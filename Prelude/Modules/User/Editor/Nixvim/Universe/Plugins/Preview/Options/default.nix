# Preview: universal browser-based asset preview
{ lib, ... }:
{
  options.nixvim.preview = {
    enable = lib.mkEnableOption "universal asset preview";
    port = lib.mkOption { type = lib.types.port; default = 9876; description = "Preview server port"; };
    autoSwitch = lib.mkOption { type = lib.types.bool; default = true; description = "Auto-switch preview on buffer change"; };
    browser = lib.mkOption { type = lib.types.str; default = "open"; description = "Browser launch command"; };
    converters = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        # 2D HDR images → PNG
        exr = "ffmpeg -loglevel error -y -i \${input} \${output}.png";
        hdr = "ffmpeg -loglevel error -y -i \${input} \${output}.png";
        tga = "ffmpeg -loglevel error -y -i \${input} \${output}.png";
        tiff = "ffmpeg -loglevel error -y -i \${input} \${output}.png";
        tif = "ffmpeg -loglevel error -y -i \${input} \${output}.png";
        dds = "ffmpeg -loglevel error -y -i \${input} \${output}.png";
        bmp = "ffmpeg -loglevel error -y -i \${input} \${output}.png";
        # Vector → SVG
        eps = "inkscape --export-type=svg --export-filename=\${output}.svg \${input}";
        ai = "inkscape --export-type=svg --export-filename=\${output}.svg \${input}";
        # 3D models → GLB
        fbx = "assimp export \${input} \${output}.glb";
        dae = "assimp export \${input} \${output}.glb";
        "3ds" = "assimp export \${input} \${output}.glb";
        ply = "assimp export \${input} \${output}.glb";
        off = "assimp export \${input} \${output}.glb";
        obj = "assimp export \${input} \${output}.glb";
        stl = "assimp export \${input} \${output}.glb";
        # CAD → GLB (via freecad → stl → assimp)
        step = "freecad-cmd \${input} --export \${output}.stl && assimp export \${output}.stl \${output}.glb";
        stp = "freecad-cmd \${input} --export \${output}.stl && assimp export \${output}.stl \${output}.glb";
        iges = "freecad-cmd \${input} --export \${output}.stl && assimp export \${output}.stl \${output}.glb";
        igs = "freecad-cmd \${input} --export \${output}.stl && assimp export \${output}.stl \${output}.glb";
        brep = "freecad-cmd \${input} --export \${output}.stl && assimp export \${output}.stl \${output}.glb";
        # Parametric 3D → GLB
        scad = "openscad -o \${output}.stl \${input} && assimp export \${output}.stl \${output}.glb";
        # Audio → WAV
        mid = "timidity \${input} -Ow -o \${output}.wav";
        midi = "timidity \${input} -Ow -o \${output}.wav";
        mod = "ffmpeg -loglevel error -y -i \${input} \${output}.wav";
        xm = "ffmpeg -loglevel error -y -i \${input} \${output}.wav";
        it = "ffmpeg -loglevel error -y -i \${input} \${output}.wav";
        s3m = "ffmpeg -loglevel error -y -i \${input} \${output}.wav";
        # Video → MP4
        avi = "ffmpeg -loglevel error -y -i \${input} -c:v libx264 -c:a aac \${output}.mp4";
        mkv = "ffmpeg -loglevel error -y -i \${input} -c:v libx264 -c:a aac \${output}.mp4";
        mov = "ffmpeg -loglevel error -y -i \${input} -c:v libx264 -c:a aac \${output}.mp4";
        flv = "ffmpeg -loglevel error -y -i \${input} -c:v libx264 -c:a aac \${output}.mp4";
        wmv = "ffmpeg -loglevel error -y -i \${input} -c:v libx264 -c:a aac \${output}.mp4";
        # Shaders → GLSL
        hlsl = "naga \${input} \${output}.glsl";
        wgsl = "naga \${input} \${output}.glsl";
        # Diagrams → SVG
        d2 = "d2 --layout=elk \${input} \${output}.svg";
        mmd = "mmdc -i \${input} -o \${output}.svg";
        dot = "dot -Tsvg \${input} -o \${output}.svg";
        puml = "plantuml -tsvg \${input}";
        # Tilemaps XML → JSON
        tmx = ""; # built-in XML→JSON in Go sidecar
        # Docs → HTML
        rst = "pandoc -f rst -t html -o \${output}.html \${input}";
        org = "pandoc -f org -t html -o \${output}.html \${input}";
        adoc = "pandoc -f asciidoc -t html -o \${output}.html \${input}";
        tex = "pandoc -f latex -t html -o \${output}.html \${input}";
        # Typst → PDF
        typ = "typst compile \${input} \${output}.pdf";
        # Data → JSON
        db = "sqlite3 -json \${input} 'SELECT * FROM sqlite_master' > \${output}.json";
      };
      description = "Extension → conversion command. \${input} and \${output} substituted at runtime.";
    };
  };
}