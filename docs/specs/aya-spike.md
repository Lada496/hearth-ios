# Tiny-Aya Earth Spike

Status: provisional implementation decision. Human validation still required.

Planning note (2026-07-19): tier and candidate-language references below record the original
spike context. The current August plan defers final language selection; see `../PRD.md`.

Issue: https://github.com/Lada496/hearth-ios/issues/1

Sprint task: `docs/sprints/sprint-0.md` task 0.1

## Decision

Proceed with this implementation plan:

- Use Tiny-Aya Earth as the single translation engine for v1.
- Keep Tier 1 languages for testing/demo, but do not optimize model choice around them.
- Keep Apple Translation only as a fallback if Tiny-Aya Earth fails device/performance gates.
- Do not run a team-led quality bake-off now.

Reasoning:

- Hearth's main product value is African-language support.
- The team does not currently have fluent reviewers for the target African languages.
- Tier 1 languages are mainly for app testing and demo, so a full Tier 1 quality bake-off is
  not worth the time right now.
- Apple Translation worked in Airplane Mode only after language assets were downloaded/prepared;
  fresh Airplane Mode without downloaded assets failed, so it does not satisfy Hearth's
  offline-from-first-launch goal as the planned v1 path.
- Published Tiny-Aya benchmark/model-card evidence is enough to justify building a prototype,
  but not enough to claim final quality.

Quality status:

- Tiny-Aya Earth quality is `provisionally accepted for implementation`.
- Tiny-Aya Earth quality is still `not validated with target users`.
- Real validation should happen after the app is usable, through TestFlight or field testing
  with fluent speakers.

## Model Choice

Use `CohereLabs/tiny-aya-earth` instead of `CohereLabs/tiny-aya-global`.

Why:

- Tiny-Aya Earth is positioned for West Asian and African languages.
- That matches Hearth's main differentiation better than the Global variant.
- Shipping one Tiny-Aya model keeps app size and memory risk lower than bundling multiple
  variants.

Model facts to record:

| Item | Value |
|---|---|
| Repository | `CohereLabs/tiny-aya-earth` |
| Model | `tiny-aya-it-earth` |
| Parameter count | 3.35B |
| Architecture | `cohere2` |
| Source weights | BF16 |
| License | CC-BY-NC 4.0 plus Cohere Labs Acceptable Use Policy |

Sources:

- https://huggingface.co/CohereLabs/tiny-aya-earth
- https://huggingface.co/CohereLabs/tiny-aya-earth-GGUF
- https://cohere.com/cohere-labs-cc-by-nc-license
- https://docs.cohere.com/docs/cohere-labs-acceptable-use-policy

## Remaining Checks

Before closing issue #1, humans still need to confirm:

| Check | Status |
|---|---|
| License is acceptable for Hearth's free, non-commercial App Store distribution | PASS — human confirmed CC-BY-NC 4.0/AUP is acceptable for Hearth's free, non-commercial app with attribution |
| Tiny-Aya Earth can be converted to GGUF and quantized to Q4_K_M | PASS — Cohere provides official public GGUF artifacts, including Q4_K_M, in `CohereLabs/tiny-aya-earth-GGUF`; local BF16 conversion was not run because the source model files are gated |
| Quantized model size fits the app budget | PASS — official Q4_K_M GGUF is 2,143,977,056 bytes / about 2.0 GiB; with Whisper `small` at about 500 MB, projected model payload is about 2.65 GB, under the 3.5 GB app-size target before app overhead |
| Model runs on a supported physical iPhone within PRD latency targets | PASS — see Device Test Result below; 3/3 runs in airplane mode on iPhone 16 Pro Max, well within the 8 s Pro-tier target, confirming full offline latency compliance |
| Tiny-Aya-only memory smoke test is stable on a supported physical iPhone | PASS — see Device Test Result below; 10 runs over 10+ minutes on iPhone 16 Pro Max, peak 274.7 MB, flat memory profile, no crash/jetsam |
| Combined WhisperKit + Tiny-Aya memory test has an owner | TODO — coordinate with issue #2; use `TinyAyaDeviceTest` for the Tiny-Aya side once WhisperKit small is available |
| Apple Translation can work offline in the app path for Tier 1/demo languages | PASS WITH LIMITATION — works in Airplane Mode only after language assets are downloaded/prepared; fresh Airplane Mode without downloaded assets fails; use only as fallback, not planned v1 path |
| Fluent-speaker validation plan exists for TestFlight / field testing | TODO |

## Device Test Result (2026-07-25)

Both Test 4 (latency) and Test 5 (Tiny-Aya-only memory smoke test) complete and passing.

Two passes were run: an initial online pass, then a proper 3-run pass in airplane mode (the
protocol Test 4 actually calls for). The airplane-mode numbers below are the ones that count —
they confirm Tiny-Aya's offline-from-first-launch behavior, per PRD §"Offline" and ADR-008.

```text
Device: Steph's iPhone 16 Pro Max
iOS: 26.5.2
Test date: 2026-07-25
Tester: Stephanie Xue
App/branch/commit: TinyAyaDeviceTest, docs/tiny-aya-device-test-results @ fcb0253
Model file: tiny-aya-earth-q4_k_m.gguf
Model SHA256: 01ecc5d1195a21a9e3e2efa4f4b7c547502a58efda8d38b80646823b56d383c4
Airplane mode: on (confirmed via Control Center + status bar airplane icon)

Latency (airplane mode, 3 runs):
- Load time: 0.578 s (same load reused for all 3 runs)
- First token latency, run 1 / 2 / 3: 0.605 s / 0.515 s / 0.522 s
- Total generation time, run 1 / 2 / 3: 1.151 s / 1.116 s / 1.077 s
- Tokens/sec, run 1 / 2 / 3: 8.69 / 8.96 / 9.28
- Generated translation, all 3 runs: "I need help finding a place to stay tonight." (correct,
  identical across runs)
- Crash/freeze/kill: none
- PASS/FAIL: PASS (all 3 runs well within the 8 s iPhone 15 Pro+ target, fully offline)

For reference, an earlier online-only pass (Wi-Fi/cellular on) showed closely matching
numbers: load 0.390 s, first token 0.477 s, total gen 0.981 s, 10.19 tok/s — confirming no
meaningful difference between online and offline behavior for Tiny-Aya, as expected for a
fully local `.gguf` model.

Tiny-Aya-only memory:
- Whisper included: no
- Memory per run (MB), runs 1–10: 274.5 / 274.6 / 274.7 / 274.7 / 274.6 / 274.6 / 274.1 / 274.3 /
  274.3 / 274.3
- Peak memory: 274.7 MB
- 10-minute run completed: yes
- Crash/jetsam: none — all 10 runs completed, no crash, freeze, or kill
- PASS/FAIL: PASS (memory stayed flat within a ~0.6 MB band across 10 runs over 10+ minutes, no
  instability)
```

## Conversion Notes

Preferred artifact: use Cohere's official public GGUF repo:

- `CohereLabs/tiny-aya-earth-GGUF`
- Revision: `be0b513fa757880688c48aa688742729c19c09df`
- Last modified: 2026-02-17
- File: `tiny-aya-earth-q4_k_m.gguf`
- Size: 2,143,977,056 bytes
- SHA256: `01ecc5d1195a21a9e3e2efa4f4b7c547502a58efda8d38b80646823b56d383c4`

Local verification was performed in `/private/tmp`; the model file was not added to this repo.

If the team later needs a reproducible local conversion from source weights, run outside the
app repo after accepting the gated Hugging Face model terms:

```sh
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
python3 -m pip install -r requirements.txt
python3 convert_hf_to_gguf.py CohereLabs/tiny-aya-earth --outfile tiny-aya-earth-f16.gguf
./llama-quantize tiny-aya-earth-f16.gguf tiny-aya-earth-q4_k_m.gguf Q4_K_M
```

Record:

| Artifact | Value |
|---|---|
| Official GGUF repo revision | `be0b513fa757880688c48aa688742729c19c09df` |
| Source model revision | TODO if local conversion is later required |
| F16 GGUF size | TODO if local conversion is later required |
| Q4_K_M GGUF size | 2,143,977,056 bytes |
| Q4_K_M SHA256 | `01ecc5d1195a21a9e3e2efa4f4b7c547502a58efda8d38b80646823b56d383c4` |

Do not commit model files to this repo.

## Implementation Prompt

This section is the canonical prompt and output-cleanup contract for `TinyAyaEngine`.

Prompt:

```text
You are a translator. Output ONLY the {target_lang} translation of the text below. Do not explain, do not add notes, do not repeat the original. If the text is already in {target_lang}, output it unchanged.

{text}
```

Cleanup:

- Trim surrounding whitespace.
- Strip the first matching leading label case-insensitively: `{target_lang} translation:`,
  `{target_lang}:`, `Translation:`, `Answer:`, `Text:`, `Translated text:`, `Output:`, or
  `Result:`. Trim again after removing the label.
- If the model returns alternatives separated by `" or "`, use the first alternative.

## ADR Impact

ADR-003 should say:

- Hearth uses Tiny-Aya Earth as the single v1 translation engine.
- Tier 1 languages are for testing/demo and are not the model-choice driver.
- Apple Translation remains a fallback only if Tiny-Aya Earth fails device/performance gates.
- African-language quality is provisional until validated with fluent speakers.
