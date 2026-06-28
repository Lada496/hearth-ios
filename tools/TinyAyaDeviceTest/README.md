# TinyAyaDeviceTest

Temporary Sprint 0 iOS app for issue #1 Tiny-Aya latency and Tiny-Aya-only memory smoke tests.
This can also become the shared device harness for issue #2 WhisperKit testing.

This app is based on the official llama.cpp SwiftUI example, trimmed for Hearth's offline
Tiny-Aya Earth test. It has no model download UI and should be run on a physical iPhone.

## What You Need

- Xcode
- A supported physical iPhone per `docs/PRD.md` §6 and `docs/adr/ADRs.md` ADR-005
- `tiny-aya-earth-q4_k_m.gguf`
- `llama.xcframework` built from llama.cpp

Do not commit the GGUF model or generated framework.

## Add The Model

Put the model here:

```text
tools/TinyAyaDeviceTest/llama.swiftui/Resources/models/tiny-aya-earth-q4_k_m.gguf
```

Expected SHA256:

```text
01ecc5d1195a21a9e3e2efa4f4b7c547502a58efda8d38b80646823b56d383c4
```

## Add llama.xcframework

Build `llama.xcframework` from llama.cpp, then put it here:

```text
tools/TinyAyaDeviceTest/build-apple/llama.xcframework
```

The Xcode project already points at that path.

## Run

### Install On iPhone

1. On the Mac, open Xcode.
2. In Xcode, open `tools/TinyAyaDeviceTest/llama.swiftui.xcodeproj`.
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
14. If the app does not open automatically, unlock the iPhone and tap the app icon.

### Test 4: Latency

1. Confirm the app is installed and open on the iPhone.
2. Open Control Center on the iPhone.
3. Turn on airplane mode.
4. Confirm Wi-Fi and cellular are off.
5. Return to the app.
6. Tap `Load Model`.
7. Wait until the app says the model is loaded.
8. Write down the model load time shown by the app.
9. Confirm the prompt box contains:

```text
You are a translator. Output ONLY the English translation of the text below. Do not explain, do not add notes, do not repeat the original. If the text is already in English, output it unchanged.

Ninahitaji msaada kupata makazi usiku wa leo.
```

10. Tap `Run Translation`.
11. Wait for the translation to finish.
12. Write down first token latency, total generation time, tokens/sec, and whether the app froze,
    crashed, or was killed.
13. Run the same prompt two more times.
14. Write down the same timing numbers for run 2 and run 3.

Pass target:

- Translation visible within 15 seconds on the minimum supported device.
- Translation visible within 8 seconds on iPhone 15 Pro or better.

### Test 5: Tiny-Aya-Only Memory Smoke Test

This does not complete the full WhisperKit + Tiny-Aya memory test. Coordinate that combined
test with issue #2 after WhisperKit small is available.

1. Keep the iPhone connected to the Mac.
2. Keep the app running from Xcode.
3. In Xcode, open the memory/debug area.
4. Find the app's current memory usage number.
5. Write down the starting memory usage.
6. In the app, load Tiny-Aya Earth if it is not already loaded.
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

## Extension For Issue #2

Issue #2 is the WhisperKit spike. If Jianding wants to reuse this app, keep the existing
Tiny-Aya screen and add a small WhisperKit section below it.

Suggested additions:

1. Add WhisperKit as the only new package dependency for this test harness.
2. Add a `Load Whisper small` button.
3. Show Whisper load time.
4. Add a simple `Record` / `Stop` flow, or a way to run bundled test audio clips.
5. Show transcript text.
6. Show detected language code.
7. Show detection confidence if WhisperKit exposes it.
8. Show STT processing time.
9. Show current or peak memory while Whisper is loaded.

For the combined memory test:

1. Load WhisperKit `small`.
2. Load Tiny-Aya Earth Q4_K_M.
3. Run a 10-minute simulated session.
4. Record peak memory.
5. Record whether the app crashed, froze, or was killed by iOS.
6. Copy the result into both `docs/specs/aya-spike.md` and the issue #2 Whisper spike doc.

Keep this harness offline-only. Do not add networking, analytics, crash SDKs, or extra packages.
