[TOC]



# 2026-11-09 20:15-Hours Agent Config Plan

## Current Available Local Models

1. **`gemma4:31b`** - 32kb context window
2. **`qwen3.8:27b`** - 32kb context window
3. **`qwen-tuned-38:latest`** - Tuned for 16kb context window



## Implement These Ollama Settings - Done

To make `OLLAMA_NUM_PARALLEL` work effectively, you must configure two companion environment variables alongside it. Update your **Windows System Environment Variables** with the following matrix:

| Environment Variable           | Recommended Value         | Purpose                                                      |
| ------------------------------ | ------------------------- | ------------------------------------------------------------ |
| **`OLLAMA_NUM_PARALLEL`**      | `2` *(or 4)* (Set to '2') | Handles simultaneous IDE agent requests without queuing.     |
| **`OLLAMA_MAX_LOADED_MODELS`** | `1`                       | Forces Ollama to keep only **one** active model in VRAM at a time, preventing your 27B and 31B models from fighting over your 24GB GPU limit. |
| **`HSA_OVERRIDE_GFX_VERSION`** | `11.0.0`                  | Ensures your RX 7900 XTX (Navi 31) utilizes native ROCm acceleration seamlessly under Windows/WSL. |



## *Tune* a New Variant of **`qwen3.8:27b`** Model

### Step 1: Remove the Old *Tuned* Model, *``qwen3.8:27b``* - DONE

```bash
ollama rm qwen-tuned-38:latest
```



### Step 2: Download and Install the Latest ***qwen3.8:27b*** Model from Ollama - DONE

```bash
ollama pull qwen3.8:27b
```

Using `ollama pull` ensures you download the absolute latest iteration without accidentally initiating an interactive chat session in your terminal window.

### Step 3: Configure New Modelfile - DONE

#### Step 3-A: Delete or Archive Old Modelfile **`G:\ModelFiles\Modelfile_Q38_1`**

#### Step 3-B: Configure New Modelfile **`G:\ModelFiles\Modelfile_Q38_2`**

##### Configuration for **`G:\ModelFiles\Modelfile_Q38_2`**

```bash
# G:\ModelFiles\Modelfile_Q38_2 contents 
FROM qwen3.8:27b

# Unlock the full native 32kb context window
PARAMETER num_ctx 32768

# Maintain a massive token ceiling for large script/code generation blocks
PARAMETER num_predict 8192
```



### Step 4: Build New ***Tuned*** Model for Windows

```bash
ollama create qwen38-dev:32kb -f G:\ModelFiles\Modelfile_Q38_2
```

#### Granular Control Over Naming and Labels

**You have 100% complete granular control over your model labels.** Ollama does not automatically force names on you; you simply specify your chosen naming scheme right after the `ollama create` instruction.

Ollama uses a standard **`name:tag`** convention. You can exploit this to organize versions cleanly across your development projects:

- **Structure:** `[model-purpose]-[base-size]:[your-custom-tag]`
- **Examples of valid names you can use right now:**
  - `ollama create qwen-go:v1 -f ...`
  - `ollama create qwen38-coding:32kb-ctx -f ...`
  - `ollama create dev-qwen-27b:experimental -f ...`

Using distinct tags (like `:32kb-ctx` vs `:16kb-ctx`) will completely prevent any naming conflicts when you alternate configurations inside your **kilo** agent.



### Step 5: Download and Install the Latest **`gemma4:31b`** Model from Ollama - DONE

```bash
ollama pull gemma4:31b
```



### Step 6: Modify ***`kilo.jsonc`*** ***agent*** Property - DONE

```json
"agent": {
    "build": {
      "temperature": 0.2,
      "top_p": 0.90,
      "repeat_penalty": 1.15,
      "repeat_last_n": 64
    },
    "ask": {
      "temperature": 0.1,
      "top_p": 0.50,
      "repeat_penalty": 1.15,
      "repeat_last_n": 64
    }
},
```

#### Property Definitions

##### What is `top_p` and Recommended Setting

**`top_p` (Nucleus Sampling)** controls pool diversity. It tells the LLM to only consider a cumulative percentage of the most likely words. For instance, `0.95` means the model throws away the bottom 5% of highly unusual words.

- **Recommended Setting for Code:** Set `top_p` to **`0.90`** (or even down to **`0.50`** for deep logic like Rust/Go). Lowering `top_p` cuts off the "long tail" of weird or experimental syntax choices, forcing the model to select standard, clean, and idiomatic coding patterns.



##### **`repeat_penalty = 1.1` to `1.2`** (Ollama's default is usually `1.1`)

- **What it does:** Scolds the model for using the exact same tokens it just generated. Setting this slightly higher than 1.0 breaks infinite code repetition loops instantly.

  

##### **`repeat_last_n = 64`**

- **What it does:** Tells the model how far back into its own output history to look for repetitions. For coding, 64 to 128 tokens is the sweet spot.



### Step 7: Modify Global ***kilo.jsonc*** Configuration File

It was necessary to convert the ***baseURL*** property from:

```json
"baseURL": "http://localhost:11434"
```

TO:

```json
"baseURL": "http://localhost:11434/v1"
```



The modified global ***kilo.jsonc*** file is shown as follows:

```json
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

 

### [Reference: 202611092159_Google_Search.md](D:\Programming\ArtificialIntelligence\LLM_Server_Frameworks\Ollama\Ollama_Operations\Ollama_Settings\Research\202611092159_Google_Search\202611092159_Google_Search.md)



## Modifications COMPLETED! JOB DONE!