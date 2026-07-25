<h1 align="center">Hearth iOS</h1>

<p align="center">
  <img src="docs/design/screenshots/hearth-logo.png" alt="Hearth logo" width="400"/>
</p>

<p align="center"><b>A multilingual communication tool that leaves no one behind.</b><br>
Fully on-device, privacy-first, two-way voice translation for shelter staff and residents.</p>

Native Swift/SwiftUI rewrite of the award-winning
[youCode 2026 hackathon prototype](https://github.com/jasmine-pyz/youCode2026)
(🏆 1st Place CWI Experienced Stream · 🥇 Diversity in CS Project Hub Winner).

## Status

**UI-first development.** Target: installable internal build by August 31, 2026. Final
languages, translation-quality validation, and the public release date are still to be decided.

## Start here

| Doc | Purpose |
|---|---|
| [`docs/PRD.md`](docs/PRD.md) | What v1 is — and explicitly is not |
| [`docs/adr/ADRs.md`](docs/adr/ADRs.md) | The 8 architecture decisions (guardrails for humans **and** AI agents) |
| [`docs/ROADMAP.md`](docs/ROADMAP.md) | Current dependency order, team structure, schedule, and risks |
| [`docs/design/UI-SPEC.md`](docs/design/UI-SPEC.md) | Exact design tokens + per-screen specs to replicate the prototype UI |
| [`docs/sprints/`](docs/sprints/) | Sprint-by-sprint task lists with acceptance criteria |
| [`AGENTS.md`](AGENTS.md) | Rules for ALL AI coding agents (Codex, Claude Code, Cursor) — single source of truth |

## Working with AI agents

Codex reads `AGENTS.md` automatically; Claude Code reads `CLAUDE.md`, which points to it —
so both tools follow the same rules. Every implementation task should start from a sprint
file. Standard prompt (works for either tool):

> Read `AGENTS.md`, `docs/PRD.md`, `docs/adr/ADRs.md`, and `docs/sprints/sprint-N.md`.
> For UI tasks also read `docs/design/UI-SPEC.md` and look at `docs/design/screenshots/`.
> Implement task N.M. Do not add dependencies or change the engine protocols.

Cloud agents (Codex web) usually can't run Xcode — they write code + tests and a human
builds and device-tests before merge (see "Notes for sandboxed/cloud agents" in `AGENTS.md`).

`reference/` contains the prototype source files we port from — **read-only**: agents may
read them as specs but must never import, copy verbatim, or "fix" them.

## Team

Jasmine Zou · Jianding Bai · Yuko Murayama · Stephanie Xue

## Decisions already made (do not re-litigate in PRs)

- 100% on-device, zero network, zero backend — the FastAPI server is deleted, not ported
- STT: WhisperKit (`small`) · MT: one Tiny Aya GGUF via llama.cpp (fallback: Apple Translation) · TTS: AVSpeechSynthesizer
- SwiftUI + MVVM · iOS 17+ · devices with ≥6 GB RAM (iPhone 12 Pro / iPhone 14 and newer)
- Final language support and model accuracy are post-August validation decisions, not UI or
  engine-integration blockers
- Cut from v1: transcript history, support prompts, region picker, SMS alerts, accounts, analytics
