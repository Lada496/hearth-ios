"""
HearTh Backend

Whisper:  local (STT + language detection)
Aya:      HuggingFace Inference API (translation only)

Endpoints:
  GET  /health                — sanity check
  POST /process               — Whisper STT → transcript + detected language
  POST /detect-and-translate  — Aya: translate resident text to English
  POST /translate             — Aya: translate English to resident's language
"""

from fastapi import FastAPI, HTTPException, Request, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from huggingface_hub import InferenceClient
import os, json, pathlib, re, tempfile
import whisper
from dotenv import load_dotenv
import httpx


from .aggression import check_aggression
from .notify import send_sms_alert

# flake8:noqa
# ─── App ──────────────────────────────────────────────────────────────────────


load_dotenv()
app = FastAPI(title="HearTh", version="1.0.0")
app.add_middleware(
    CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"]
)

FRONTEND_DIR = pathlib.Path(__file__).parent.parent.parent / "frontend"

MODELS = {
    "global": "CohereLabs/tiny-aya-global",
    "earth": "CohereLabs/tiny-aya-earth",
    "fire": "CohereLabs/tiny-aya-fire",
    "water": "CohereLabs/tiny-aya-water",
}

# ─── Whisper (local) ──────────────────────────────────────────────────────────

print("[HearTh] Loading Whisper small...")
whisper_model = whisper.load_model("small")
print("[HearTh] Whisper ready.")

# ─── Request models ───────────────────────────────────────────────────────────


class DetectAndTranslateRequest(BaseModel):
    text: str
    model_key: str = "global"
    detected_language_code: str = "und"  # from Whisper, or "und" for text input
    detected_language_name: str = "Unknown"  # from Whisper, or "Unknown" for text input


class TranslateRequest(BaseModel):
    text: str
    model_key: str = "global"
    target_lang: str = "English"


# ─── Helpers ──────────────────────────────────────────────────────────────────


def get_token(request: Request) -> str:
    token = request.headers.get("X-HF-Token") or os.environ.get("HF_TOKEN", "")
    if not token:
        raise HTTPException(
            status_code=401, detail="No HuggingFace token. Add it in Settings."
        )
    return token


def _translate(client: InferenceClient, text: str, target_lang: str) -> str:
    """Translate text to target_lang via Aya. Output ONLY the translation."""
    prompt = (
        f"You are a translator. Output ONLY the {target_lang} translation "
        f"of the text below. Do not explain, do not add notes, do not repeat "
        f"the original. If the text is already in {target_lang}, output it unchanged.\n\n"
        f"{text}"
    )
    response = client.chat_completion(
        messages=[{"role": "user", "content": prompt}],
        max_tokens=512,
        temperature=0.1,
    )
    translation = response.choices[0].message.content.strip()

    # Strip any echoed prefix the model may still produce
    for prefix in [
        f"{target_lang} translation:",
        f"{target_lang}:",
        "Translation:",
        "Answer:",
        "Text:",
        "Translated text:",
        "Output:",
        "Result:",
    ]:
        if translation.lower().startswith(prefix.lower()):
            translation = translation[len(prefix) :].strip()

    # If model returns alternatives ("A" or "B"), take the first
    if '" or "' in translation:
        translation = translation.split('" or "')[0].strip('"').strip()

    return translation


def _detect_and_translate(client: InferenceClient, text: str) -> tuple[str, str]:
    """
    Auto-detect language and translate to English.
    Returns (english_translation, detected_language_name).
    Used for text-input path where Whisper hasn't run.
    """
    prompt = (
        "You are a translator. Given the text below:\n"
        "1. Detect its language.\n"
        "2. Translate it to English.\n\n"
        "Reply in this exact format and nothing else:\n"
        "LANGUAGE: <language name in English>\n"
        "TRANSLATION: <English translation>\n\n"
        f"Text: {text}"
    )
    response = client.chat_completion(
        messages=[{"role": "user", "content": prompt}],
        max_tokens=512,
        temperature=0.1,
    )
    raw = response.choices[0].message.content.strip()

    # Parse LANGUAGE and TRANSLATION lines
    lang_match = re.search(r"LANGUAGE:\s*(.+)", raw, re.IGNORECASE)
    trans_match = re.search(r"TRANSLATION:\s*(.+)", raw, re.IGNORECASE)

    detected_lang = lang_match.group(1).strip() if lang_match else "Unknown"
    translation = trans_match.group(1).strip() if trans_match else raw

    return translation, detected_lang


# ─── Endpoints ────────────────────────────────────────────────────────────────


@app.get("/health")
def health():
    return {"status": "ok", "whisper": "ready", "models": list(MODELS.keys())}


@app.post("/process")
async def process(audio: UploadFile = File(...)):
    """Whisper STT → transcript + detected language code."""
    suffix = pathlib.Path(audio.filename or "audio.webm").suffix or ".webm"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp.write(await audio.read())
        tmp_path = tmp.name

    print(
        f"[HearTh] /process — file: {tmp_path}, size: {os.path.getsize(tmp_path)} bytes"
    )

    try:
        result = whisper_model.transcribe(tmp_path, task="transcribe")
        transcript = result["text"].strip()
        detected_lang = result["language"]
        print(f"[HearTh] Whisper → lang={detected_lang!r}, transcript={transcript!r}")

        return {
            "detected_language": detected_lang,
            "transcript": transcript,
        }
    finally:
        os.unlink(tmp_path)


@app.post("/detect-and-translate")
def detect_and_translate(req: DetectAndTranslateRequest, request: Request):
    """
    Resident → translate to English.

    Talk mode: language already known from Whisper (detected_language_code != "und")
               → just translate, echo back the Whisper-detected language.

    Type mode: language unknown (detected_language_code == "und")
               → ask Aya to detect + translate, return the detected language name.
    """
    token = get_token(request)
    if not token:
        raise HTTPException(
            status_code=401, detail="No HuggingFace token. Add it in Settings."
        )

    print(
        f"[HearTh] /detect-and-translate — lang={req.detected_language_code!r}, text={req.text!r}"
    )

    model_id = MODELS.get(req.model_key, MODELS["global"])
    client = InferenceClient(model=model_id, token=token)

    try:
        if req.detected_language_code in ("und", "unknown", ""):
            # ── Type mode: Aya detects language + translates ──────────────────
            translation, detected_language_name = _detect_and_translate(
                client, req.text
            )
            detected_language_code = (
                req.detected_language_code
            )  # still "und"; frontend can update
        else:
            # ── Talk mode: Whisper already detected the language ──────────────
            translation = _translate(client, req.text, "English")
            detected_language_name = req.detected_language_name
            detected_language_code = req.detected_language_code

        # Check the English translation for aggressive content
        if check_aggression(translation):
            send_sms_alert(req.text, translation)
            raise HTTPException(
                status_code=422,
                detail={
                    "error_code": "aggressive_content",
                    "message": "Message blocked: aggressive or threatening language detected.",
                },
            )

        print(
            f"[HearTh] translation: {translation!r}, lang: {detected_language_name!r}"
        )
        return {
            "detected_language": detected_language_name,  # ← now always a real name
            "detected_language_code": detected_language_code,
            "translation": translation,
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/translate")
def translate(req: TranslateRequest, request: Request):
    """Worker (English) → resident's language."""
    token = get_token(request)
    print(f"[HearTh] /translate — target={req.target_lang!r}, text={req.text!r}")

    if not req.target_lang or req.target_lang.lower() in ("unknown", "und", ""):
        raise HTTPException(
            status_code=400,
            detail="Resident language not yet detected. Have the resident speak or type first.",
        )

    model_id = MODELS.get(req.model_key, MODELS["global"])
    client = InferenceClient(model=model_id, token=token)

    # Worker text is already English — check before translating to save API cost
    if check_aggression(req.text):
        send_sms_alert(req.text, req.text)
        raise HTTPException(
            status_code=422,
            detail={
                "error_code": "aggressive_content",
                "message": "Message blocked: aggressive or threatening language detected.",
            },
        )

    try:
        translation = _translate(client, req.text, req.target_lang)
        print(f"[HearTh] translation: {translation!r}")
        return {"translation": translation}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ─── Frontend static files (must be last) ────────────────────────────────────

app.mount("/", StaticFiles(directory=str(FRONTEND_DIR), html=True), name="frontend")
