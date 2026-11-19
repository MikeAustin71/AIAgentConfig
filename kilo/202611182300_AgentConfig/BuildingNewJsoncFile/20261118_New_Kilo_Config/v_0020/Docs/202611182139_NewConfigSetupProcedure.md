

# New Kilo Configuration Setup Procedure 2026-11-17 17:01-Hours



### 64K Context Qwen 3.8 Model Derivation and Configuration Procedures

#### Step 1: Set Windows 11 Environment Variables - <u>Completed 2026-11-17 17:05-Hours</u>

```
OLLAMA_FLASH_ATTENTION=1
OLLAMA_KV_CACHE_TYPE=q8_0
```

#### Step 2: ***Fully Quit*** and Restart ***Ollama***

#### Step 3: Create Model File Configuration for `qwen38-dev:64kb` Derivation

Proposed Model File Name: **`G:\ModelFiles\Modelfile_Q38_64`**

##### File Contents:

```bash
# G:\ModelFiles\Modelfile_Q38_64
FROM qwen3.8:27b

# Specify 64K context window
PARAMETER num_ctx 65536

```

#### Step 4: Create `qwen38-dev:64kb` Model Derivation

##### Execute Model File Creation Commands

```bash
# Create Model Derivative Command
ollama create qwen38-dev2:64kb -f G:\ModelFiles\Modelfile_Q38_64

# Run Command
ollama run qwen38-dev2:64kb

# Run 'show' Command to view Model info
ollama show --modelfile qwen38-dev2:64kb

# Other model parameter display commands
ollama ps

ollama show qwen38-dev2:64kb
```

#### Step 5: **Always verify with `ollama ps` during a real Kilo + JetBrains session:**

While JetBrains and your normal browser tabs are open and Kilo is actively generating, run:

```powershell
ollama ps
```

Check two columns:

* **`CONTEXT`** should show `65536`.
* **`PROCESSOR`** must say **`100% GPU`**. If you see something like `88%/12% GPU/CPU` (or heavy Shared GPU Memory use in Task Manager), drop back to `qwen38-dev:32kb` (or close VRAM-hungry apps).

#### Step 6: **Keep both tags (`32kb` and `64kb`) and update `kilo.jsonc`:**

* Keep `qwen38-dev2:64kb` for heavy agentic coding (`code` / `plan`) where Kilo reads multiple files and needs room before compaction.
* Keep `qwen38-dev:32kb` as Jose's snappy backup for games, Docker/WSL, or heavy GPU apps open alongside JetBrains.

#### Step 7: Update **`kilo.jsonc`**

Make sure your `kilo.jsonc` entry for `qwen38-dev2:64kb` sets `"limit": { "context": 65536, "output": 16384 }` so Kilo knows it has the full 64K runway before auto-compacting. *(And keep `variant: "medium"` or `"low"`—because Qwen 3.8's thinking tokens eat from that same 64K budget.)*

```json
# TO BE DETERMINED TBD
```



## 