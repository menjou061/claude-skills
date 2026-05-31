# knowledge-governance

> Personal decision governance system — 7-gate rule promotion, 6 collection sources, 5 redlines, conversation as L0 interface.

A skill for managing personal decision rules (investing, product work, personal capability) with strict promotion gates and source-of-truth separation.

## Concept

Three matched parts:
- **Obsidian** = single source of truth (narratives, cases, full rule book)
- **CC repo** = governance staging area (rule promotion gates, candidates)
- **Memory** = cross-session continuity (Active Threads, redlines)

## Structure

```
knowledge-governance/
├── SKILL.md                            # Top-level entry
├── docs/
│   ├── PRD.md                          # System purpose & success metrics
│   ├── presets.md                      # 6 collection sources × default actions × override tags
│   ├── conversation-protocol.md        # 4 conversation flow modes + L0-L3 crystallization
│   └── decision-records/
│       ├── 004-rule-promotion-gates.md
│       ├── 005-book-tier-protocol.md
│       ├── 006-handwritten-fast-track.md
│       ├── 007-snippet-collection.md
│       ├── 008-work-artifact-bidirectional.md
│       ├── 009-conversation-as-interface.md
│       └── 099-source-of-truth.md
└── domains/
    ├── trading-discipline/             # Investment decision rules
    ├── product-experience/             # Product work rules
    ├── personal-capability/            # Personal growth rules
    ├── book-digest/                    # Book reading → structured cards
    └── curate/                         # Cross-domain principles + curation
```

Each domain has a `manifest.yaml` defining its role, card types, and inputs/outputs.

## Key Mechanisms

### 7-Gate Rule Promotion (ADR-004 + ADR-006)

Every rule candidate must pass these gates before entering `rules.json`:

| Gate | Name | Judge | Purpose |
|------|------|-------|---------|
| 0 | Metacognition | User self-audit + AI prompting | Evidence, emotion, counterexample, time check, logical closure |
| 1 | Uniqueness | AI | Compare against existing rules + same-batch candidates |
| 2 | Executable | AI | Must have quantifiable check logic |
| 3 | Pain point | AI search + user confirm | Cite specific historical case |
| 4 | Frequency | AI stats | ≥10 = P1 / 3-9 = P2 / <3 = P3 |
| 5 | Tier review | AI suggest + user decide | P1 must have "what's the disaster if violated" |
| 6 | Personal backtest | AI simulate + user decide | ✅ improves / ❌ worsens / ⚪ no change |

### 6 Collection Sources

| Source | Default action | Quota | Override tag |
|--------|---------------|-------|--------------|
| 📚 Book | Full 7-gate | 3-7/book | `[tier=A\|B\|C]` |
| 📝 Review | Attribution + candidates | 1-2/piece | `[mode=attribution-only]` |
| ✋ Handwritten | Fast-track (4 gates) | 1/instance | `[level=P1\|P2\|P3]` |
| 🎙️ Snippet | Add-case preferred | 5/month global | `[mode=new-rule]` |
| 📄 Work artifact | Audit-first | 0-2/piece | `[mode=audit\|extract-only]` |
| 💬 Conversation | L0-L3 crystallization | 3/chat + 5 ADR/month | `[save-as=adr\|rule\|decision]` |

### 5 CC Redlines

Hard constraints on what CC can NOT do:

1. **Default-deny on promotion ambiguity** — Vague words ("OK", "continue", "this is fine") never count as approve
2. **Default-staging on repo role** — CC repo never mirrors source of truth; quota mismatch is normal, not a bug
3. **Default-no-reconstruction on history** — CC never back-fills non-existent historical content
4. **Default-no-write to source-of-truth** — CC never proactively writes Obsidian (or whatever you choose as truth)
5. **No self-granted authority** — CC's own mapping/protocol docs do NOT authorize CC's writes; needs explicit user approval per action

## Installation

This skill is part of the [claude-skills](https://github.com/menjou061/claude-skills) collection.

```bash
ln -s ~/claude-skills/knowledge-governance ~/.claude/skills/knowledge-governance
```

## Adapting to Your Workflow

This skill assumes Obsidian as source of truth, but the principles transfer:
- Swap "Obsidian" for whatever holds your narratives (Notion, Bear, plain markdown folder)
- Swap the 3 domains for whatever you care about (e.g. health-discipline, learning-progress)
- The 7 gates, 6 sources, and 5 redlines are domain-agnostic

The default settings in `docs/presets.md` lean conservative — "minimal disruption" philosophy — so the system protects rule sovereignty over proposal convenience.

## Status

- v1.0.2 (2026-05-31) — first stress test passed: L1/L2/L3 overreach detected, rolled back, redlines upgraded to 5
- ADR-001~003 — established in early oral design, content embedded in PRD.md, not yet standalone
- ADR-010~015 — pending (rule retirement / usage telemetry / scenario retrieve / wiki references / conflict detection / disaster recovery)
