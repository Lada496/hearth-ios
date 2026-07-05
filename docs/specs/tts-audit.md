# TTS Voice Audit

Status: in progress. Owner: C (Speech & Audio).
Sprint task: `docs/sprints/sprint-0.md` task 0.3

## Goal

Enumerate which launch languages have usable iOS TTS voices, to lock the Tier 1 (spoken) vs
Tier 2 (large-type) split and update PRD §3.

## Setup

| Item | Value |
|---|---|
| Device(s) + iOS version | TODO (test iOS 17 and latest) |
| Method | `AVSpeechSynthesisVoice.speechVoices()` dump + Settings → Accessibility → Spoken Content → Voices |

## Voice inventory

Quality: `.default` = compact/robotic, `.enhanced` / `.premium` = natural.

| Lang | Voice exists at all? | Installed by default? | Downloadable? | Best quality | Playback verdict |
|---|---|---|---|---|---|
| en |  |  |  |  |  |
| ar |  |  |  |  |  |
| zh |  |  |  |  |  |
| ja |  |  |  |  |  |
| sw |  |  |  |  |  |
| ha |  |  |  |  |  |
| am |  |  |  |  |  |

> Somali (so) intentionally absent: dropped as a candidate — Tiny-Aya Earth does not cover it
> (ADR-003 / PR #14). PRD §3 still lists it; removal proposed via task 0.2/0.3 findings.

> `speechVoices()` returns only *installed* voices — cross-check the Settings download list before
> concluding "no voice." Enhanced/premium voices can't be bundled or downloaded programmatically
> (user/provisioning only).

## Tier assignment

| Lang | Tier 1 (spoken) / Tier 2 (large-type) | Basis |
|---|---|---|
| ar |  |  |
| zh |  |  |
| ja |  |  |
| sw |  |  |
| ha |  |  |
| am |  |  |

## Proposed PRD §3 update

TODO — final Tier 1 / Tier 2 split, once STT (0.2) also confirms these languages are usable.

## Notes

- Enhanced-voice availability per device / provisioning implication.
- Any language-code (BCP-47) matching quirks.
