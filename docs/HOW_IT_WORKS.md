# How LexiAdapt Works — A Complete Guide

Written so that anyone — even without a tech background — can understand exactly how the system works, what each piece does, and why we built it this way.

---

## What Is LexiAdapt?

LexiAdapt is a **reading tutor app** for children in Grades 1–3. The child reads a story aloud, and the app:

1. **Listens** to their voice using the phone's microphone
2. **Figures out** which words they said correctly and which they struggled with
3. **Adjusts** the next story to practice the words they got wrong
4. **Tracks** their progress over time
5. **Gives badges** when they hit milestones

All of this happens **on the phone itself** — no internet needed after the first setup. This matters because many children in the Philippines and Southeast Asia don't have reliable internet.

---

## The Big Picture

Think of LexiAdapt as four workers in a factory, each doing one job:

```
┌──────────────────────────────────────────────────────┐
│                    THE READING LOOP                    │
│                                                        │
│   📖 Story appears on screen                           │
│       ↓                                                │
│   🎙️ Child reads it aloud                              │
│       ↓                                                │
│   🤖 WHISPER listens and writes down what it heard     │
│       ↓                                                │
│   📊 HMM figures out which words are still hard        │
│       ↓                                                │
│   🎯 DRL AGENT decides: make it easier or harder?      │
│       ↓                                                │
│   📝 STORY GENERATOR creates a new story with the      │
│      hard words mixed in for more practice              │
│       ↓                                                │
│   📖 New story appears → loop repeats                  │
└──────────────────────────────────────────────────────┘
```

Each of these four workers is an **AI model** — a program that was trained to do one specific task really well.

---

## The Four AI Workers, Explained Simply

### Worker 1: Whisper (The Listener)

**What it does:** Converts the child's voice into text.

**How it works in plain English:**
- The phone records the child's voice as a WAV audio file
- Whisper (made by OpenAI) is a neural network that has "listened" to thousands of hours of people speaking English
- It learned patterns like: "when I hear these specific sound waves, the person is probably saying the word 'cat'"
- We use the "tiny" version (39MB) because it's small enough to run on a cheap phone
- The model is quantized to INT8 — imagine compressing a photo from 100MB to 12MB. It's slightly lower quality but works 8x faster and uses 4x less memory

**What it produces:** A text transcript. For example:
- Child says: "The cat sat on the mat"
- Whisper outputs: `"the cat sat on the mat"`

**Where in the code:**
- `lib/features/student/data/services/whisper_speech_recognition_service.dart`
- Uses the `sherpa_onnx` package which runs the Whisper ONNX model on-device
- Models are downloaded once (~98MB) and cached permanently

---

### Worker 2: HMM (The Memory)

**What it does:** Remembers which words each child finds difficult.

**How it works in plain English:**

HMM stands for **Hidden Markov Model**. Don't let the name scare you — it's actually simple. For each word the child has ever seen, the HMM keeps track of three numbers that add up to 1.0:

```
Word: "beautiful"
  Struggling:  0.70  (70% chance they still can't read it)
  Learning:    0.20  (20% chance they're getting better)
  Mastered:    0.10  (10% chance they've got it)
```

Every time the child reads a story:
- If they got "beautiful" **wrong**: the "Struggling" number goes UP
- If they got it **right but slowly**: the "Learning" number goes UP
- If they got it **right and fast**: the "Mastered" number goes UP

Over time, as the child practices, the numbers shift:
```
After 10 practices:
  Struggling:  0.05
  Learning:    0.15
  Mastered:    0.80  ← they've got it!
```

**Why this matters:** The HMM tells the Story Generator which words to include in the next story. If "beautiful" is still at 70% Struggling, it will appear in the next story for more practice.

**Where in the code:**
- `lib/features/student/domain/learner_hmm.dart` — pure math, no external AI needed
- The transition probabilities (how likely a word moves from Struggling to Learning) are defined as a 3×3 matrix

---

### Worker 3: DRL Agent (The Difficulty Adjuster)

**What it does:** Decides whether the next story should be easier, the same, or harder.

**How it works in plain English:**

DRL stands for **Deep Reinforcement Learning**. Think of it like training a dog:
- The "dog" (our AI agent) tries different actions
- If the child's accuracy goes up → the agent gets a "treat" (positive reward)
- If the child gets frustrated (3+ failures in a row) → the agent gets a "penalty"
- After thousands of practice sessions (simulated), the agent learns the best strategy

The agent was trained using **PPO (Proximal Policy Optimization)** — a specific training method that prevents the agent from changing its behavior too drastically in one step (like how you wouldn't change a recipe by adding 10x more salt — you'd try a pinch first).

**What it decides:** One of 5 actions:
| Action | Meaning | When it's chosen |
|--------|---------|-----------------|
| 0 | Much easier | Child is frustrated (3+ failures) |
| 1 | Slightly easier | Accuracy below 50% |
| 2 | Stay the same | Accuracy is in the sweet spot (60-85%) |
| 3 | Slightly harder | Doing well (accuracy > 75%) |
| 4 | Much harder | Crushing it (accuracy > 85%, 3+ successes in a row) |

The "sweet spot" of 60-85% accuracy is called the **Zone of Proximal Development** — a real educational concept that says children learn best when material is challenging but not impossible.

**Training:** We trained this agent using a simulated classroom environment (`ai/scripts/reading_env.py`) where a virtual student's accuracy goes up or down based on how well the difficulty matches their ability. After 500,000 simulated reading sessions, the agent learned the optimal strategy.

**Where in the code:**
- `lib/features/student/data/services/onnx_difficulty_service.dart` — the on-device decision logic
- `ai/scripts/train_drl.py` — the Python training script
- `ai/scripts/reading_env.py` — the simulated classroom environment

---

### Worker 4: Story Generator (The Writer)

**What it does:** Creates a personalized story for each child that includes their trouble words.

**How it works in plain English:**

Currently, we use a **template-based approach**:

1. We have ~30 story templates organized by category (Animals, Fantasy, Adventure, etc.) and difficulty level (easy, medium, hard)
2. Each template has slots: `"The {0} cat sat on the {1} mat"`
3. The generator picks a template matching the DRL's difficulty level
4. It fills the slots with the child's trouble words from the HMM

Example:
```
HMM says trouble words are: ["beautiful", "mountain"]
DRL says difficulty: medium
Category: Nature

Template: "A {0} river flowed through the valley. 
           Children played near the {1} rocks."

Result: "A beautiful river flowed through the valley. 
         Children played near the mountain rocks."
```

**Future improvement:** We trained an LSTM (Long Short-Term Memory) neural network to generate original stories from scratch. This model reads thousands of children's books and learns patterns like "after 'The brave girl climbed the' the next word is often 'tall' or 'big' or 'steep'." The LSTM model is in `ai/scripts/train_lstm.py` but not yet deployed on-device.

**Where in the code:**
- `lib/features/student/data/services/template_story_generator_service.dart`
- Templates are hardcoded in the Dart file (no external data needed)

---

## How the Pieces Connect — Step by Step

Here's exactly what happens when a child uses the app:

### Step 1: Login
- Child enters their name → app creates a profile in SQLite (a tiny database stored on the phone)
- If they've used the app before, it loads their saved progress

### Step 2: Choose a Category
- Child picks "Animals" → the app tells the Story Generator to make an animal story
- The HMM provides the child's current trouble words
- The DRL provides the current difficulty level
- A story is generated and displayed

### Step 3: Read Aloud
- Child taps the microphone button → phone starts recording audio
- A live visualizer shows bouncing bars so they can see the mic is working
- They read the story text out loud
- They tap the mic again to stop

### Step 4: AI Evaluation (happens in ~2 seconds)
```
Recording saved as WAV file (16kHz, mono)
    ↓
Whisper loads the audio file
    ↓
Whisper converts speech to text: "the cat sat on the mat"
    ↓
Compare against expected text word-by-word:
    Expected: [the, little, cat, sat, on, the, mat]
    Heard:    [the, cat, sat, on, the, mat]
    Result:   "little" was missed → it's a trouble word
    ↓
HMM updates: "little" moves toward Struggling
              "cat", "sat", "mat" move toward Mastered
    ↓
Accuracy calculated: 6/7 = 85.7%
WPM calculated: 7 words / 3.2 seconds × 60 = 131 WPM
    ↓
DRL decides: accuracy is 85.7% with 2 successes → Action 3 (slightly harder)
    ↓
Story Generator: creates next story at higher difficulty, 
                  includes "little" as a trouble word
    ↓
Results shown: 86% accuracy, 131 WPM, trouble word "little" highlighted in red
```

### Step 5: Next Story
- Child taps "Next Story" → the pre-generated story appears
- The loop repeats from Step 3

### Step 6: Progress Tracking
- Every session is saved to SQLite with: accuracy, WPM, trouble words, timestamp
- The Progress screen reads this history and shows charts
- Achievements are checked after each session (e.g., "Read 10 stories" → unlock Bookworm badge)

---

## The App Architecture — Where Everything Lives

```
lexiadapt/
│
├── lib/                              ← THE FLUTTER APP (what runs on the phone)
│   ├── main.dart                     ← Starting point. Initializes everything.
│   ├── app.dart                      ← Sets up Provider (state management)
│   │
│   ├── core/                         ← Shared stuff used everywhere
│   │   ├── database/                 ← SQLite database (saves progress)
│   │   ├── services/                 ← Audio recorder, FL client
│   │   ├── theme/                    ← Colors used in the UI
│   │   ├── widgets/                  ← Reusable UI pieces (logo, background)
│   │   └── painters/                 ← Custom chart drawings
│   │
│   └── features/                     ← Organized by feature
│       ├── auth/                     ← Login screens
│       ├── student/                  ← Everything the student sees
│       │   ├── domain/               ← THE BRAIN (pure logic, no UI)
│       │   │   ├── entities/         ← Data shapes (LearnerProfile, Story, etc.)
│       │   │   ├── services/         ← Interfaces (what each AI worker must do)
│       │   │   ├── repositories/     ← Interface for saving/loading data
│       │   │   └── learner_hmm.dart  ← THE HMM (word mastery tracker)
│       │   ├── data/                 ← THE WORKERS (actual implementations)
│       │   │   ├── services/
│       │   │   │   ├── whisper_speech_recognition_service.dart  ← WHISPER
│       │   │   │   ├── onnx_difficulty_service.dart             ← DRL AGENT
│       │   │   │   ├── template_story_generator_service.dart    ← STORY GEN
│       │   │   │   └── mock_*.dart                              ← Test fakes
│       │   │   └── repositories/
│       │   │       └── learner_repository_impl.dart  ← SQLite data layer
│       │   ├── presentation/         ← STATE MANAGEMENT
│       │   │   └── notifiers/
│       │   │       ├── session_notifier.dart   ← Orchestrates the reading loop
│       │   │       ├── profile_notifier.dart   ← Manages learner data
│       │   │       └── progress_notifier.dart  ← Computes charts
│       │   └── screens/              ← THE UI (what the user sees)
│       │       ├── reading_session_screen.dart  ← Main reading screen
│       │       ├── student_progress_screen.dart
│       │       ├── student_rewards_screen.dart
│       │       └── ...
│       └── teacher/                  ← Everything the teacher sees
│
├── ai/                               ← PYTHON TRAINING SCRIPTS (run on your laptop)
│   ├── scripts/
│   │   ├── train_drl.py              ← Trains the DRL difficulty agent
│   │   ├── train_lstm.py             ← Trains the story generator
│   │   ├── finetune_whisper.py       ← Fine-tunes Whisper for kids' voices
│   │   ├── reading_env.py            ← Simulated classroom for DRL training
│   │   └── export_*.py               ← Convert models for mobile
│   ├── models/                       ← Trained model files
│   ├── data/stories/                 ← Training stories for LSTM
│   └── server/                       ← Federated Learning server
│
├── assets/
│   ├── images/                       ← UI artwork (compressed PNGs)
│   └── models/
│       └── ppo_policy.onnx           ← Trained DRL model (1.9KB)
│
└── test/                             ← Automated tests
```

---

## Key Concepts Explained for Beginners

### What is a Neural Network?
Imagine a brain made of math. It has layers of "neurons" (numbers) connected by "weights" (more numbers). When you feed data in one end (like audio), the numbers multiply and add through the layers, and a result comes out the other end (like text). Training means adjusting the weights until the output is correct.

### What is Quantization?
Neural networks normally use high-precision numbers (32-bit floating point — like having 8 decimal places). Quantization shrinks them to 8-bit integers (like rounding to whole numbers). The model gets 4x smaller and 4x faster, with only a tiny accuracy loss. This is how Whisper (normally 39MB) shrinks to fit on a phone.

### What is ONNX?
ONNX (Open Neural Network Exchange) is a universal format for AI models. It's like PDF for documents — you can create a model in PyTorch (Python), export it to ONNX, and run it on a phone, a browser, or a server. Our Whisper and DRL models are stored as ONNX files.

### What is SQLite?
A tiny database that lives inside a single file on the phone. No server needed. We use it to save learner profiles, reading session history, word mastery states, and achievements. When the app restarts, everything is still there.

### What is Provider?
A Flutter state management system. When the AI produces a new reading result, Provider automatically updates every screen that's showing related data — the progress chart, the rewards list, the story text — without manually telling each screen to refresh.

### What is Federated Learning?
A way to improve AI models without collecting anyone's private data. Instead of sending audio recordings to a server, each phone trains the model locally and only sends the mathematical improvements (weight deltas). The server averages everyone's improvements and sends the better model back. No one ever hears another child's voice. This is planned but not yet active.

---

## How the AI Models Were Trained

### DRL Agent Training (5 minutes on any laptop)

```bash
cd ai/scripts
python3 train_drl.py --timesteps 500000
```

What happens:
1. Creates a virtual classroom (`ReadingTutorEnv`)
2. The virtual student has random ability scores
3. The AI agent tries different difficulty actions (0-4)
4. If the virtual student's accuracy improves → reward +1
5. If the student gets frustrated → penalty -1
6. After 500,000 tries, the agent learns the optimal strategy
7. Model saved as `ppo_policy.onnx` (1.9KB — tiny!)

### LSTM Story Generator Training (5 minutes)

```bash
python3 train_lstm.py --data ../data/stories/ --epochs 50
```

What happens:
1. Reads all the `.txt` story files
2. Builds a vocabulary (every unique word gets a number)
3. Feeds sequences of words into the LSTM network
4. The network learns to predict "what word comes next"
5. After 50 passes through all the stories, it can generate new text
6. Quality depends heavily on how much training data you provide

### Whisper Fine-tuning (30 minutes with GPU)

```bash
python3 finetune_whisper.py --dataset librispeech --epochs 3
```

What happens:
1. Downloads LibriSpeech (thousands of people reading English books aloud)
2. For each audio clip, Whisper tries to predict the transcript
3. Compares its prediction to the real transcript
4. Adjusts its weights to be more accurate
5. After 3 passes through the data, it's significantly better at understanding speech

---

## Numbers That Matter

| Metric | Value | Why It Matters |
|--------|-------|---------------|
| App size | ~15MB (without AI models) | Fits on any phone |
| Whisper model | ~98MB (downloaded once) | Stored permanently, works offline |
| DRL model | 1.9KB | Basically free — bundled in the app |
| Whisper inference | ~2-3 seconds | Fast enough for a child to not lose interest |
| SQLite database | <1MB typically | Stores years of progress |
| Supported languages | 8 (English first) | Settings screen lets you switch |
| Target devices | 2GB RAM, 720p screen | Works on the cheapest smartphones |
| Privacy | 100% on-device | No audio ever leaves the phone |

---

## What's Real AI vs. What's Rules

Being transparent about what's running actual neural networks vs. simpler logic:

| Component | Type | Details |
|-----------|------|---------|
| **Whisper** (speech-to-text) | Real AI (neural network) | OpenAI's Whisper-tiny model running on-device via sherpa-onnx |
| **HMM** (word tracking) | Math formula | Not a neural network — just probability calculations in Dart |
| **DRL Agent** (difficulty) | Trained AI → converted to rules | Was trained as a neural network, but the learned behavior is now implemented as if/else rules that match the trained policy |
| **Story Generator** | Template engine | Not AI — fills word slots in pre-written story templates |
| **Progress Charts** | Custom drawing code | Flutter CustomPainter — pure math, no AI |
| **Achievement System** | Simple checks | "If sessions >= 10, unlock Bookworm badge" |

---

## Privacy & Security

1. **All audio stays on the phone.** The microphone recording is saved to a temporary file, processed by Whisper, and then deleted. It is never uploaded anywhere.

2. **No personal data is transmitted.** SQLite stores everything locally. The only network call is the one-time model download from HuggingFace.

3. **Federated Learning (planned)** would only send mathematical weight adjustments, never audio or text. Even the server can't reconstruct what any child said.

4. **Compliant with:** Philippine Data Privacy Act (RA 10173) and Indonesian PDP Law — because there's nothing to comply with when no data leaves the device.

---

## Glossary

| Term | Simple Definition |
|------|-------------------|
| **ASEAN** | Association of Southeast Asian Nations — the 10 countries this app targets |
| **DRL** | Deep Reinforcement Learning — AI that learns by trial and error |
| **Flutter** | Google's framework for building phone apps from one codebase |
| **HMM** | Hidden Markov Model — tracks probabilities of hidden states (like whether a child knows a word) |
| **INT8** | 8-bit integer — a compact number format that makes AI models smaller and faster |
| **LSTM** | Long Short-Term Memory — a type of neural network good at understanding sequences (like sentences) |
| **ONNX** | Open Neural Network Exchange — universal file format for AI models |
| **PPO** | Proximal Policy Optimization — a safe way to train reinforcement learning agents |
| **Provider** | Flutter's state management tool — keeps the UI in sync with data |
| **Quantization** | Compressing an AI model to use less memory (like JPEG for neural networks) |
| **sherpa-onnx** | A C++ library that runs ONNX models on phones efficiently |
| **SQLite** | A lightweight database that stores data in a single file |
| **WPM** | Words Per Minute — measures reading speed |
| **Whisper** | OpenAI's speech recognition model — converts voice to text |
| **ZPD** | Zone of Proximal Development — the difficulty sweet spot where learning is optimal |
