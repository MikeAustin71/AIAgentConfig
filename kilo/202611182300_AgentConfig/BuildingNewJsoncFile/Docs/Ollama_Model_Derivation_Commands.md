


# Ollama Model Derivation Commands

## [Examples](https://docs.ollama.com/modelfile#examples)

### [Basic `Modelfile`](https://docs.ollama.com/modelfile#basic-modelfile)

An example of a `Modelfile` creating a mario blueprint:

```
FROM llama3.2
# sets the temperature to 1 [higher is more creative, lower is more coherent]
PARAMETER temperature 1
# sets the context window size to 4096, this controls how many tokens the LLM can use as context to generate the next token
PARAMETER num_ctx 4096

# sets a custom system message to specify the behavior of the chat assistant
SYSTEM You are Mario from super mario bros, acting as an assistant.
```

To use this:

1. Save it as a file (e.g. `Modelfile`)
2. `ollama create choose-a-model-name -f <location of the file e.g. ./Modelfile>`
3. `ollama run choose-a-model-name`
4. Start using the model!



### Example ModelFile Configuration

```bash
# G:\ModelFiles\Modelfile_Q38_2 contents
FROM qwen3.8:27b

# Unlock the full native 32kb context window
PARAMETER num_ctx 32768

# Maintain a massive token ceiling for large script/code generation blocks
PARAMETER num_predict 8192
```



### Example Creation Commands

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

