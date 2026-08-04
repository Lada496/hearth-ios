# Conversation ViewModel Specification

**Status:** ready for implementation · **Sprint task:** 2.5 · **Issue:** #9

This is the canonical behavior contract for `ConversationViewModel`. It replaces the original
web prototype state machine as an implementation source. The frozen engine protocols, PRD,
ADRs, and approved August flows take precedence if an older prototype behavior conflicts.

## Scope

Task 2.5 implements the in-memory conversation state and unit tests against `MockSTT`,
`MockTranslator`, and `MockTTS`. It does not implement audio capture, a concrete model adapter,
session timeout, persistence, a language picker, or any supported-language catalog.

The ViewModel is `@MainActor`, uses `@Observable`, and receives only engine protocols through
its initializer. Views receive state and invoke intent methods; they never call engines.

## Observable state

- `messages: [Message]`, initially empty and stored in memory only.
- `phase: SessionPhase`, initially `.idle`.
- `residentLanguage: Language?`, initially absent. It is session metadata, not a launch claim.
- `errorMessage: String?`, initially absent and safe to display.
- `playingMessageID: UUID?`, initially absent, so the UI can identify replay activity.

The worker language for the August build is English. Supply it through composition or a private
constant; do not introduce a production language catalog.

## Global concurrency rules

1. A new turn, recording action, or replay may start only while `phase == .idle`.
2. While any operation is active, other input is ignored rather than queued.
3. An end/stop recording intent is accepted only for the speaker that started the recording.
4. Starting a valid operation clears the previous recoverable error.
5. Every asynchronous path returns to `.idle`, including empty transcription and failure.
6. A failed operation never appends a partial message or deletes earlier messages.

## Typed turn

1. Trim whitespace and newlines. Empty input is a no-op: no engine call, error, or phase change.
2. Resolve the language pair before calling the translator:
   - resident: known `residentLanguage` → English;
   - worker: English → known `residentLanguage`.
3. If `residentLanguage` is unavailable, do not call the translator. Show a readable error
   explaining that the resident must speak first so their language can be detected. Debug and
   test composition may inject a fixture language; production UI must not expose it as supported.
4. Set `.translating(speaker)`, call `TranslationEngine.translate`, and append one `Message` only
   after translation succeeds.
5. The message stores trimmed original text, translated text, speaker, both runtime languages,
   a generated ID, and the current timestamp.

## Simulated and recorded voice turn

Sprint 2 may drive these transitions with injected preview/test callbacks. Later audio work
supplies the `AudioBuffer` without changing the engine protocols.

1. Beginning a valid recording sets `.recording(speaker)`.
2. Finishing the matching recording sets `.transcribing(speaker)` and calls `SpeechToText`.
3. A blank transcription returns to `.idle` without translation or a message.
4. A resident transcription must include detected language metadata. Store it in
   `residentLanguage` before translation. If detection is absent, show a recoverable error and
   do not guess a language.
5. A worker transcription uses English as its source and requires an existing
   `residentLanguage` as its target.
6. Set `.translating(speaker)`, translate, and append exactly one complete message on success.

## Replay and text fallback

Replay is viewer-relative because each pane presents the same turn from a different perspective.

- If the viewer is the message speaker, replay the original text in the source language.
- Otherwise replay the translated text in the target language.
- Call `TextToSpeech.supports` before playback. When unsupported, do not call `speak`; keep the
  large translated text visible and expose the text-only state to the view.
- When supported, set `playingMessageID`, set `.speaking(message.speaker)`, await `speak`, then
  clear the ID and return to `.idle` whether playback succeeds or fails.
- A playback failure is recoverable and does not alter messages or session language.

## Errors and clearing

Map engine errors to concise user-facing copy; do not expose framework or model internals.
`dismissError()` clears only `errorMessage`. Clearing the conversation removes messages,
resident-language metadata, replay state, and any error, stops TTS, and restores `.idle`.
The five-minute background wipe and confirmation UI are implemented under Sprint 3 task 3.5.

## Required unit tests

- Initial state is empty and idle.
- Whitespace-only typed input is ignored.
- Busy-state input and mismatched recording stop are ignored.
- A worker turn without resident language fails before translation.
- Resident voice detection becomes session language and uses the correct translation pair.
- Resident and worker typed turns use the correct injected languages.
- Successful translation appends one complete message and returns to idle.
- STT or translation failure retains earlier messages, exposes readable error, and returns idle.
- Blank transcription does not call translation.
- Replay chooses viewer-relative text/language and serializes playback.
- Unsupported TTS produces text fallback without calling `speak`.
- Dismiss and clear operations affect only the state described above.

## Visual references

- `docs/design/august-ui/flow-02-conversation-turn.png`
- `docs/design/august-ui/flow-03-recovery-privacy.png`
- `docs/design/UI-SPEC.md`
