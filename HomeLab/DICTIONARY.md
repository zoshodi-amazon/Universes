# HomeLab Type Dictionary

## Inductive Types (ADTs)
| Type | Description | Constructors |
|------|-------------|-------------|
| ShellEditor | Default editor | nvim, vim, nano |
| TmuxPrefix | Tmux prefix key | ctrlA, ctrlB |
| KittyTheme | Terminal theme | tokyoNightNight, catppuccinMocha, gruvboxDark |
| Colorscheme | Editor colorscheme | tokyonight, catppuccin, gruvbox |
| GitBranch | Default git branch | main, master |
| SearchEngine | Browser search | duckDuckGo, google, brave |
| AIProvider | AI provider | amazonBedrock, openai, anthropic |
| CloudOutputFormat | CLI output format | json, text, table |

## Dependent Types (Structures)
| Type | Description | Parameterized by |
|------|-------------|-----------------|
| GitConfig | Git configuration | GitBranch |
| BrowserConfig | Browser settings | SearchEngine |
| AIConfig | AI assistant | AIProvider |
| CloudConfig | Cloud CLI | CloudOutputFormat |
| SshConfig | SSH settings | — |
| SovereigntyConfig | Workspace config | SovereigntyMode |
