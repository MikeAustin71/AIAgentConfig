



This global ***kilo.jsonc*** file is stored at :

```bash
C:\Users\%USERPROFILE%\.config\kilo\kilo.jsonc
```



The original ***kilo.jsonc*** is shown as follows:

```json
{
  "$schema": "https://app.kilo.ai/config.json",
  "provider": {
    "ollama": {
      "name": "Ollama Local",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://localhost:11434"
      },
      "models": {
        "qwen38-dev:32kb": {
          "id": "qwen38-dev:32kb",
          "name": "qwen38-dev:32kb"
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
    "auto": true
  }
}
```

