package main

import (
	"embed"
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io"
	"log"
	"mime"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"

	"github.com/gorilla/websocket"
)

//go:embed static/index.html
var staticFS embed.FS

// --- WebSocket hub ---

type Hub struct {
	mu      sync.RWMutex
	clients map[*websocket.Conn]bool
}

func (h *Hub) add(c *websocket.Conn) {
	h.mu.Lock()
	h.clients[c] = true
	h.mu.Unlock()
}

func (h *Hub) remove(c *websocket.Conn) {
	h.mu.Lock()
	delete(h.clients, c)
	h.mu.Unlock()
	c.Close()
}

func (h *Hub) broadcast(msg []byte) {
	h.mu.Lock()
	defer h.mu.Unlock()
	for c := range h.clients {
		if err := c.WriteMessage(websocket.TextMessage, msg); err != nil {
			c.Close()
			delete(h.clients, c)
		}
	}
}

var hub = &Hub{clients: make(map[*websocket.Conn]bool)}
var upgrader = websocket.Upgrader{CheckOrigin: func(r *http.Request) bool { return true }}

// --- Conversion ---

var converters = map[string]string{}
var cacheDir string

func init() {
	cacheDir = filepath.Join(os.TempDir(), "asset-preview-cache")
	os.MkdirAll(cacheDir, 0o755)
}

func loadConverters() {
	raw := os.Getenv("PREVIEW_CONVERTERS")
	if raw == "" {
		return
	}
	json.Unmarshal([]byte(raw), &converters)
}

func webNative(ext string) bool {
	switch ext {
	case "png", "jpg", "jpeg", "gif", "webp", "svg", "bmp",
		"mp3", "ogg", "wav", "flac", "aac",
		"mp4", "webm",
		"glb", "gltf", "obj", "stl",
		"glsl", "frag", "vert",
		"ttf", "otf", "woff", "woff2",
		"pdf",
		"md", "json", "yaml", "yml", "toml", "csv", "html":
		return true
	}
	return false
}

func convert(filePath, ext string) (string, string, error) {
	cmd, ok := converters[ext]
	if !ok || cmd == "" {
		if ext == "tmx" {
			return convertTMX(filePath)
		}
		return "", "", fmt.Errorf("no converter for .%s", ext)
	}
	base := filepath.Base(filePath)
	outBase := filepath.Join(cacheDir, strings.TrimSuffix(base, "."+ext))
	expanded := strings.ReplaceAll(cmd, "${input}", filePath)
	expanded = strings.ReplaceAll(expanded, "${output}", outBase)

	c := exec.Command("sh", "-c", expanded)
	c.Stderr = os.Stderr
	if err := c.Run(); err != nil {
		return "", "", fmt.Errorf("converter failed for .%s: %w", ext, err)
	}
	matches, _ := filepath.Glob(outBase + ".*")
	if len(matches) == 0 {
		return "", "", fmt.Errorf("converter produced no output for .%s", ext)
	}
	outPath := matches[len(matches)-1]
	outExt := strings.TrimPrefix(filepath.Ext(outPath), ".")
	return outPath, outExt, nil
}

func convertTMX(filePath string) (string, string, error) {
	data, err := os.ReadFile(filePath)
	if err != nil {
		return "", "", err
	}
	var xmlData interface{}
	if err := xml.Unmarshal(data, &xmlData); err != nil {
		outPath := filepath.Join(cacheDir, filepath.Base(filePath)+".json")
		os.WriteFile(outPath, []byte(`{"error":"failed to parse TMX","raw":true}`), 0o644)
		return outPath, "json", nil
	}
	jsonBytes, _ := json.MarshalIndent(xmlData, "", "  ")
	outPath := filepath.Join(cacheDir, filepath.Base(filePath)+".json")
	os.WriteFile(outPath, jsonBytes, 0o644)
	return outPath, "json", nil
}

// --- Message types ---

type PreviewMsg struct {
	File    string `json:"file"`
	Type    string `json:"type"`
	Warning string `json:"warning,omitempty"`
	URL     string `json:"url,omitempty"`
}

// resolvePreview takes a file path, determines type, converts if needed, returns broadcast msg.
func resolvePreview(msg *PreviewMsg) {
	ext := strings.TrimPrefix(filepath.Ext(msg.File), ".")
	if ext == "" {
		ext = msg.Type
	}
	msg.Type = ext

	if webNative(ext) {
		msg.URL = "/file?path=" + msg.File
	} else {
		converted, newExt, err := convert(msg.File, ext)
		if err != nil {
			msg.Warning = err.Error()
			msg.URL = "/file?path=" + msg.File
		} else {
			msg.Type = newExt
			msg.URL = "/file?path=" + converted
		}
	}
}

// --- HTTP handlers ---

func handleWS(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		return
	}
	hub.add(conn)
	defer hub.remove(conn)

	for {
		_, raw, err := conn.ReadMessage()
		if err != nil {
			break
		}
		var msg PreviewMsg
		if err := json.Unmarshal(raw, &msg); err != nil {
			continue
		}
		resolvePreview(&msg)
		out, _ := json.Marshal(msg)
		hub.broadcast(out)
	}
}

// handlePreviewPost accepts POST from nvim (curl) and broadcasts to WS clients.
func handlePreviewPost(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "POST only", 405)
		return
	}
	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, err.Error(), 400)
		return
	}
	var msg PreviewMsg
	if err := json.Unmarshal(body, &msg); err != nil {
		http.Error(w, err.Error(), 400)
		return
	}
	resolvePreview(&msg)
	out, _ := json.Marshal(msg)
	hub.mu.RLock()
	clients := len(hub.clients)
	hub.mu.RUnlock()
	fmt.Fprintf(os.Stderr, "broadcasting to %d clients\n", clients)
	hub.broadcast(out)
	w.Header().Set("Content-Type", "application/json")
	w.Write(out)
}

func handleFile(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Query().Get("path")
	if path == "" {
		http.Error(w, "missing path", 400)
		return
	}
	ext := strings.TrimPrefix(filepath.Ext(path), ".")
	ct := mime.TypeByExtension("." + ext)
	if ct == "" {
		ct = "application/octet-stream"
	}
	switch ext {
	case "glb":
		ct = "model/gltf-binary"
	case "gltf":
		ct = "model/gltf+json"
	case "glsl", "frag", "vert":
		ct = "text/plain"
	case "md":
		ct = "text/markdown"
	case "yaml", "yml":
		ct = "text/yaml"
	case "toml":
		ct = "text/plain"
	case "csv":
		ct = "text/csv"
	case "obj":
		ct = "text/plain"
	case "stl":
		ct = "application/octet-stream"
	case "ttf":
		ct = "font/ttf"
	case "otf":
		ct = "font/otf"
	case "woff":
		ct = "font/woff"
	case "woff2":
		ct = "font/woff2"
	}
	w.Header().Set("Content-Type", ct)
	w.Header().Set("Access-Control-Allow-Origin", "*")
	f, err := os.Open(path)
	if err != nil {
		http.Error(w, err.Error(), 404)
		return
	}
	defer f.Close()
	io.Copy(w, f)
}

func handleIndex(w http.ResponseWriter, r *http.Request) {
	data, _ := staticFS.ReadFile("static/index.html")
	w.Header().Set("Content-Type", "text/html")
	w.Write(data)
}

func main() {
	loadConverters()
	port := os.Getenv("PREVIEW_PORT")
	if port == "" {
		port = "9876"
	}

	http.HandleFunc("/", handleIndex)
	http.HandleFunc("/ws", handleWS)
	http.HandleFunc("/preview", handlePreviewPost)
	http.HandleFunc("/file", handleFile)

	addr := "127.0.0.1:" + port
	fmt.Fprintf(os.Stderr, "asset-preview listening on http://%s\n", addr)
	log.Fatal(http.ListenAndServe(addr, nil))
}
