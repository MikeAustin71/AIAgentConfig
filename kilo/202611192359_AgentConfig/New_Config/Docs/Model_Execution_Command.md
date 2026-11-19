# Model Creation Execution Commands



## Create ***gemma4-dev:64kb***



### Model File: **`G:\ModelFiles\Modelfile_gemma4_64kb`** 

```
# G:\ModelFiles\Modelfile_gemma4_64kb
FROM gemma4:31b

# Specify 64K context window
PARAMETER num_ctx 65536
```



### Create Model Commands

Create 64kb context for local LLM Model ***gemma4:31b***

```bash
# Create Model Derivative Command
ollama create gemma4-dev:64kb -f G:\ModelFiles\Modelfile_gemma4_64kb

# Run Command
ollama run gemma4-dev:64kb

# Run 'show' Command to view Model info
ollama show --modelfile gemma4-dev:64kb

# Other model parameter display commands
ollama ps

ollama show gemma4-dev:64kb
```



### Status - Done 2026-11-19 15:18-Hours



## Create ***gemma4-dev:32kb***



### Model File: **`G:\ModelFiles\Modelfile_gemma4_32kb`**

```bash
# G:\ModelFiles\Modelfile_gemma4_32kb
FROM gemma4:31b

# Specify 32K context window
PARAMETER num_ctx 32768

```

### 	

### Create Model Commands

Create 64kb context for local LLM Model ***gemma4:31b***

```bash
# Create Model Derivative Command
ollama create gemma4-dev:32kb -f G:\ModelFiles\Modelfile_gemma4_32kb

# Run Command
ollama run gemma4-dev:32kb

# Run 'show' Command to view Model info
ollama show --modelfile gemma4-dev:32kb

# Other model parameter display commands
ollama ps

ollama show gemma4-dev:32kb
```



### Status: DONE -  2026-11-19 15:32-Hours