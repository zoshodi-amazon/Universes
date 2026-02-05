# LLM

Local inference capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Apps |
| Purpose | Local LLM inference |
| Bindings | ollama, localai |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable LLM server |
| `backend` | enum | "ollama" | LLM backend |
| `domain` | str | "llm.localhost" | API domain |
| `models` | listOf str | [] | Models to pull |
| `gpu` | bool | false | Enable GPU acceleration |

## Usage

```nix
servers.apps.llm = {
  enable = true;
  backend = "ollama";
  models = [ "llama3" "codellama" ];
  gpu = true;
};
```

## Auto-Wiring

When enabled:
- Gateway: `llm.<domain>` route (API)
- ObjectStore: Model cache storage

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| ollama | `ollama/ollama` | Simple, model library |
| localai | `localai/localai` | OpenAI-compatible API |
