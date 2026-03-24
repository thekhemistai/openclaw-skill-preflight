# Skill-Preflight Roadmap

A living document for skill-preflight plugin development. Versioned by semantic releases.

## Current Release: 1.0.0 ✅

**Status:** Stable & Published to clawhub
**Released:** 2026-03-24

### Features
- ✅ Recursive directory scanning (1 level deep) for skills and protocols
- ✅ Local embeddings via nomic-embed-text (Ollama)
- ✅ Cosine similarity ranking
- ✅ Configurable relevance threshold (minScore)
- ✅ Session-level deduplication
- ✅ Pinned docs (always-inject)
- ✅ Content truncation (maxDocLines)
- ✅ Debug logging for score transparency
- ✅ Full documentation & troubleshooting guide

### Known Limitations
- Embedding caching TTL is fixed at 1 hour
- Recursive depth limited to 1 level
- No hot-reload when docs change (requires plugin restart)
- No file watch for new docs during development

---

## Phase 2: Enhanced Caching & Observability (v1.1.0)

**Planned:** Q2 2026
**Priority:** Medium — improves dev experience

### Features
- [ ] **File watching** — Detect new/changed docs without restart
- [ ] **Dynamic cache TTL** — Config option to adjust cache lifetime
- [ ] **Performance metrics** — Log embedding latency per doc
- [ ] **Score distribution** — Debug output showing score distribution (min/max/mean)
- [ ] **Embedding verification** — Simple test command to verify Ollama works: `openclaw preflight-check`

### Why
- Dev workflow improvement: no more waiting for cache to expire to see new skills
- Better observability: understand performance bottlenecks
- Easier troubleshooting: verify setup before hitting issues

### Breaking Changes
None expected. Config-backward compatible.

---

## Phase 3: Advanced Embedding Strategies (v1.2.0)

**Planned:** Q3 2026
**Priority:** Low-Medium — feature expansion

### Features
- [ ] **Multiple embedding models** — Support different nomic variants or other models (e.g., jina, all-minilm)
- [ ] **Reranking** — Optional second-pass ranking with a different model for precision
- [ ] **Semantic grouping** — Cluster docs by topic, allow injection by group
- [ ] **Custom weights** — Weight certain docs higher (e.g., house-rules always top-scored)

### Why
- Users with different hardware can choose appropriate models
- Reranking improves precision for large doc collections
- Grouping enables "inject all security docs" type patterns
- Custom weights provide fine-grained control

### Breaking Changes
New config options, fully backward compatible.

---

## Phase 4: Integration & Ecosystem (v2.0.0)

**Planned:** Q4 2026
**Priority:** Low — ecosystem play

### Features
- [ ] **ClawHub metadata plugin** — Auto-publish skill docs to ClawHub as skills
- [ ] **Vault sync** — Export injected context to Obsidian/external memory systems
- [ ] **Multi-agent coordination** — Share embedding cache across agents in same workspace
- [ ] **Agent marketplace** — Skills as tradeable/discoverable ACP assets
- [ ] **MCP integration** — Expose doc index as MCP resource for other tools

### Why
- Creates a feedback loop: skills → embeddings → marketplace → better skills
- Enables agents to build on each other's docs
- Bridges OpenClaw agents with broader ecosystem
- Sets foundation for autonomous knowledge networks

### Breaking Changes
Potential API changes. Would bump major version.

---

## Maintenance & Support

### Bug Reports
File issues with:
- Reproduction steps
- Config (minScore, maxResults, etc.)
- Relevant logs (enable debug logs)
- OpenClaw version

### Feature Requests
Discuss in Issues before implementation. Check roadmap first to see if it's planned.

### Performance Considerations
- Embedding latency scales with doc count and doc size
- Caching mitigates most of this (1-hour TTL by v1.1)
- For >100 docs, consider reducing maxResults or raising minScore
- Ollama on same machine typically adds 100-300ms per embedding

### Testing Strategy
- Unit tests for scoring algorithm
- Integration tests with real Ollama instance
- E2E tests with OpenClaw agents
- Performance benchmarks for large doc sets (100+, 1000+ docs)

---

## Release Cycle

- **Stable** (@latest on npm): Thoroughly tested, production-ready
- **Pre-release** (@next on npm): Feature branches, published for early testing
- **Development**: Unpublished, local testing only

### Before Each Release
1. Update version in package.json
2. Update SKILL.md with new features
3. Tag git: `git tag v1.x.x`
4. Publish: `npm publish --tag latest` (stable) or `npm publish --tag next` (pre-release)
5. Publish to ClawHub: `clawhub package publish . --source-repo thekhemistai/openclaw-skill-preflight --source-commit <SHA>`

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for development setup and submission guidelines.

## Questions?

Open an issue or check the [troubleshooting guide](./SKILL.md#troubleshooting) in SKILL.md.
