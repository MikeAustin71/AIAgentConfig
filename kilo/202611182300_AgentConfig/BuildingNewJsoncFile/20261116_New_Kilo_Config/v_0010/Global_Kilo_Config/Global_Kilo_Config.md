

# Global Kilo Config



## C:\Users\%USERPROFILE%\.config\kilo\kilo.jsonc

### Before Modification

**`kiloGlobal.jsonc`** **<u>2026-11-15</u>** 

```
{
  "$schema": "https://app.kilo.ai/config.json",
  "provider": {
    "ollama": {
      "name": "Ollama Local",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen38-dev:32kb": {
          "id": "qwen38-dev:32kb",
          "name": "qwen38-dev:32kb"
        },
        "gemma4:31b": {
          "id": "gemma4:31b",
          "name": "gemma4:31b"
        }
      }
    }
  },
  "agent": {
    "debug": {
    },
    "ask": {
    },
    "code": {
    },
    "plan": {
    }
  },
  "compaction": {
    "auto": true,
    "threshold_percent": 90
  },
  "permission": {
    "glob": "allow",
    "grep": "allow",
    "list": "allow",
    "todowrite": "allow",
    "lsp": "allow",
    "skill": "allow",
    "todoread": "allow",
    "webfetch": "ask",
    "websearch": "ask",
    "task": "ask",
    "read": "allow",
    "edit": "allow"
  }
}
```

