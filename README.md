# openclaw-plugin-skill-preflight

An [OpenClaw](https://openclaw.ai) plugin that automatically injects relevant skills and protocols into agent context before each run — using Ollama embeddings. Free. No separate embedding API required.

## How it works

1. Scans your `skills/` and `memory/protocols/` directories (recursively)
2. Embeds each doc using [nomic-embed-text](https://ollama.com/library/nomic-embed-text) via Ollama
3. On every agent run, embeds the incoming prompt and cosine-similarity matches against your docs
4. Injects only the relevant ones — above a configurable score threshold
5. Session deduplication: same doc won't be re-injected twice in one conversation

**Result:** agents follow their own protocols without burning tokens on irrelevant context.

## Requirements

- [OpenClaw](https://openclaw.ai) ≥ 1.0
- [Ollama](https://ollama.com) running locally
- `nomic-embed-text` model: `ollama pull nomic-embed-text`

## Installation

```bash
npm install openclaw-plugin-skill-preflight
```

Then register in your `openclaw.json`:

```json
{
  "plugins": {
    "skill-preflight": {
      "enabled": true,
      "config": {
        "minScore": 0.3,
        "maxResults": 3
      }
    }
  }
}
```

## Config options

| Option | Default | Description |
|--------|---------|-------------|
| `protocolDirs` | `["memory/protocols"]` | Dirs to scan for protocol docs (recursive) |
| `skillsDirs` | `["skills"]` | Dirs to scan for skill docs |
| `toolsFiles` | `["TOOLS.md"]` | Individual files to always include in the index |
| `pinnedDocs` | `[]` | Docs always injected regardless of score |
| `maxResults` | `3` | Max ranked docs to inject per run |
| `maxDocLines` | `0` | Truncate injected docs to N lines (0 = no limit) |
| `minScore` | `0.3` | Cosine similarity threshold — tune via debug logs |
| `embedModel` | `nomic-embed-text:latest` | Ollama model for embeddings |
| `ollamaBaseUrl` | `http://localhost:11434` | Ollama API base URL. Keep this local (`localhost`, `127.0.0.1`, `::1`) if you want prompts and indexed docs to stay on the same machine. A remote host will receive that text for embedding. |
| `requestTimeoutMs` | `10000` | Timeout for embedding calls |

## Pinned docs

Always inject a specific doc regardless of relevance score:

```json
{
  "pinnedDocs": ["memory/protocols/house-rules.md"]
}
```

Pinned docs appear first and don't count toward `maxResults`.

## Tuning minScore

Enable debug logging in OpenClaw to see similarity scores per run:

```
skill-preflight: scores — DebuggingProtocol(0.72), EthereumSkill(0.51), MemoryProtocol(0.34), ...
```

Use this to dial in your threshold.

## Privacy note

This plugin is local-only **when your configured `ollamaBaseUrl` is local**. If you change it to a remote URL, the plugin will POST prompt text and indexed markdown content to that remote Ollama host for embeddings. Treat that as a trust-boundary change, not a cosmetic config tweak.

## License

MIT
