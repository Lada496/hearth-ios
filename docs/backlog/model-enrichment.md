# Model Enrichment Backlog

This plan starts **after** the August internal build and **after** humans approve the target
language directions. It turns the provisional Tiny-Aya Earth translator into an evidence-backed
candidate for each approved language without weakening Hearth's offline or privacy guarantees.

This is a dependency-ordered backlog, not a dated release commitment. Repeat ME-1 through ME-9
for each language direction or closely related group. A result for one language must not be used
to claim support for another. GitHub parent issue
[#37](https://github.com/Lada496/hearth-ios/issues/37) tracks the full sequence.

## 1. Entry gate

Do not start model-enrichment experiments until all of the following exist:

- The August build has completed its offline device baseline.
- Humans have approved the target language and both translation directions to investigate.
- At least two fluent reviewers are committed, or the human decision owner documents an
  exception and an independent adjudication path.
- The data owner has approved permitted sources and licenses.
- The team has named the devices on which performance and memory will be judged.

Target-language selection considers shelter need, Tiny-Aya and Whisper behavior, system TTS
availability, evaluator access, dialect/register coverage, and the cost of maintaining quality.
Language detection helps route a turn at runtime; it does not prove that a detected language is
safe to advertise as supported.

## 2. Rules that continue to apply

1. The shipped app remains fully offline. Training or evaluation tooling must never introduce
   networking, analytics, or remote inference into the iOS target.
2. Do not use resident conversations or production transcripts as training or evaluation data.
   Hearth does not persist them. Any future exception requires separate human consent, data
   governance, and an ADR before collection begins.
3. Do not commit datasets, checkpoints, adapters, or GGUF weights to this repository. Humans
   manage approved model artifacts under `Hearth/Resources/Models/`.
4. Keep the frozen `TranslationEngine` protocol. Prompting, adapters, quantization, and model
   replacement belong behind the existing engine boundary.
5. Do not add ML or data dependencies to the iOS project. Experiment tooling lives outside the
   app target and needs its own reproducible environment and license review.
6. Automatic scores are screening evidence only. Fluent-speaker review and a human decision are
   required before Hearth names a supported language.
7. Preserve a rollback artifact and the previous approved model until the replacement passes
   linguistic, privacy, memory, latency, and stability gates.

## 3. Enrichment sequence

| ID | Work item | Depends on | Owner | Exit artifact |
|---|---|---|---|---|
| [ME-0 / #40](https://github.com/Lada496/hearth-ios/issues/40) | Approve language/direction scope and evaluator roster | August device baseline | Human-only | Approved decision record |
| [ME-1 / #41](https://github.com/Lada496/hearth-ios/issues/41) | Define evaluation rubric, error taxonomy, and thresholds | ME-0 | Human-led | Approved evaluation spec |
| [ME-2 / #42](https://github.com/Lada496/hearth-ios/issues/42) | Build the licensed data inventory and protected splits | ME-0 | Human-owned | Data manifest + train/dev/test IDs |
| [ME-3 / #43](https://github.com/Lada496/hearth-ios/issues/43) | Benchmark unchanged Tiny-Aya Earth | ME-1, ME-2 | Agent-assisted, human-run | Reproducible baseline report |
| [ME-4 / #44](https://github.com/Lada496/hearth-ios/issues/44) | Choose the smallest justified intervention | ME-3 | Human-only | Continue/stop decision per direction |
| [ME-5 / #45](https://github.com/Lada496/hearth-ios/issues/45) | Test prompt, decoding, cleanup, and glossary changes | ME-4 selects it | Agent-assisted | Compared experiment report |
| [ME-6 / #46](https://github.com/Lada496/hearth-ios/issues/46) | Train an adapter only if lighter changes are inadequate | ME-2, ME-5, explicit approval | Human-led | Candidate adapter + training report |
| [ME-7 / #47](https://github.com/Lada496/hearth-ios/issues/47) | Merge, quantize, document, and package the candidate | ME-4 decision + selected ME-3/ME-5/ME-6 result | Human-owned | Candidate GGUF + model card + checksum |
| [ME-8 / #48](https://github.com/Lada496/hearth-ios/issues/48) | Run supported-iPhone regression testing | ME-7 | Human-owned | Device quality/performance report |
| [ME-9 / #49](https://github.com/Lada496/hearth-ios/issues/49) | Run blinded fluent review and decide promotion | ME-7 | Human-only | Accept/reject record per direction |
| [ME-10 / #50](https://github.com/Lada496/hearth-ios/issues/50) | Expose approved support and plan release validation | ME-8, ME-9 both pass | Mixed, human-gated | Product backlog + release decision packet |

ME-1 and ME-2 may run in parallel. ME-8 and ME-9 may run in parallel after packaging. All other
work follows the dependency order above. If ME-4 concludes that the base model cannot meet the
approved need within device limits, stop that language direction instead of forcing a tuning
task through the pipeline.

## 4. ME-1 — Evaluation design

Create the test before changing the model so that experiments cannot redefine success after
seeing results. The approved evaluation spec records:

- exact language directions, dialects, scripts, formality, and code-switching expectations;
- general translation examples plus shelter-domain examples;
- protected holdout sentences that experiment authors cannot tune against;
- critical categories: negation, names, numbers, dates, addresses, medications, directions,
  safety/crisis statements, consent, politeness, and uncertainty;
- instruction-following attacks that check the model translates rather than answering,
  advising, summarizing, or following text embedded in the source;
- error severity: meaning-changing/unsafe, material, minor, and stylistic;
- human scoring instructions, disagreement handling, and pass/stop thresholds; and
- automatic metrics used for screening, with a warning that they are not the promotion gate.

Keep the same protected test set across baseline and candidates. Add new regression examples when
a defect is found, but report results on the original set separately to avoid moving the goal.

## 5. ME-2 — Data and governance

Prefer licensed public data and human-authored, non-personal shelter-domain examples. The data
manifest must record source, license, permitted use, language direction, dialect/register,
collection or generation method, row count, transformations, and reviewer.

Before training or evaluation:

- scan for personal data and remove names or identifiers that are not deliberate test fixtures;
- deduplicate within and across train, development, and test sets;
- prevent test leakage, including paraphrases and translated duplicates;
- balance both translation directions and document known coverage gaps;
- preserve punctuation, numbers, and named-entity examples needed for safety review; and
- pin split identifiers and checksums so every result can be reproduced.

If license, provenance, privacy, or fluent review is unclear, that data stays out.

## 6. ME-3 to ME-6 — Baseline and intervention ladder

First run the unchanged, human-approved Tiny-Aya Earth artifact with the app's real prompt and
cleanup behavior. Record the model checksum, quantization, prompt version, decoding settings,
evaluation-set version, seed where applicable, automatic scores, categorized human errors, and
device-independent latency. This is the baseline every candidate must beat.

ME-4 chooses the smallest intervention supported by the error analysis:

1. Fix prompt structure, language tags, decoding parameters, output cleanup, or glossary handling.
2. Re-run the full baseline comparison, including protected and adversarial examples.
3. Only if the remaining errors are systematic and the approved data is adequate, authorize a
   reproducible supervised adapter experiment such as LoRA/QLoRA.
4. Compare the tuned candidate with both the unchanged baseline and the best lightweight result.
5. Reject candidates that improve averages while worsening critical categories or either
   translation direction beyond the approved threshold.

Every experiment report includes exact inputs, configuration, code revision, artifact hashes,
results by category and direction, known limitations, and a recommendation. Agents may prepare
configs, harnesses, and reports; humans approve data, run controlled training, and interpret
linguistic safety.

## 7. ME-7 — Packaging

Package only the unchanged or enriched candidate selected through ME-4/ME-5/ME-6. The human
model owner:

- merges an approved adapter when applicable and exports the chosen GGUF quantization;
- compares the packaged artifact against the higher-precision candidate for quality loss;
- records filename, exact model/version, tokenizer, prompt template, quantization, size, SHA-256,
  license, attribution, training-data summary, limitations, and intended language directions;
- keeps the prior model available for rollback; and
- places the approved artifact through the repository's human-managed model process.

Changing a model file is not permission to change engine protocols, add a download path, or hide
model/licensing details from Settings attribution.

## 8. ME-8 — On-device gate

Run the packaged candidate on every named supported-device class with the bundled Whisper model
and normal app UI. At minimum record:

- cold model-load time, first-token latency, total translation latency, and output length;
- peak memory while STT and translation are both resident;
- a ten-minute alternating conversation with no crash, jetsam, or unrecoverable state;
- airplane-mode behavior from first launch, app size, thermal observations, and battery notes;
- quality differences introduced by GGUF conversion or quantization; and
- end-session/background-timeout memory cleanup.

The device gate fails if the candidate is linguistically better but cannot run reliably within
Hearth's device, size, offline, or privacy limits.

## 9. ME-9 — Fluent-speaker promotion gate

Reviewers compare the unchanged baseline and candidate without being told which is which. Use the
approved rubric and protected set, capture disagreements, and require adjudication for critical
errors. Exercise both directions and the actual app prompt/output cleanup.

The decision record is per language direction and says **accept**, **revise**, or **stop**, with
evidence and known limitations. It must not include real resident conversations. A passing
automatic score, successful demo, or language-detection result cannot replace this review.

## 10. ME-10 — Product and release follow-through

Only a language direction that passes both ME-8 and ME-9 may enter the supported catalog. Then:

1. Add the approved language metadata and a manual override when its product spec is reviewed.
2. Confirm the system-TTS voice behavior and document text-only fallback where no voice exists.
3. Update onboarding, settings, attribution, support claims, and accessibility tests.
4. Run an external beta plan with consented testers and no analytics or transcript collection.
5. Re-run privacy, offline, device, and regression gates for the release candidate.
6. Let humans choose App Store scope, assets, dates, and the public release decision.

Adding more languages later repeats this backlog. It does not require retraining every language
into one release if separate evidence or device constraints favor a narrower supported set.

## 11. Definition of done

Model enrichment is complete for a language direction only when its provenance and license are
approved, baseline and candidate results are reproducible, critical errors meet the human-set
thresholds, the packaged model passes physical-device gates, fluent reviewers approve it, and a
rollback artifact exists. Until then, the language remains experimental and unmarketed.
