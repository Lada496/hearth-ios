# reference/ — prototype sources (READ-ONLY)

Selected files from the [youCode 2026 hackathon prototype](https://github.com/jasmine-pyz/youCode2026),
kept here so humans and AI agents can port from them without leaving this repo.

**Rules (also in /CLAUDE.md):** never edit, import, or execute anything in this folder.
These files are *specifications*, not code to reuse.

| File | What to port from it |
|---|---|
| `frontend/types.ts` | Domain model → `Hearth/Domain/` |
| `frontend/hooks.ts` | `useConversation` state machine → `ConversationViewModel` |
| `frontend/lib/hearth-translation-service.ts` | Session-language logic, language/flag maps |
| `frontend/app/*` + `frontend/components/*` (+ `.module.css`) | UI structure & exact styling — see `docs/design/UI-SPEC.md` |
| `backend/main.py` | Translation prompts + output-cleaning (lines 81–146) → `TinyAyaEngine` |
| `backend/aggression.py` | Optional v1-stretch SafetyFilter keyword list |

Not copied (cut from v1): transcript store/overlay, support prompt content, region picker,
Twilio notify, Next.js API routes, `translation-service.ts` (unused scaffold).
