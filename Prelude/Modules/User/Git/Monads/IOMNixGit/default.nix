# IOMNixGit Monad — enables itself + default ignores
{ lib, ... }:
{
  config.git.enable = true;
  config.git.ignores = [
    ".DS_Store" "Thumbs.db" "Desktop.ini"
    ".idea/" "*.iml" ".vscode/" "*.swp" "*.swo" "*~" ".project" ".classpath" ".settings/"
    "result" "result-*" ".direnv/"
    "*.class" "*.jar" "*.war" "*.ear" "target/" "build/" ".gradle/" "out/"
    "node_modules/" "dist/" ".next/" ".nuxt/" ".output/" ".cache/" "*.log" ".parcel-cache/"
    ".env" ".env.*" "!.env.example" "*.pem" "*.key" "*.p12" "*.pfx" "*.jks"
    "*.gpg" "*.asc" "*.age" "secrets/" ".secrets/" "credentials.json"
    "*.enc" "*.encrypted" "*.sealed" "secret.*" "!secret.*.example"
  ];
}
