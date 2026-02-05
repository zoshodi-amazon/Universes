package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Mode represents TUI mode (vim-like)
type Mode int

const (
	ModeBrowse Mode = iota
	ModeEdit
	ModePreview
	ModeCommand
)

func (m Mode) String() string {
	return [...]string{"BROWSE", "EDIT", "PREVIEW", "COMMAND"}[m]
}

// Asset represents a library asset
type Asset struct {
	ID     string   `json:"id"`
	Name   string   `json:"name"`
	Path   string   `json:"path"`
	Source string   `json:"source"`
	Tags   []string `json:"tags"`
}

func (a Asset) Title() string       { return a.Name }
func (a Asset) Description() string { return a.Path }
func (a Asset) FilterValue() string { return a.Name }

// Transform represents a transform in the stack
type Transform struct {
	Type   string                 `json:"type"`
	Params map[string]interface{} `json:"params"`
}

// Model is the Elm architecture model
type Model struct {
	domain      string
	justfile    string
	mode        Mode
	assets      []Asset
	assetList   list.Model
	current     *Asset
	stack       []Transform
	commandInput textinput.Model
	width       int
	height      int
	err         error
}

// Styles
var (
	titleStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("212")).
			Bold(true)
	modeStyle = lipgloss.NewStyle().
			Background(lipgloss.Color("62")).
			Foreground(lipgloss.Color("230")).
			Padding(0, 1)
	helpStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("241"))
	stackStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(lipgloss.Color("62")).
			Padding(0, 1)
)

func initialModel(domain, justfile string) Model {
	// Command input
	ti := textinput.New()
	ti.Placeholder = "command..."
	ti.CharLimit = 256

	// Asset list
	delegate := list.NewDefaultDelegate()
	l := list.New([]list.Item{}, delegate, 0, 0)
	l.Title = "Library"
	l.SetShowStatusBar(false)
	l.SetFilteringEnabled(true)

	return Model{
		domain:       domain,
		justfile:     justfile,
		mode:         ModeBrowse,
		assets:       []Asset{},
		assetList:    l,
		stack:        []Transform{},
		commandInput: ti,
	}
}

func (m Model) Init() tea.Cmd {
	return m.loadAssets()
}

func (m Model) loadAssets() tea.Cmd {
	return func() tea.Msg {
		// Call library script to list assets
		cmd := exec.Command("nu", 
			"Universe/Library/Bindings/Scripts/default.nu",
			`{"action": "list"}`)
		out, err := cmd.Output()
		if err != nil {
			return errMsg{err}
		}
		var assets []Asset
		if err := json.Unmarshal(out, &assets); err != nil {
			return errMsg{err}
		}
		return assetsMsg{assets}
	}
}

type assetsMsg struct{ assets []Asset }
type errMsg struct{ err error }

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		return m.handleKey(msg)
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		m.assetList.SetSize(msg.Width/3, msg.Height-4)
		return m, nil
	case assetsMsg:
		m.assets = msg.assets
		items := make([]list.Item, len(msg.assets))
		for i, a := range msg.assets {
			items[i] = a
		}
		m.assetList.SetItems(items)
		return m, nil
	case errMsg:
		m.err = msg.err
		return m, nil
	}
	return m, nil
}

func (m Model) handleKey(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	key := msg.String()

	// Global keys
	switch key {
	case "q", "ctrl+c":
		return m, tea.Quit
	case "esc":
		if m.mode == ModeCommand {
			m.mode = ModeBrowse
			m.commandInput.Reset()
		}
		return m, nil
	}

	// Mode-specific keys
	switch m.mode {
	case ModeBrowse:
		return m.handleBrowseKey(key)
	case ModeEdit:
		return m.handleEditKey(key)
	case ModePreview:
		return m.handlePreviewKey(key)
	case ModeCommand:
		return m.handleCommandKey(msg)
	}
	return m, nil
}

func (m Model) handleBrowseKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "e":
		m.mode = ModeEdit
	case "p":
		m.mode = ModePreview
		return m, m.spawnPreview()
	case ":":
		m.mode = ModeCommand
		m.commandInput.Focus()
	case "enter":
		if i, ok := m.assetList.SelectedItem().(Asset); ok {
			m.current = &i
		}
	case "j", "down":
		m.assetList, _ = m.assetList.Update(msg)
	case "k", "up":
		m.assetList, _ = m.assetList.Update(msg)
	}
	
	var cmd tea.Cmd
	m.assetList, cmd = m.assetList.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune(key)})
	return m, cmd
}

func (m Model) handleEditKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "b":
		m.mode = ModeBrowse
	case "j", "k", "h", "l":
		// Dial adjustment would go here
	}
	return m, nil
}

func (m Model) handlePreviewKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "b":
		m.mode = ModeBrowse
	case "space":
		return m, m.togglePlay()
	}
	return m, nil
}

func (m Model) handleCommandKey(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "enter":
		cmd := m.commandInput.Value()
		m.commandInput.Reset()
		m.mode = ModeBrowse
		return m, m.executeCommand(cmd)
	}
	var cmd tea.Cmd
	m.commandInput, cmd = m.commandInput.Update(msg)
	return m, cmd
}

func (m Model) executeCommand(cmd string) tea.Cmd {
	return func() tea.Msg {
		parts := strings.Fields(cmd)
		if len(parts) == 0 {
			return nil
		}
		switch parts[0] {
		case "fetch":
			if len(parts) >= 2 {
				exec.Command("just", "-f", m.justfile, "fetch", parts[1]).Run()
			}
		case "play":
			if m.current != nil {
				exec.Command("just", "-f", m.justfile, "play", m.current.Path).Run()
			}
		case "analyze":
			if m.current != nil {
				exec.Command("just", "-f", m.justfile, "analyze", m.current.Path).Run()
			}
		}
		return nil
	}
}

func (m Model) spawnPreview() tea.Cmd {
	return func() tea.Msg {
		if m.current == nil {
			return nil
		}
		// Spawn cava in tmux split
		exec.Command("tmux", "split-window", "-h", "cava").Run()
		return nil
	}
}

func (m Model) togglePlay() tea.Cmd {
	return func() tea.Msg {
		if m.current != nil {
			exec.Command("just", "-f", m.justfile, "play", m.current.Path).Run()
		}
		return nil
	}
}

func (m Model) View() string {
	if m.width == 0 {
		return "Loading..."
	}

	// Header
	header := lipgloss.JoinHorizontal(
		lipgloss.Top,
		titleStyle.Render(fmt.Sprintf("Lab [%s]", m.domain)),
		"  ",
		modeStyle.Render(m.mode.String()),
	)

	// Main content based on mode
	var content string
	switch m.mode {
	case ModeBrowse:
		content = m.viewBrowse()
	case ModeEdit:
		content = m.viewEdit()
	case ModePreview:
		content = m.viewPreview()
	case ModeCommand:
		content = m.viewCommand()
	}

	// Help
	help := helpStyle.Render("[b]rowse [e]dit [p]review [:]cmd [q]uit")

	return lipgloss.JoinVertical(lipgloss.Left, header, "", content, "", help)
}

func (m Model) viewBrowse() string {
	left := m.assetList.View()
	
	right := "No asset selected"
	if m.current != nil {
		right = fmt.Sprintf("Current: %s\nPath: %s\n\nStack:\n", m.current.Name, m.current.Path)
		for i, t := range m.stack {
			right += fmt.Sprintf("  [%d] %s\n", i, t.Type)
		}
	}
	rightBox := stackStyle.Width(m.width/2 - 4).Render(right)
	
	return lipgloss.JoinHorizontal(lipgloss.Top, left, "  ", rightBox)
}

func (m Model) viewEdit() string {
	return "Edit mode - adjust dials with j/k (coarse) h/l (fine)\n\nNo dials configured yet."
}

func (m Model) viewPreview() string {
	if m.current == nil {
		return "No asset selected for preview"
	}
	return fmt.Sprintf("Preview: %s\n\n[space] play/pause  [b] back", m.current.Name)
}

func (m Model) viewCommand() string {
	return fmt.Sprintf(":%s", m.commandInput.View())
}

func main() {
	domain := flag.String("domain", "audio", "Lab domain (audio, video, 3d, data)")
	justfile := flag.String("justfile", "", "Path to domain justfile")
	flag.Parse()

	if *justfile == "" {
		*justfile = fmt.Sprintf("Modules/Labs/%s/justfile", strings.Title(*domain))
	}

	p := tea.NewProgram(initialModel(*domain, *justfile), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
