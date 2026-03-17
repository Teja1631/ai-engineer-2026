# AI Engineer Curriculum — Roadmap 2026

**Owner:** Teja · **Start:** Mar 22, 2026 · **End:** Jun 28, 2026  
**Schedule:** Saturdays (learn) + Sundays (build) · ~120 hours total  
**Target roles:** PathAI · Intuitive Surgical · NBA · Waymo  

---

## Hardware

| Resource | Spec | Notes |
|----------|------|-------|
| GPU 0 | RTX 6000 Ada (48 GB VRAM) | Shared workstation — ~35 GB free typically |
| GPU 1 | RTX 6000 Ada (48 GB VRAM) | ~45 GB free — use this for training/inference |
| CUDA | 12.4 | Driver 550.144.03 |
| Cloud fallback | Kaggle T4 (free) / RunPod A100 ($0.40/hr) | Only if local GPUs are fully occupied |

**Tip:** Use `CUDA_VISIBLE_DEVICES=1` to target the less-loaded GPU.

---

## Phases

### P1 — LLM APIs & Prompt Engineering (2 weekends · Mar 22 → Mar 29)

**Saturday — Concepts:**
- Anthropic & OpenAI SDK: async calls, streaming, error handling
- Prompt patterns: chain-of-thought, few-shot, structured output (JSON mode)
- Token economics & context window management
- Model selection: frontier (Claude, GPT-4o) vs open (Llama 3, Mistral, Gemma)
- Ollama: run models locally on RTX 6000 (CUDA 12.4)
- System prompts & prompt versioning basics

**Sunday — Project: Tissue QC Report Generator**
- Pipe ClaraQC JSON → LLM → pathologist-readable summaries
- Streaming output + cost logging per request
- Compare Haiku 4.5 vs local Llama 3 70B (fits in 48 GB)

**Resources:** Anthropic docs · OpenAI Cookbook · Ollama GitHub · promptingguide.ai

**Deliverables:**
- [ ] Working report generator script with streaming
- [ ] Cost comparison table (Haiku vs GPT-4o-mini vs local Llama)
- [ ] Prompt version file with at least 3 iterations

---

### P2 — RAG Pipelines & Vector Search (3 weekends · Apr 5 → Apr 19)

**Saturday — Concepts:**
- Embeddings: text-embedding-3, nomic-embed, sentence-transformers
- Vector DBs: Chroma (local), Pinecone (managed), pgvector
- Chunking strategies: fixed-size, semantic, section-based
- Hybrid search: BM25 + dense retrieval
- Reranking: Cohere Rerank, cross-encoders
- LlamaIndex: document ingestion & query engine

**Sunday — Project: SectionStar Docs Assistant**
- Index internal runbooks + FDA 510(k) docs into Chroma
- RAG chatbot answering QC acceptance criteria questions
- Return answers with source citations

**Resources:** LlamaIndex docs · LangChain RAG guide · Chroma docs · Pinecone learn

**Deliverables:**
- [ ] Chroma index with chunked documents
- [ ] RAG pipeline with hybrid search + reranking
- [ ] Evaluation: retrieval precision on 20+ test queries
- [ ] Comparison: naive chunking vs semantic chunking

---

### P3 — Agentic AI & MCP (4 weekends · Apr 26 → May 17)

**Saturday — Concepts:**
- ReAct agent pattern: reasoning + tool calling loop
- Function/tool calling: Anthropic tools API
- Model Context Protocol (MCP): build a server
- LangGraph: stateful multi-step agent workflows
- Multi-agent: CrewAI or AutoGen for task delegation
- Agent memory: in-context, external (Redis / pgvector)
- Safety: guardrails, timeout logic, cost caps

**Sunday — Project: ClaraPath QC Audit Agent**
- Ingest TapeQC batch results
- Query vector DB for similar past cases
- Run scoring logic, file structured audit report
- Multi-step workflow with human-in-the-loop approval

**Resources:** Anthropic agents guide · LangGraph docs · MCP spec · CrewAI docs

**Deliverables:**
- [ ] Working MCP server (custom tool)
- [ ] LangGraph agent with ≥3 tools
- [ ] Agent trace logs showing reasoning steps
- [ ] Cost cap + timeout guardrails implemented

---

### P4 — LLMOps & Production Systems (3 weekends · May 23 → Jun 7)

**Saturday — Concepts:**
- Evaluation frameworks: RAGAS, Braintrust, LangSmith
- Observability & tracing: Langfuse, Phoenix (Arize)
- Prompt versioning & A/B testing
- vLLM serving & OpenAI-compatible endpoints (run on RTX 6000)
- Fine-tuning: LoRA/QLoRA with your own data (RTX 6000 = 48 GB, fits 70B QLoRA)
- Latency optimization: caching, batching, quantization
- Cost tracking & budget guardrails

**Sunday — Project: LLMOps Dashboard**
- Instrument RAG/agent pipeline with Langfuse
- Weekly RAGAS eval script: faithfulness + relevancy scoring
- Integrate into existing MLflow setup
- vLLM endpoint serving a fine-tuned model

**Resources:** RAGAS docs · Langfuse docs · vLLM docs · Braintrust

**Deliverables:**
- [ ] Langfuse-instrumented pipeline with traces
- [ ] RAGAS eval script (automated, scheduled)
- [ ] vLLM serving endpoint on RTX 6000
- [ ] QLoRA fine-tune on domain-specific data
- [ ] MLflow integration for model versioning

---

### P5 — Multimodal AI & Portfolio (3 weekends · Jun 13 → Jun 28)

**Saturday — Concepts:**
- Vision-language models: GPT-4o, Claude Vision, LLaVA
- Image + text pipelines: describe, classify, extract
- Multimodal RAG: image embeddings (CLIP, SigLIP)
- Med-AI: MedSAM, BioMedCLIP, PathFoundation
- AI code assistants: Claude Code, Cursor, Aider

**Sunday — Project: Visual QC Co-Pilot**
- Send slide images to GPT-4o / Claude Vision with structured prompts
- Compare tissue anomaly descriptions against ClaraQC scoring
- Bridges your CV stack and AI eng stack
- Portfolio-ready: open-source on GitHub

**Resources:** OpenAI Vision guide · CLIP paper · BioMedCLIP · MedSAM GitHub

**Deliverables:**
- [ ] Vision pipeline comparing LLM descriptions vs ClaraQC scores
- [ ] Multimodal RAG prototype (image + text retrieval)
- [ ] 2-3 polished GitHub repos with READMEs
- [ ] Portfolio page or README linking all projects

---

## Cost Estimate

| Service | Phase | Est. Cost |
|---------|-------|-----------|
| Anthropic API (Haiku 4.5) | P1–P5 | ~$5 |
| OpenAI API (embeddings + GPT-4o Vision) | P2, P5 | ~$10–15 |
| Pinecone / Chroma | P2 | Free tier |
| Langfuse / LangSmith | P4 | Free tier |
| Cloud GPU (RunPod, if needed) | P4 | ~$5–10 |
| **Total** | | **~$50–60** |

**$0 path:** Ollama + Chroma + Langfuse self-hosted + RTX 6000 local = entire curriculum for $0.  
**API tip:** Haiku 4.5 for dev/testing. Sonnet only for final demos. Enable prompt caching for 70-80% savings.

---

## GitHub Repository Structure

```
ai-engineer-2026/
├── README.md                  # Overview, links to each phase
├── devlog.md                  # Append-only lab notebook
├── setup.md                   # Environment setup (reproducible)
├── tracker.md                 # Progress scores, weak areas
├── phase1-llm-apis/
│   ├── README.md              # Phase summary + learnings
│   ├── notebooks/             # Exploration notebooks
│   ├── src/                   # Clean scripts
│   ├── prompts/               # Versioned prompt files
│   └── results/               # Outputs, cost logs, screenshots
├── phase2-rag/
│   ├── README.md
│   ├── src/
│   ├── data/                  # Sample docs (no proprietary data)
│   ├── eval/                  # Test queries + retrieval metrics
│   └── results/
├── phase3-agents/
│   ├── README.md
│   ├── src/
│   ├── mcp-server/            # Custom MCP server code
│   └── traces/                # Agent execution logs
├── phase4-llmops/
│   ├── README.md
│   ├── src/
│   ├── eval/                  # RAGAS scripts
│   ├── configs/               # vLLM, LoRA configs
│   └── dashboards/            # Langfuse exports, screenshots
└── phase5-multimodal/
    ├── README.md
    ├── src/
    ├── samples/               # Example images (non-proprietary)
    └── results/
```

**Git workflow:**
- `main` branch = stable, reviewed code
- `phase/X-name` branches for active work
- Tag milestones: `v0.1-p1-complete`, `v0.2-p2-complete`, etc.
- Commit messages: `[P2] add hybrid search with BM25 + dense reranking`
- **Never commit proprietary ClaraPath data** — use synthetic/public samples

---

## Key Notes

- **Proprietary data:** All ClaraPath/TapeQC data stays local. GitHub repos use synthetic or public datasets only.
- **RTX 6000 advantage:** 48 GB VRAM means you can run 70B models locally (Llama 3 70B Q4, Mixtral 8x7B) — skip cloud GPU for most tasks.
- **CUDA_VISIBLE_DEVICES=1:** GPU 1 is less loaded. Default to it for your experiments.
- **Docker:** Containerize each phase's environment for reproducibility.
