# Git Ignore Bindings
{ ... }:
{
  config.git.ignores = [
    # OS
    ".DS_Store" "Thumbs.db" "Desktop.ini"
    # Editors
    ".idea/" "*.iml" ".vscode/" "*.swp" "*.swo" "*~" ".project" ".classpath" ".settings/"
    # Nix
    "result" "result-*" ".direnv/"
    # Java
    "*.class" "*.jar" "*.war" "*.ear" "target/" "build/" ".gradle/" "out/"
    # Web
    "node_modules/" "dist/" ".next/" ".nuxt/" ".output/" ".cache/" "*.log" ".parcel-cache/"
    # Secrets & Keys
    ".env" ".env.*" "!.env.example" "*.pem" "*.key" "*.p12" "*.pfx" "*.jks"
    "*.gpg" "*.asc" "*.age" "secrets/" ".secrets/" "credentials.json"
    # Encrypted
    "*.enc" "*.encrypted" "*.sealed" "secret.*" "!secret.*.example"
  ];
}
