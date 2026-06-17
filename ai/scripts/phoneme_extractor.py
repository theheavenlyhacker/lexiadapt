#!/usr/bin/env python3
"""
Phoneme-level reading analysis using Whisper + phonemizer.
Focused on English for Grade 1-3 reading evaluation.

Usage:
  # Analyze an audio file against expected text
  python phoneme_extractor.py --audio test.wav --expected "The boy sees a big fish"

  # Quick test with a sample from LibriSpeech
  python phoneme_extractor.py --test

  # Use fine-tuned model
  python phoneme_extractor.py --audio test.wav --expected "text" --model ../models/whisper-tiny-en
"""
import argparse
import json


def analyze_reading(audio_path: str, expected_text: str, model_path: str = "tiny"):
    """
    Core analysis function. Returns accuracy, WPM, and trouble words.
    This is what the on-device Whisper will eventually replicate.
    """
    import whisper

    model = whisper.load_model(model_path)
    result = model.transcribe(audio_path, language="en", word_timestamps=True)

    spoken_text = result["text"].strip()
    spoken_words = [w.strip().lower() for w in spoken_text.split() if w.strip()]
    expected_words = [w.strip().lower() for w in expected_text.split() if w.strip()]

    # Word-level accuracy
    correct = 0
    trouble_words = []
    for i, expected in enumerate(expected_words):
        spoken = spoken_words[i] if i < len(spoken_words) else ""
        clean_expected = expected.strip(".,!?;:'\"")
        clean_spoken = spoken.strip(".,!?;:'\"")
        if clean_expected == clean_spoken:
            correct += 1
        else:
            trouble_words.append({
                "position": i,
                "expected": clean_expected,
                "spoken": clean_spoken if clean_spoken else "(missing)",
            })

    accuracy = correct / len(expected_words) if expected_words else 0

    # WPM from timestamps
    segments = result.get("segments", [])
    duration = 0
    if segments:
        duration = segments[-1]["end"] - segments[0]["start"]
    wpm = (len(spoken_words) / duration) * 60 if duration > 0 else 0

    # Phoneme analysis (English)
    try:
        from phonemizer import phonemize
        for tw in trouble_words:
            if tw["expected"]:
                tw["expected_phonemes"] = phonemize(
                    tw["expected"], language="en-us", backend="espeak"
                ).strip()
            if tw["spoken"] and tw["spoken"] != "(missing)":
                tw["spoken_phonemes"] = phonemize(
                    tw["spoken"], language="en-us", backend="espeak"
                ).strip()
    except ImportError:
        pass
    except Exception:
        pass

    # Classify trouble words by error type
    for tw in trouble_words:
        exp, spk = tw["expected"], tw["spoken"]
        if spk == "(missing)":
            tw["error_type"] = "omission"
        elif len(spk) > len(exp) + 2:
            tw["error_type"] = "insertion"
        elif exp[:2] == spk[:2] if len(exp) >= 2 and len(spk) >= 2 else False:
            tw["error_type"] = "ending"
        else:
            tw["error_type"] = "substitution"

    return {
        "accuracy": round(accuracy, 3),
        "wpm": round(wpm, 1),
        "spoken_text": spoken_text,
        "expected_text": expected_text,
        "trouble_words": trouble_words,
        "word_count": len(expected_words),
        "correct_count": correct,
        "duration_seconds": round(duration, 2),
    }


def grade_reading_level(accuracy: float, wpm: float) -> dict:
    """
    Map accuracy + WPM to a Grade 1-3 reading level.
    Based on WCPM (Words Correct Per Minute) norms.
    """
    wcpm = accuracy * wpm

    if wcpm >= 90:
        level = "Grade 3 (Proficient)"
    elif wcpm >= 60:
        level = "Grade 2 (Developing)"
    elif wcpm >= 30:
        level = "Grade 1 (Beginning)"
    else:
        level = "Pre-reader (Needs support)"

    return {
        "wcpm": round(wcpm, 1),
        "level": level,
        "accuracy_grade": "Good" if accuracy >= 0.9 else "Fair" if accuracy >= 0.7 else "Needs practice",
        "fluency_grade": "Good" if wpm >= 80 else "Fair" if wpm >= 50 else "Needs practice",
    }


def run_test():
    """Quick test using Whisper on a synthetic example."""
    import whisper
    import numpy as np

    print("Loading Whisper-tiny...")
    model = whisper.load_model("tiny")
    print("Model loaded successfully!")

    # Generate silent audio and transcribe (just to verify model works)
    silent = np.zeros(16000 * 2, dtype=np.float32)
    result = model.transcribe(silent, language="en")
    print(f"Transcription of silence: '{result['text'].strip()}'")
    print("Whisper-tiny is working. Ready for real audio files.")

    # Show grading examples
    print("\nReading level examples:")
    for acc, wpm in [(0.95, 100), (0.80, 70), (0.60, 40), (0.40, 20)]:
        grade = grade_reading_level(acc, wpm)
        print(f"  Accuracy={acc:.0%} WPM={wpm} → WCPM={grade['wcpm']} → {grade['level']}")


def main():
    parser = argparse.ArgumentParser(description="Analyze English reading with Whisper")
    parser.add_argument("--audio", type=str, help="Path to audio file (.wav/.mp3)")
    parser.add_argument("--expected", type=str, help="Expected text the student should read")
    parser.add_argument("--model", type=str, default="tiny",
                        help="Whisper model name or path to fine-tuned model")
    parser.add_argument("--test", action="store_true",
                        help="Run a quick test to verify Whisper works")
    args = parser.parse_args()

    if args.test:
        run_test()
        return

    if not args.audio or not args.expected:
        parser.error("--audio and --expected are required (or use --test)")

    result = analyze_reading(args.audio, args.expected, args.model)
    grade = grade_reading_level(result["accuracy"], result["wpm"])
    result["reading_level"] = grade

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
