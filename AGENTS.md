# AGENTS.md — Rules for ALL AI coding agents (Codex, Claude Code, Cursor, …)

Hearth is a **fully offline, on-device** iOS translation app for shelter staff and residents.
Privacy is the product. There is no backend. There is no network code. Ever.

## Before any task

1. Read `docs/PRD.md` and `docs/adr/ADRs.md`.
2. Find your task in the current `docs/sprints/sprint-N.md` — implement exactly that scope,
   nothing more.
3. For UI work: read `docs/design/UI-SPEC.md` and view `docs/design/screenshots/translation.png`
   and `landing.png`. The UI must match the spec's tokens, not your taste.

## Hard rules (PRs violating these get closed, not fixed)

1. **No networking.** `URLSession`, `Network.framework`, sockets, analytics SDKs — all banned.
   CI greps for them. The App Store privacy label says "Data Not Collected" and must stay true.
2. **No new dependencies.** Allowed SPM packages: WhisperKit, the llama.cpp Swift package.
   Anything else requires a human-approved ADR change first (ADR-007).
3. **Engine protocols are frozen** (`Hearth/Engines/*/`: `SpeechToText`, `TranslationEngine`,
   `TextToSpeech`). Changing a protocol signature requires an ADR PR approved by two humans.
4. **No persistence of conversation content.** Messages live in memory only (ADR-006).
   `UserDefaults` is allowed only for: onboarding-seen flag, last manual language selection.
5. **`reference/` is read-only.** It holds the React/FastAPI prototype sources as porting specs.
   Never import from it, never edit it, never "modernize" it.
6. **No force-unwraps (`!`)**, no `try!`, no `fatalError` outside precondition checks.
7. Keep PRs ≤ ~400 changed lines. Split larger work.
8. Every feature starts from a spec in `docs/specs/`. If the sprint task lacks detail,
   write the spec first and stop for human review.

## Conventions

- Swift 5.10+, SwiftUI, MVVM with `@Observable` view models. One `Features/<Name>/` folder
  per screen containing `<Name>View.swift` + `<Name>ViewModel.swift`.
- ViewModels depend on engine **protocols**, injected via `init` — never on concrete engines.
  Tests use the `Mock*` engines.
- Async work: `async/await` only. No Combine, no completion handlers.
- UI must use the design tokens from `Hearth/DesignSystem/` (generated from
  `docs/design/UI-SPEC.md`) — never hard-code colors/fonts in views.
- Branch names: `feat/<kebab>`, `fix/<kebab>`, `spike/<kebab>`. Conventional commit messages.
- Device-dependent code (audio, ML inference) must be tested on a physical iPhone by a human
  before merge — say so in the PR description if you could not.

## Build & test

- Build: open `Hearth.xcodeproj` in Xcode, or
  `xcodebuild -scheme Hearth -destination 'platform=iOS Simulator,name=iPhone 16' build`
- Tests: `xcodebuild test -scheme Hearth -destination 'platform=iOS Simulator,name=iPhone 16'`
- Lint: `swiftlint` (config at repo root once Sprint 0 task 0.4 lands).
- Unit tests must run **without model files present** — that's what the `Mock*` engines are for.
  Never write a test that requires the GGUF/CoreML weights.

## Notes for sandboxed/cloud agents (Codex cloud, CI agents)

- You likely **cannot build or run iOS code** in your environment (no Xcode/simulator).
  That is expected: still write the code + tests, state clearly in the PR that you could not
  build, and a human will verify locally. Do not "work around" a missing toolchain by
  restructuring the project, adding SwiftPM-only targets, or stubbing out frameworks.
- Never touch code signing, provisioning, `.entitlements`, or `Info.plist` privacy strings
  unless the task explicitly says so — these are human-owned (see `docs/ROADMAP.md` §5).
- Anything under `Hearth/Resources/Models/` (model weights) is managed by humans; never
  add, remove, or re-reference model files.

## Project map

```
Hearth/App/            entry point, router, device capability check
Hearth/Features/       Landing, Onboarding, Conversation, Settings (View+ViewModel pairs)
Hearth/Engines/        SpeechToText | Translation | TextToSpeech | Safety — protocol + impls + mocks
Hearth/Domain/         Message, Language, SessionPhase, LanguageTier (ported from reference/frontend/types.ts)
Hearth/Audio/          AudioSessionManager (AVAudioSession lifecycle)
Hearth/DesignSystem/   Color/Font/spacing tokens from docs/design/UI-SPEC.md
Hearth/Resources/Models/  bundled whisper-small CoreML + tiny-aya GGUF (human-managed)
```
