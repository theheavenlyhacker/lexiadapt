# LexiAdapt — AI Implementation Roadmap

A step-by-step guide for implementing the complete AI pipeline: from environment setup through model training, quantization, Flutter integration, and on-device deployment.

---

## Table of Contents

1. [Overview — What You're Building](#1-overview)
2. [Environment Setup & Downloads](#2-environment-setup--downloads)
3. [Phase 1: Speech Recognition (Whisper-tiny)](#3-phase-1-speech-recognition-whisper-tiny)
4. [Phase 2: Learner Tracking (HMM)](#4-phase-2-learner-tracking-hmm)
5. [Phase 3: Adaptive Difficulty (DRL/PPO)](#5-phase-3-adaptive-difficulty-drlppo)
6. [Phase 4: Story Generation (LSTM)](#6-phase-4-story-generation-lstm)
7. [Phase 5: Quantization & On-Device Deployment](#7-phase-5-quantization--on-device-deployment)
8. [Phase 6: Flutter Integration](#8-phase-6-flutter-integration)
9. [Phase 7: Federated Learning](#9-phase-7-federated-learning)
10. [Phase 8: Local Database Layer](#10-phase-8-local-database-layer)
11. [Data Sources & Datasets](#11-data-sources--datasets)
12. [File Structure After AI Integration](#12-file-structure-after-ai-integration)
13. [Constraints Checklist](#13-constraints-checklist)
14. [Sprint-to-Phase Mapping](#14-sprint-to-phase-mapping)

---

## 1. Overview

The AI pipeline has 4 core models that work together in a loop:

```
Student reads aloud
       │
       ▼
┌─────────────────┐
│  Whisper-tiny    │ ← Speech-to-text, phoneme extraction, WPM
│  (INT4 quantized)│
└────────┬────────┘
         │ phoneme scores, failure points
         ▼
┌─────────────────┐
│  HMM Tracker     │ ← Tracks vocab retention, letter-sound failures
│  (Pure Dart/Python)│
└────────┬────────┘
         │ learner state vector
         ▼
┌─────────────────┐
│  DRL Agent (PPO) │ ← Decides next difficulty level
│  (TFLite model)  │
└────────┬────────┘
         │ difficulty params
         ▼
┌─────────────────┐
│  LSTM Generator  │ ← Generates next story with "trouble words"
│  (TFLite model)  │
└────────┬────────┘
         │ personalized story
         ▼
    UI displays story → Student reads → Loop repeats
```

**Target constraints** (from tech doc):
- All inference < 100ms latency
- All models combined < 100MB on disk
- Runs on 2GB RAM ARM devices
- 100% offline capable
- INT4 quantization for all neural models

---

## 2. Environment Setup & Downloads

### 2.1 Python Environment (Model Training)

You'll train models on your dev machine, then export quantized versions for mobile.

```bash
# Create virtual environment
python3 -m venv lexiadapt_ai
source lexiadapt_ai/bin/activate

# Core ML framework
pip install torch torchvision torchaudio    # PyTorch (DRL + LSTM training)
pip install tensorflow tensorflow-lite      # TFLite export + quantization

# Whisper
pip install openai-whisper                  # Whisper model (we'll use whisper-tiny)
pip install transformers                    # HuggingFace for model access

# Reinforcement Learning
pip install stable-baselines3               # PPO implementation
pip install gymnasium                       # RL environments

# Quantization & Export
pip install onnx onnxruntime               # ONNX intermediate format
pip install optimum                         # HuggingFace quantization tools

# Data Processing
pip install pandas numpy librosa            # Audio processing
pip install jiwer                           # Word Error Rate metric
pip install phonemizer                      # Grapheme-to-phoneme conversion

# Federated Learning
pip install flwr                            # Flower framework (FL)
```

### 2.2 Model Downloads

```bash
# Create model directory
mkdir -p ai/models ai/data ai/scripts ai/exports

# Download Whisper-tiny (39MB base, ~10MB after INT4 quantization)
python3 -c "import whisper; whisper.load_model('tiny', download_root='ai/models/')"

# Alternative: HuggingFace (more control over export)
python3 -c "
from transformers import WhisperProcessor, WhisperForConditionalGeneration
model = WhisperForConditionalGeneration.from_pretrained('openai/whisper-tiny')
model.save_pretrained('ai/models/whisper-tiny')
processor = WhisperProcessor.from_pretrained('openai/whisper-tiny')
processor.save_pretrained('ai/models/whisper-tiny')
"
```

### 2.3 Flutter Packages (Add to pubspec.yaml when ready)

```yaml
dependencies:
  # On-device ML inference
  tflite_flutter: ^0.11.0          # Run TFLite models on device
  tflite_flutter_helper: ^0.4.4    # Tensor helpers

  # Audio capture
  record: ^5.1.2                    # Microphone recording
  just_audio: ^0.9.40               # Audio playback

  # Local database
  sqflite: ^2.4.1                   # SQLite for learner data
  path_provider: ^2.1.5             # File paths

  # Optional: ONNX alternative
  # onnxruntime_flutter: ^1.0.0     # If using ONNX instead of TFLite
```

### 2.4 Required Datasets

| Dataset | Purpose | Source | Size |
|---------|---------|--------|------|
| Common Voice (Filipino/Tagalog) | Speech training data | `https://commonvoice.mozilla.org/` | ~2GB |
| Common Voice (Vietnamese, Indonesian, Thai) | Multi-dialect support | Same as above | ~1-3GB each |
| LibriSpeech (clean-100) | English baseline phoneme accuracy | `https://www.openslr.org/12/` | 6.3GB |
| ASEAN Folk Tales corpus | LSTM story training | Compile manually from public domain sources | ~50MB text |
| Grade 1-3 Word Lists | Vocabulary trees, difficulty grading | Philippine DepEd K-3 curriculum | Manual compilation |
| IPA Phoneme Dictionary | Phoneme-to-sound mapping | `https://github.com/open-dict-data/ipa-dict` | ~5MB |

---

## 3. Phase 1: Speech Recognition (Whisper-tiny)

**Goal:** Student speaks → app gets phoneme-level accuracy + WPM.

### 3.1 What to Do

1. **Download Whisper-tiny** (39MB FP32 → ~10MB INT4)
2. **Fine-tune on ASEAN accents** — Whisper-tiny works well for English but needs tuning for Filipino/Tagalog vowel shifts
3. **Extract phoneme-level timestamps** — Whisper gives word-level timestamps; you need phoneme alignment
4. **Calculate metrics:** WPM (words per minute), phoneme accuracy per word, reading cadence

### 3.2 Training Script Skeleton

```python
# ai/scripts/finetune_whisper.py
from transformers import (
    WhisperForConditionalGeneration,
    WhisperProcessor,
    Seq2SeqTrainer,
    Seq2SeqTrainingArguments,
)
from datasets import load_dataset, Audio

# Load Whisper-tiny
model = WhisperForConditionalGeneration.from_pretrained("openai/whisper-tiny")
processor = WhisperProcessor.from_pretrained("openai/whisper-tiny")

# Load Common Voice Filipino dataset
dataset = load_dataset("mozilla-foundation/common_voice_16_1", "tl", split="train")
dataset = dataset.cast_column("audio", Audio(sampling_rate=16000))

def prepare_dataset(batch):
    audio = batch["audio"]
    batch["input_features"] = processor(
        audio["array"], sampling_rate=16000, return_tensors="pt"
    ).input_features[0]
    batch["labels"] = processor.tokenizer(batch["sentence"]).input_ids
    return batch

dataset = dataset.map(prepare_dataset, remove_columns=dataset.column_names)

# Training config — optimize for tiny model + small dataset
training_args = Seq2SeqTrainingArguments(
    output_dir="ai/models/whisper-tiny-filipino",
    per_device_train_batch_size=8,
    num_train_epochs=3,
    learning_rate=1e-5,
    fp16=True,                          # Mixed precision for faster training
    predict_with_generate=True,
    save_total_limit=2,
)

trainer = Seq2SeqTrainer(
    model=model,
    args=training_args,
    train_dataset=dataset,
    tokenizer=processor.feature_extractor,
)

trainer.train()
model.save_pretrained("ai/models/whisper-tiny-filipino")
```

### 3.3 Phoneme Extraction

```python
# ai/scripts/phoneme_extractor.py
import whisper
from phonemizer import phonemize

model = whisper.load_model("tiny")

def analyze_reading(audio_path: str, expected_text: str):
    """Compare student's speech against expected text."""
    result = model.transcribe(audio_path, word_timestamps=True)

    spoken_words = [seg["word"].strip() for seg in result["segments"][0]["words"]]
    expected_words = expected_text.lower().split()

    # Word-level accuracy
    correct = sum(1 for s, e in zip(spoken_words, expected_words) if s == e)
    accuracy = correct / len(expected_words) if expected_words else 0

    # WPM calculation
    duration = result["segments"][-1]["end"] - result["segments"][0]["start"]
    wpm = (len(spoken_words) / duration) * 60

    # Phoneme-level analysis
    expected_phonemes = phonemize(expected_text, language="en-us")
    spoken_phonemes = phonemize(" ".join(spoken_words), language="en-us")

    # Identify "trouble words" — words where phonemes diverge
    trouble_words = []
    for s, e in zip(spoken_words, expected_words):
        if s != e:
            trouble_words.append({
                "expected": e,
                "spoken": s,
                "expected_phonemes": phonemize(e, language="en-us"),
                "spoken_phonemes": phonemize(s, language="en-us"),
            })

    return {
        "accuracy": accuracy,
        "wpm": wpm,
        "trouble_words": trouble_words,
        "transcript": result["text"],
    }
```

### 3.4 Key Files to Create

```
ai/
├── scripts/
│   ├── finetune_whisper.py          # Fine-tune on ASEAN dialects
│   ├── phoneme_extractor.py         # Extract phoneme accuracy
│   └── export_whisper_tflite.py     # Convert to TFLite INT4
├── models/
│   ├── whisper-tiny/                # Base model
│   └── whisper-tiny-filipino/       # Fine-tuned model
```

---

## 4. Phase 2: Learner Tracking (HMM)

**Goal:** Track which words/phonemes each student struggles with over time.

### 4.1 What to Do

This is the simplest AI component — it can be implemented in **pure Dart** without a neural model. A Hidden Markov Model tracks state transitions between "mastered" and "struggling" for each word/phoneme.

### 4.2 Implementation

```python
# ai/scripts/hmm_learner_model.py
# This logic will be reimplemented in Dart for on-device use.

import numpy as np

class LearnerHMM:
    """
    States: STRUGGLING (0), LEARNING (1), MASTERED (2)
    Observations: INCORRECT (0), SLOW_CORRECT (1), CORRECT (2)
    """

    STRUGGLING, LEARNING, MASTERED = 0, 1, 2

    def __init__(self):
        # Transition probabilities: P(next_state | current_state)
        self.transition = np.array([
            [0.6, 0.3, 0.1],   # From STRUGGLING
            [0.1, 0.5, 0.4],   # From LEARNING
            [0.05, 0.15, 0.8], # From MASTERED
        ])

        # Emission probabilities: P(observation | state)
        self.emission = np.array([
            [0.7, 0.2, 0.1],   # STRUGGLING → likely incorrect
            [0.2, 0.5, 0.3],   # LEARNING → likely slow but correct
            [0.05, 0.15, 0.8], # MASTERED → likely correct
        ])

    def update(self, word: str, observation: int, word_states: dict) -> int:
        """Update belief about a word's mastery state."""
        if word not in word_states:
            word_states[word] = np.array([0.7, 0.2, 0.1])  # Start assuming struggling

        belief = word_states[word]
        # Predict step: apply transition
        predicted = belief @ self.transition
        # Update step: apply emission
        updated = predicted * self.emission[:, observation]
        updated /= updated.sum()

        word_states[word] = updated
        return int(np.argmax(updated))  # Most likely state
```

### 4.3 Dart Implementation Location

```
lib/features/student/domain/learner_hmm.dart     # Pure Dart HMM
lib/features/student/data/learner_repository.dart  # SQLite persistence
```

The HMM doesn't need a TFLite model — it's lightweight math that runs in Dart directly.

---

## 5. Phase 3: Adaptive Difficulty (DRL/PPO)

**Goal:** Automatically adjust reading difficulty based on the student's performance.

### 5.1 What to Do

1. **Define the environment** — state = learner profile, action = difficulty adjustment
2. **Train PPO agent** using stable-baselines3
3. **Export to TFLite** for on-device inference

### 5.2 Environment Design

```python
# ai/scripts/reading_env.py
import gymnasium as gym
from gymnasium import spaces
import numpy as np

class ReadingTutorEnv(gym.Env):
    """
    State (8 dims):
      - overall_accuracy (0-1)
      - phonics_score (0-1)
      - vocabulary_score (0-1)
      - fluency_wpm_normalized (0-1)
      - comprehension_score (0-1)
      - current_difficulty (0-1)
      - consecutive_successes (0-10, normalized)
      - consecutive_failures (0-10, normalized)

    Actions (5 discrete):
      0: decrease difficulty by 2 levels
      1: decrease difficulty by 1 level
      2: maintain current difficulty
      3: increase difficulty by 1 level
      4: increase difficulty by 2 levels

    Reward:
      +1.0 if student accuracy improves
      +0.5 if student maintains good accuracy (> 0.7)
      -0.5 if accuracy drops below 0.4
      -1.0 if student gets frustrated (3+ consecutive failures)
      +0.3 bonus for staying in "Zone of Proximal Development" (accuracy 0.6-0.85)
    """

    def __init__(self):
        super().__init__()
        self.observation_space = spaces.Box(low=0, high=1, shape=(8,), dtype=np.float32)
        self.action_space = spaces.Discrete(5)
        self.state = None
        self.reset()

    def reset(self, seed=None, options=None):
        super().reset(seed=seed)
        self.state = np.array([
            0.5,   # overall_accuracy
            0.5,   # phonics
            0.5,   # vocabulary
            0.4,   # fluency
            0.5,   # comprehension
            0.3,   # difficulty (start easy)
            0.0,   # consecutive_successes
            0.0,   # consecutive_failures
        ], dtype=np.float32)
        return self.state, {}

    def step(self, action):
        difficulty_delta = (action - 2) * 0.1  # Maps 0-4 to -0.2 to +0.2
        new_difficulty = np.clip(self.state[5] + difficulty_delta, 0.0, 1.0)

        # Simulate student response based on difficulty vs ability
        ability = np.mean(self.state[:5])
        gap = ability - new_difficulty
        accuracy = np.clip(0.5 + gap + np.random.normal(0, 0.1), 0, 1)

        # Calculate reward
        reward = 0.0
        if accuracy > self.state[0]:
            reward += 1.0  # Improved
        if 0.6 <= accuracy <= 0.85:
            reward += 0.3  # Zone of Proximal Development
        if accuracy < 0.4:
            reward -= 0.5  # Too hard
        if accuracy >= 0.7:
            reward += 0.5  # Good performance

        # Update state
        self.state[0] = accuracy
        self.state[5] = new_difficulty
        self.state[6] = min(1.0, self.state[6] + 0.1) if accuracy > 0.6 else 0
        self.state[7] = min(1.0, self.state[7] + 0.1) if accuracy < 0.4 else 0

        terminated = False
        truncated = False
        return self.state, reward, terminated, truncated, {}
```

### 5.3 Training Script

```python
# ai/scripts/train_drl.py
from stable_baselines3 import PPO
from reading_env import ReadingTutorEnv

env = ReadingTutorEnv()

model = PPO(
    "MlpPolicy",
    env,
    learning_rate=3e-4,
    n_steps=2048,
    batch_size=64,
    n_epochs=10,
    verbose=1,
)

model.learn(total_timesteps=500_000)
model.save("ai/models/drl_ppo_tutor")

# Export to ONNX → TFLite
# See Phase 5 for quantization steps
```

### 5.4 Key Outputs

The DRL agent outputs a single integer (0-4) representing the difficulty adjustment. This gets mapped to:

| Action | Meaning | Effect |
|--------|---------|--------|
| 0 | Much easier | Shorter words, simpler sentences |
| 1 | Slightly easier | Reduce 1 vocab level |
| 2 | Maintain | Same difficulty |
| 3 | Slightly harder | Add 1 vocab level |
| 4 | Much harder | Longer sentences, harder words |

---

## 6. Phase 4: Story Generation (LSTM)

**Goal:** Generate personalized reading passages that weave in the student's "trouble words."

### 6.1 What to Do

1. **Compile training corpus** — 20,000 ASEAN folk tales + Grade 1-3 reading passages
2. **Train character-level or word-level LSTM**
3. **Condition generation on:** difficulty level + trouble words + category theme

### 6.2 Training Script

```python
# ai/scripts/train_lstm.py
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, Dataset

class StoryLSTM(nn.Module):
    def __init__(self, vocab_size, embed_dim=128, hidden_dim=256, num_layers=2):
        super().__init__()
        self.embedding = nn.Embedding(vocab_size, embed_dim)
        self.lstm = nn.LSTM(embed_dim, hidden_dim, num_layers, batch_first=True)
        self.fc = nn.Linear(hidden_dim, vocab_size)

    def forward(self, x, hidden=None):
        x = self.embedding(x)
        output, hidden = self.lstm(x, hidden)
        output = self.fc(output)
        return output, hidden

    def generate(self, start_tokens, max_len=100, temperature=0.8):
        """Generate story text given starting tokens."""
        self.eval()
        tokens = start_tokens.clone()
        hidden = None

        with torch.no_grad():
            for _ in range(max_len):
                output, hidden = self.forward(tokens[:, -1:], hidden)
                probs = torch.softmax(output[:, -1] / temperature, dim=-1)
                next_token = torch.multinomial(probs, 1)
                tokens = torch.cat([tokens, next_token], dim=1)

                if next_token.item() == EOS_TOKEN:
                    break

        return tokens

# Training loop
model = StoryLSTM(vocab_size=10000)
optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
criterion = nn.CrossEntropyLoss()

for epoch in range(50):
    for batch in dataloader:
        inputs, targets = batch
        output, _ = model(inputs)
        loss = criterion(output.view(-1, 10000), targets.view(-1))
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

torch.save(model.state_dict(), "ai/models/story_lstm.pth")
```

### 6.3 Story Generation Strategy

The LSTM doesn't generate completely from scratch. Instead:

1. **Template bank** — 500+ story templates per category (Animals, Fantasy, Adventure, etc.)
2. **Word injection** — Replace key nouns/verbs with the student's trouble words
3. **LSTM fills gaps** — Generates connecting text that makes grammatical sense
4. **Difficulty filter** — Post-process to ensure vocabulary matches the DRL difficulty target

Example:
```
Template:  "The [ANIMAL] went to the [PLACE] to find a [OBJECT]."
Trouble words: ["beautiful", "rock", "table"]
Generated: "The beautiful bird went to the rock by the river to find a table for the feast."
```

---

## 7. Phase 5: Quantization & On-Device Deployment

**Goal:** Convert all models to INT4/INT8 TFLite for mobile.

### 7.1 Whisper → TFLite

```python
# ai/scripts/export_whisper_tflite.py
from transformers import WhisperForConditionalGeneration
import tensorflow as tf
import numpy as np

# Step 1: Export to ONNX
from optimum.onnxruntime import ORTModelForSpeechSeq2Seq
ort_model = ORTModelForSpeechSeq2Seq.from_pretrained(
    "ai/models/whisper-tiny-filipino",
    export=True
)
ort_model.save_pretrained("ai/exports/whisper-onnx")

# Step 2: Convert ONNX → TFLite with INT4 quantization
# Using representative dataset for calibration
def representative_dataset():
    for _ in range(100):
        yield [np.random.randn(1, 80, 3000).astype(np.float32)]

converter = tf.lite.TFLiteConverter.from_saved_model("ai/exports/whisper-saved-model")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_dataset
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.int8
converter.inference_output_type = tf.int8

tflite_model = converter.convert()

with open("ai/exports/whisper_tiny_int4.tflite", "wb") as f:
    f.write(tflite_model)

print(f"Model size: {len(tflite_model) / 1024 / 1024:.1f} MB")
```

### 7.2 PPO Agent → TFLite

```python
# ai/scripts/export_ppo_tflite.py
from stable_baselines3 import PPO
import torch
import tensorflow as tf

model = PPO.load("ai/models/drl_ppo_tutor")
policy = model.policy.to("cpu")

# Export policy network only (not the value network)
dummy_input = torch.randn(1, 8)  # 8-dim state vector
torch.onnx.export(
    policy.action_net,
    dummy_input,
    "ai/exports/ppo_policy.onnx",
    input_names=["state"],
    output_names=["action"],
)

# Then convert ONNX → TFLite (similar to above)
```

### 7.3 LSTM → TFLite

```python
# ai/scripts/export_lstm_tflite.py
import torch

model = StoryLSTM(vocab_size=10000)
model.load_state_dict(torch.load("ai/models/story_lstm.pth"))
model.eval()

dummy_input = torch.randint(0, 10000, (1, 20))
torch.onnx.export(
    model,
    dummy_input,
    "ai/exports/story_lstm.onnx",
    input_names=["input_tokens"],
    output_names=["output_logits"],
    dynamic_axes={"input_tokens": {1: "seq_len"}},
)

# Convert to TFLite with INT8 quantization
```

### 7.4 Expected Model Sizes

| Model | FP32 Size | INT4/INT8 Size | Target |
|-------|-----------|----------------|--------|
| Whisper-tiny | 39 MB | ~10 MB | Speech recognition |
| PPO Policy | ~2 MB | ~0.5 MB | Difficulty adjustment |
| LSTM Story | ~15 MB | ~4 MB | Story generation |
| **Total** | **~56 MB** | **~15 MB** | **< 100 MB budget** |

---

## 8. Phase 6: Flutter Integration

### 8.1 File Structure

```
lib/features/student/
├── data/
│   ├── datasources/
│   │   ├── speech_recognition_service.dart    # Whisper TFLite bridge
│   │   ├── story_generator_service.dart       # LSTM TFLite bridge
│   │   └── local_database.dart                # SQLite operations
│   ├── models/
│   │   ├── reading_session_model.dart
│   │   └── learner_profile_model.dart
│   └── repositories/
│       ├── learner_repository_impl.dart
│       └── story_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── learner_profile.dart
│   │   ├── reading_result.dart
│   │   └── story.dart
│   ├── learner_hmm.dart                       # Pure Dart HMM
│   ├── difficulty_engine.dart                 # TFLite PPO bridge
│   └── usecases/
│       ├── evaluate_reading.dart
│       └── get_next_story.dart
```

### 8.2 Speech Recognition Service

```dart
// lib/features/student/data/datasources/speech_recognition_service.dart
import 'package:tflite_flutter/tflite_flutter.dart';

class SpeechRecognitionService {
  late Interpreter _interpreter;

  Future<void> initialize() async {
    _interpreter = await Interpreter.fromAsset('models/whisper_tiny_int4.tflite');
  }

  Future<ReadingResult> evaluateReading(List<double> audioSamples, String expectedText) async {
    // Preprocess audio → mel spectrogram (80 x 3000)
    final melSpectrogram = _audioToMelSpectrogram(audioSamples);

    // Run inference
    final output = List.filled(1 * 448, 0.0).reshape([1, 448]);
    _interpreter.run(melSpectrogram, output);

    // Decode tokens → text
    final spokenText = _decodeTokens(output);

    // Compare against expected
    return _calculateAccuracy(spokenText, expectedText);
  }

  void dispose() => _interpreter.close();
}
```

### 8.3 Difficulty Engine

```dart
// lib/features/student/domain/difficulty_engine.dart
import 'package:tflite_flutter/tflite_flutter.dart';

class DifficultyEngine {
  late Interpreter _interpreter;

  Future<void> initialize() async {
    _interpreter = await Interpreter.fromAsset('models/ppo_policy.tflite');
  }

  int getNextDifficulty(LearnerProfile profile) {
    final state = Float32List.fromList([
      profile.overallAccuracy,
      profile.phonicsScore,
      profile.vocabularyScore,
      profile.fluencyWpm / 150.0,  // Normalize WPM
      profile.comprehensionScore,
      profile.currentDifficulty,
      profile.consecutiveSuccesses / 10.0,
      profile.consecutiveFailures / 10.0,
    ]);

    final output = List.filled(5, 0.0).reshape([1, 5]);
    _interpreter.run(state.reshape([1, 8]), output);

    // Return argmax action (0-4)
    return output[0].indexOf(output[0].reduce(max));
  }

  void dispose() => _interpreter.close();
}
```

### 8.4 Integration into Reading Session

```dart
// In ReadingSessionScreen, the full AI loop:

// 1. Student taps mic → record audio
final audioData = await _recorder.stop();

// 2. Whisper evaluates pronunciation
final result = await _speechService.evaluateReading(audioData, currentStory.text);

// 3. HMM updates learner state
for (final word in result.troubleWords) {
  _learnerHmm.update(word, observation: result.wordAccuracy(word));
}

// 4. DRL decides next difficulty
final action = _difficultyEngine.getNextDifficulty(_learnerProfile);
_learnerProfile.applyDifficultyAction(action);

// 5. LSTM generates next story
final nextStory = await _storyGenerator.generate(
  category: selectedCategory,
  difficulty: _learnerProfile.currentDifficulty,
  troubleWords: _learnerHmm.currentTroubleWords,
);

// 6. Update UI
setState(() => currentStory = nextStory);
```

---

## 9. Phase 7: Federated Learning

### 9.1 What to Do

Federated Learning lets devices improve the shared model without sending raw audio to a server. Only **model weight deltas** are transmitted.

### 9.2 Architecture

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Device A     │     │  Device B     │     │  Device C     │
│  (Tagalog)    │     │  (Cebuano)    │     │  (Vietnamese) │
│  Local train  │     │  Local train  │     │  Local train  │
└──────┬───────┘     └──────┬───────┘     └──────┬───────┘
       │ weight deltas      │                     │
       └────────────────────┼─────────────────────┘
                            ▼
                   ┌────────────────┐
                   │  FL Server      │
                   │  (FastAPI)      │
                   │  Aggregates     │
                   │  weight updates │
                   └────────┬───────┘
                            │ averaged weights
                            ▼
                   Push back to devices
                   (Lazy Sync on Wi-Fi)
```

### 9.3 Server (FastAPI + Flower)

```python
# ai/server/fl_server.py
import flwr as fl

strategy = fl.server.strategy.FedAvg(
    min_fit_clients=3,
    min_available_clients=5,
)

fl.server.start_server(
    server_address="0.0.0.0:8080",
    config=fl.server.ServerConfig(num_rounds=10),
    strategy=strategy,
)
```

### 9.4 Flutter Client (Lazy Sync)

```dart
// lib/core/services/federated_learning_client.dart
class FederatedLearningClient {
  /// Only syncs when Wi-Fi is available. Never sends raw audio.
  Future<void> syncIfConnected() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.wifi) return;

    // 1. Read local model weight deltas from SQLite
    final deltas = await _db.getWeightDeltas();
    if (deltas.isEmpty) return;

    // 2. Send deltas to FL server
    try {
      await _api.postWeightDeltas(deltas);

      // 3. Receive aggregated weights
      final globalWeights = await _api.getGlobalWeights();

      // 4. Merge into local model
      await _modelManager.mergeWeights(globalWeights);

      // 5. Clear sent deltas
      await _db.clearSentDeltas();
    } catch (_) {
      // Offline — will retry next time
    }
  }
}
```

---

## 10. Phase 8: Local Database Layer

### 10.1 SQLite Schema

```sql
-- Learner profile
CREATE TABLE learner (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  grade INTEGER NOT NULL,
  language TEXT DEFAULT 'en',
  created_at INTEGER NOT NULL
);

-- Per-word mastery tracking (HMM states)
CREATE TABLE word_mastery (
  learner_id TEXT REFERENCES learner(id),
  word TEXT NOT NULL,
  state_struggling REAL DEFAULT 0.7,
  state_learning REAL DEFAULT 0.2,
  state_mastered REAL DEFAULT 0.1,
  attempts INTEGER DEFAULT 0,
  last_seen INTEGER,
  PRIMARY KEY (learner_id, word)
);

-- Reading session history
CREATE TABLE reading_session (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  learner_id TEXT REFERENCES learner(id),
  story_text TEXT NOT NULL,
  category TEXT,
  difficulty REAL,
  accuracy REAL,
  wpm REAL,
  trouble_words TEXT,  -- JSON array
  duration_ms INTEGER,
  created_at INTEGER NOT NULL
);

-- Achievement tracking
CREATE TABLE achievement (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  learner_id TEXT REFERENCES learner(id),
  badge_id TEXT NOT NULL,
  earned_at INTEGER NOT NULL
);

-- Federated learning weight deltas (pending sync)
CREATE TABLE fl_weight_delta (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  model_name TEXT NOT NULL,
  delta_blob BLOB NOT NULL,
  created_at INTEGER NOT NULL,
  synced INTEGER DEFAULT 0
);
```

---

## 11. Data Sources & Datasets

### 11.1 What to Download

| What | URL | Notes |
|------|-----|-------|
| Whisper-tiny weights | `huggingface.co/openai/whisper-tiny` | 39MB, MIT license |
| Common Voice Filipino | `commonvoice.mozilla.org/tl` | CC-0 license, ~2GB |
| Common Voice Vietnamese | `commonvoice.mozilla.org/vi` | CC-0 license |
| Common Voice Indonesian | `commonvoice.mozilla.org/id` | CC-0 license |
| Common Voice Thai | `commonvoice.mozilla.org/th` | CC-0 license |
| IPA Phoneme Dictionary | `github.com/open-dict-data/ipa-dict` | MIT license |
| LibriSpeech clean-100 | `openslr.org/12/` | CC BY 4.0, English baseline |
| Philippine DepEd K-3 Wordlists | Manual compilation from DepEd materials | Public curriculum |
| ASEAN Folk Tales | Manual compilation from Project Gutenberg, Wikisource | Public domain |

### 11.2 What to Compile Yourself

1. **10,000-word phonetic library** — Map each word to its IPA pronunciation for all 8 supported languages
2. **Vocabulary difficulty trees** — Grade words by difficulty level (Grade 1/2/3) per language
3. **Story templates** — 500+ templates per category, tagged by difficulty
4. **SNR calibration data** — Record 50 samples in noisy environments (classroom, outdoor) for noise filtering

---

## 12. File Structure After AI Integration

```
lexiadapt/
├── ai/                                    # Python training environment
│   ├── scripts/
│   │   ├── finetune_whisper.py
│   │   ├── phoneme_extractor.py
│   │   ├── train_drl.py
│   │   ├── train_lstm.py
│   │   ├── reading_env.py
│   │   ├── export_whisper_tflite.py
│   │   ├── export_ppo_tflite.py
│   │   └── export_lstm_tflite.py
│   ├── models/                            # Trained model checkpoints
│   ├── exports/                           # Quantized TFLite files
│   ├── data/                              # Training datasets
│   └── server/
│       └── fl_server.py                   # Federated Learning aggregator
├── assets/
│   ├── images/                            # ✅ Already done
│   └── models/                            # TFLite models for mobile
│       ├── whisper_tiny_int4.tflite
│       ├── ppo_policy.tflite
│       └── story_lstm.tflite
├── lib/                                   # ✅ Flutter app
│   ├── core/
│   ├── features/
│   │   ├── student/
│   │   │   ├── screens/                   # ✅ Already done
│   │   │   ├── widgets/                   # ✅ Already done
│   │   │   ├── domain/                    # 🔜 HMM, difficulty engine, use cases
│   │   │   └── data/                      # 🔜 TFLite bridges, SQLite, repos
│   │   └── teacher/
│   └── ...
```

---

## 13. Constraints Checklist

Before submitting, verify every constraint from the tech doc:

| # | Constraint | Target | How to Verify |
|---|-----------|--------|---------------|
| 1 | App size | < 50 MB | `flutter build apk --release` → check APK size |
| 2 | Model total | < 100 MB | `du -sh assets/models/` |
| 3 | Inference latency | < 100 ms | Benchmark on target device with `Stopwatch` |
| 4 | RAM usage | < 2 GB | Android profiler during reading session |
| 5 | Offline capable | 100% | Airplane mode test — all features must work |
| 6 | Audio privacy | Never leaves device | Grep codebase for HTTP calls with audio data |
| 7 | Screen target | 720p | Test on 720p emulator |
| 8 | Battery drain | No thermal throttle | 30-min continuous use test |
| 9 | Legal (RA 10173) | No PII transmitted | Audit FL client — only weight deltas |
| 10 | Languages | 8 ASEAN | Test each language selection in settings |

---

## 14. Sprint-to-Phase Mapping

| Sprint | Period | Phases from this Roadmap | Deliverable |
|--------|--------|--------------------------|-------------|
| **Sprint 1** | May 1–15 | Phase 1 (Whisper fine-tuning), Data collection | Fine-tuned Whisper-tiny for Filipino/English, phoneme extraction working |
| **Sprint 2** | May 16–31 | Phase 2 (HMM), Phase 3 (DRL), Phase 4 (LSTM), Phase 5 (Quantization) | All 4 models trained, quantized to TFLite, < 100MB total |
| **Sprint 3** | Jun 1–15 | Phase 6 (Flutter integration), Phase 8 (SQLite) | Full AI pipeline working in app, offline database |
| **Sprint 4** | Jun 16–25 | Phase 7 (FL), Benchmarking, Security audit | FL server running, all constraints met, demo-ready |

---

## Quick Start — First 4 Hours

If you want to get a working AI prototype fast:

```bash
# 1. Set up Python env (15 min)
python3 -m venv lexiadapt_ai && source lexiadapt_ai/bin/activate
pip install openai-whisper torch stable-baselines3 gymnasium

# 2. Test Whisper-tiny works (5 min)
python3 -c "
import whisper
model = whisper.load_model('tiny')
result = model.transcribe('test_audio.wav')
print(result['text'])
"

# 3. Train DRL agent on simulated data (30 min)
cd ai/scripts && python3 train_drl.py

# 4. Implement HMM in Dart (2 hours)
# → lib/features/student/domain/learner_hmm.dart

# 5. Export PPO to TFLite (1 hour)
python3 export_ppo_tflite.py

# 6. Wire TFLite into Flutter (1 hour)
# Add tflite_flutter to pubspec.yaml
# Create DifficultyEngine in Dart
```

This gets you a working prototype where:
- Whisper transcribes student speech (Python, not yet on-device)
- HMM tracks word mastery (Dart, on-device)
- DRL adjusts difficulty (TFLite, on-device)
- Stories come from templates (later replaced by LSTM)
