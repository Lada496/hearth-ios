"""
Keyword-based aggressive language detection.

Checks English text against a curated list of threatening, violent,
and aggressive keywords/phrases. Uses word-boundary matching to
reduce false positives (e.g. "skill" won't match "kill").
"""

import re

# Phrases and keywords indicating aggressive or threatening language.
# All matching is case-insensitive with word boundaries.
AGGRESSIVE_PATTERNS: list[str] = [
    # Direct threats
    "kill you",
    "i will kill",
    "i'll kill",
    "going to kill",
    "gonna kill",
    "i will hurt",
    "i'll hurt",
    "going to hurt",
    "gonna hurt",
    "beat you up",
    "i will beat",
    "punch you",
    "slap you",
    "stab you",
    "shoot you",
    "strangle you",
    "choke you",
    "burn you",
    "destroy you",
    "murder you",
    "i will murder",
    # Threatening language
    "shut up",
    "i'll find you",
    "you're dead",
    "you are dead",
    "watch your back",
    "you'll regret",
    "you will regret",
    "pay for this",
    "i'll make you",
    "threat",
    # Aggressive slurs / hostile phrases
    "get out",
    "go back to your country",
    "i hate you",
    "die",
    "drop dead",
    "worthless",
    "piece of shit",
    "son of a bitch",
    "bastard",
    "bitch",
    "damn you",
    "screw you",
    "fuck you",
    "fuck off",
    "piss off",
    "shut your mouth",
    "i swear i will",
]

# Pre-compile a single regex with all patterns joined by OR,
# wrapped in word boundaries for accurate matching.
_AGGRESSIVE_RE = re.compile(
    r"\b(?:" + "|".join(re.escape(p) for p in AGGRESSIVE_PATTERNS) + r")\b",
    re.IGNORECASE,
)


def check_aggression(text: str) -> bool:
    """Return True if the text contains aggressive or threatening language."""
    return bool(_AGGRESSIVE_RE.search(text))
