# Tiny-Aya Device Test Kit

Purpose: complete issue #1 Tiny-Aya latency and Tiny-Aya-only memory smoke checks on a
supported physical iPhone.

Tester needs:

- A supported physical iPhone per `docs/PRD.md` §6 and `docs/adr/ADRs.md` ADR-005.
- Xcode on a Mac.
- The Hearth repo.
- The official `tiny-aya-earth-q4_k_m.gguf` model file.
- The `TinyAyaDeviceTest` app in `tools/TinyAyaDeviceTest/`.

Do not commit model files to the repo.

Important: the repo now includes the `TinyAyaDeviceTest` scaffold at `tools/TinyAyaDeviceTest/`.
Before running it, follow `tools/TinyAyaDeviceTest/README.md` to add the local-only model file
and `llama.xcframework`.

## Install The Test App

Goal: put the Tiny-Aya test build onto the physical iPhone.

Steps:

1. On the Mac, open Xcode.
2. In Xcode, open the `TinyAyaDeviceTest` project or branch.
3. Connect the iPhone to the Mac with a cable.
4. If the iPhone asks whether to trust this computer, tap `Trust`.
5. If the Mac asks for the iPhone passcode, enter it on the iPhone.
6. In Xcode's top device selector, choose the connected iPhone. Do not choose a simulator.
7. In Xcode's project settings, open `Signing & Capabilities`.
8. Choose the team's Apple developer account or personal Apple account for signing.
9. If Xcode shows a signing error, ask the iOS owner for help before continuing.
10. Press Xcode's Run button.
11. Wait while Xcode builds the app.
12. Xcode installs the app onto the iPhone.
13. The app should open on the iPhone automatically.
14. If the app does not open automatically, unlock the iPhone and tap the test app icon.

## Test 4: Latency

Goal: prove Tiny-Aya Earth can run on a supported iPhone within PRD latency targets.

Steps:

1. Confirm the test app is installed and open on the iPhone.
2. Open Control Center on the iPhone.
3. Turn on airplane mode.
4. Confirm Wi-Fi and cellular are off.
5. Return to the test app.
6. In the test app, tap the button or control that loads `tiny-aya-earth-q4_k_m.gguf`.
7. Wait until the app says the model is loaded.
8. Write down the model load time shown by the app.
9. Copy or type this prompt into the test app:

```text
You are a translator. Output ONLY the English translation of the text below. Do not explain, do not add notes, do not repeat the original. If the text is already in English, output it unchanged.

Ninahitaji msaada kupata makazi usiku wa leo.
```

10. Tap the app's `Run`, `Translate`, or equivalent button.
11. Wait for the translation to finish.
12. Write down:
    - first token latency
    - total generation time
    - tokens per second
    - whether the app froze, crashed, or was killed
13. Run the same prompt two more times.
14. Write down the same timing numbers for run 2 and run 3.
15. If the app crashes, freezes, or disappears, write that down and stop the test.

Pass target:

- Translation visible within 15 seconds on the minimum supported device.
- Translation visible within 8 seconds on iPhone 15 Pro or better.

## Test 5: Tiny-Aya-Only Memory Smoke Test

Goal: prove Tiny-Aya Earth alone does not crash or get killed for memory.

This does not complete the full WhisperKit + Tiny-Aya coexistence test. Coordinate that combined
test with issue #2 after WhisperKit small is available.

Steps:

1. Keep the iPhone connected to the Mac.
2. Keep the test app running from Xcode.
3. In Xcode, open the memory/debug area.
4. Find the app's current memory usage number.
5. Write down the starting memory usage.
6. In the test app, load Tiny-Aya Earth if it is not already loaded.
7. Write `Whisper included in this run: no`.
8. Run the same translation prompt once.
9. Wait about 30 seconds.
10. Repeat until you have run the prompt 10 times total.
11. Keep the app open until at least 10 minutes have passed since the start of the memory test.
12. Watch whether the app crashes, freezes, or disappears.
13. In Xcode, record the highest memory usage you saw.
14. If the app crashes, freezes, or disappears, write that down.

Pass target:

- No crash.
- No jetsam / OS memory kill.
- Peak memory leaves plausible headroom for later WhisperKit coexistence testing.

## Combined Memory Test With Issue #2

This is not required before issue #1 can record the Tiny-Aya-only smoke result.

When Jianding's WhisperKit spike from issue #2 is available, coordinate a combined run:

1. Use a supported physical iPhone.
2. Install the WhisperKit test build or Hearth branch from issue #2.
3. Install or run `TinyAyaDeviceTest` on the same device.
4. Load WhisperKit `small`.
5. Load Tiny-Aya Earth Q4_K_M.
6. Run a 10-minute simulated session.
7. Record peak memory.
8. Record whether the app crashed, froze, or was killed by iOS.
9. Copy the result into both `docs/specs/aya-spike.md` and the issue #2 Whisper spike doc.

## Result Template

Copy this into `docs/specs/aya-spike.md` when finished.

```text
Device:
iOS:
Test date:
Tester:
App/branch/commit:
Model file:
Model SHA256:

Latency:
- Load time:
- First token latency, run 1 / 2 / 3:
- Total generation time, run 1 / 2 / 3:
- Tokens/sec, run 1 / 2 / 3:
- PASS/FAIL:

Tiny-Aya-only memory:
- Whisper included: no
- Peak memory:
- 10-minute run completed: yes/no
- Crash/jetsam: yes/no
- PASS/FAIL:

Combined memory with issue #2:
- Owner:
- Status: pending / complete
- Result:

Notes:
```
