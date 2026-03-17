# Environment Setup

## Hardware
- 2x NVIDIA RTX 6000 Ada Generation (48 GB VRAM each)
- CUDA 12.4 · Driver 550.144.03
- Default GPU: `CUDA_VISIBLE_DEVICES=1` (less loaded)

## Base Environment

```bash
# Create conda env
conda create -n ai-eng python=3.11 -y
conda activate ai-eng

# Core
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124
pip install anthropic openai tiktoken

# RAG stack (Phase 2)
pip install chromadb langchain llama-index sentence-transformers

# Agents (Phase 3)
pip install langgraph crewai mcp

# LLMOps (Phase 4)
pip install langfuse ragas vllm mlflow

# Multimodal (Phase 5)
pip install open-clip-torch transformers

# Dev tools
pip install jupyter pytest black ruff
```

## Ollama (local models)

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3:70b-instruct-q4_K_M   # fits in 48 GB
ollama pull nomic-embed-text              # local embeddings
```

## API Keys

```bash
# Add to ~/.bashrc or .env (NEVER commit .env)
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
```

## Docker (per-phase isolation)

```bash
# Each phase gets a Dockerfile if dependencies diverge
docker build -t ai-eng-p1 -f phase1-llm-apis/Dockerfile .
```

## Git

```bash
git init ai-engineer-2026
cd ai-engineer-2026
git remote add origin git@github.com:<username>/ai-engineer-2026.git

# .gitignore essentials
echo ".env\n*.pyc\n__pycache__/\n.venv/\ndata/proprietary/\n*.ckpt\nwandb/" > .gitignore
```
