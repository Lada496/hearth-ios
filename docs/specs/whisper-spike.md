# WhisperKit STT Spike

Status: in progress. Owner: C (Speech & Audio).
Sprint task: `docs/sprints/sprint-0.md` task 0.2

## Goal

Confirm on-device WhisperKit `small` (a) transcribes and (b) detects language, in airplane
mode, for the launch languages — and record `small` vs `base` accuracy, load time, and memory.
Validates ADR-002.

## Setup

| Item | Value |
|---|---|
| Harness | `tools/TinyAyaDeviceTest` (WhisperKit STT section, issue #2) — branch `spike/whisper-tts-audit` |
| Test device(s) | TODO (note RAM — e.g. iPhone 12 mini / 4 GB) |
| WhisperKit version | TODO |
| Model(s) | `small` (primary), `base` (comparison) |
| Airplane mode | TODO (confirm on/off per run) |
| Clip source | TODO (Common Voice / team recordings — Common Voice clips ship a reference sentence) |
| Input path | Bundled clips (accuracy). Live-mic capture (sprint 0.2 "hold button → record") — see Open items |

> Device note: a 4 GB phone (12 mini) is *below* the ADR-005 floor. STT **accuracy** results are
> still valid there (Whisper alone fits, accuracy isn't RAM-bound), but **memory/latency** figures
> are not the floor benchmark — record those on a 6 GB device.

## Status log

- **2026-07-04 — functional check PASSED (simulator).** iPhone 17 sim, iOS 26.5: `test_en`
  ("I need help finding shelter tonight") transcribed exactly, detected `en`. Load 33.6 s /
  STT 6.2 s — simulator is CPU-only CoreML; timings are NOT representative, accuracy tables
  below must come from real devices.

## STT accuracy (`small`)

| Lang | Tier | Reference text | Whisper transcript | Detected code | Match? | Notes |
|---|---|---|---|---|---|---|
| en | 1 |  |  |  |  |  |
| ar | 1 |  |  |  |  |  |
| zh | 1 |  |  |  |  |  |
| ja | 1 |  |  |  |  |  |
| sw | 2 |  |  |  |  |  |
| ha | 2 |  |  |  |  |  |
| am | 2 |  |  |  |  |  |
| so | — | *not tested* | — | — | — | dropped: Tiny-Aya Earth does not cover Somali (ADR-003 / PR #14); PRD §3 still lists it as a candidate — needs updating |

## `small` vs `base`

| Lang | `small` accuracy | `base` accuracy | Notes |
|---|---|---|---|
|  |  |  |  |

## Performance

| Metric | small | base | Device |
|---|---|---|---|
| Cold load time |  |  |  |
| Warm load time |  |  |  |
| Per-clip transcribe latency |  |  |  |
| Peak memory |  |  |  |

## Language-detection reliability

TODO — how often is the detected code wrong? (feeds the "set language manually" affordance).
Watch short (<1 s) clips and low-resource languages.

## Verdict per language

| Lang | STT usable? (yes / marginal / no) | Reason |
|---|---|---|
|  |  |  |

## Open items

- [ ] Memory/latency on a 6 GB floor device
- [ ] Bundling the model for offline-from-first-launch (ADR-008) — spike downloads on first run
- [ ] Live-mic capture path (hold-to-record per sprint 0.2) — clips prove accuracy first; mic
      plumbing is the Sprint 1/2 `AudioSessionManager` work
- [ ] PRD §3 still lists Somali as a Tier 2 candidate — propose removal (Earth coverage)
