# LexiAdapt — Technical Documentation

## 1. Project Overview

**LexiAdapt** is an offline-first AI reading tutor targeting Grade 1–3 students across the ASEAN region. It runs entirely on-device using quantized NLP models, enabling personalized literacy instruction on low-cost smartphones (2GB RAM, entry-level ARM processors) without internet connectivity.

**Track:** AI for Education | **Team:** NCF–AmberWave | **Institution:** Naga College Foundation Inc.

### Problem Statement

- 70% of Philippine students lack basic reading skills (SEA-PLM 2024)
- 26%+ of the ASEAN population remains offline
- Existing EdTech tools require cloud connectivity and ignore regional dialects

### Solution

LexiAdapt delivers a high-performance AI tutor that:
- Functions 100% offline via INT4-quantized Whisper AI and NLP models
- Adapts to local dialects through Federated Learning
- Personalizes difficulty in real-time using Deep Reinforcement Learning (DRL/PPO)
- Generates culturally relevant stories with LSTM narrative synthesis
- Keeps all sensitive student audio on-device (privacy-by-design)

---

## 2. Architecture Overview

### 2.1 Folder Structure (Feature-First)

```
lib/
├── main.dart                                    # Entry point
├── app.dart                                     # MaterialApp configuration
├── core/                                        # Shared across all features
│   ├── theme/
│   │   └── app_colors.dart                      # Centralized color palette
│   ├── widgets/
│   │   ├── nature_background.dart               # Sky + hills animated background
│   │   ├── lexiadapt_logo.dart                  # Rainbow gradient brand logo
│   │   ├── top_bar.dart                         # App icon + language selector
│   │   └── section_header.dart                  # Reusable section title
│   └── painters/
│       ├── hills_painter.dart                   # CustomPainter for landscape hills
│       ├── area_chart_painter.dart              # Line/area chart (progress, accuracy)
│       └── waveform_painter.dart                # Audio waveform visualization
├── features/
│   ├── auth/                                    # Authentication flow
│   │   ├── screens/
│   │   │   ├── role_selection_screen.dart        # Student vs Teacher selection
│   │   │   └── login_screen.dart                 # Username/password + social login
│   │   └── widgets/
│   │       └── role_card.dart                    # Gradient role selection card
│   ├── student/                                 # Student-facing features
│   │   ├── screens/
│   │   │   ├── student_home_screen.dart          # Main dashboard with 4 actions
│   │   │   ├── category_screen.dart              # 2×3 reading category grid
│   │   │   ├── reading_session_screen.dart       # Story + audio + mic input
│   │   │   ├── student_progress_screen.dart      # Accuracy chart, level, skills
│   │   │   ├── student_rewards_screen.dart       # Badges and achievements
│   │   │   └── student_settings_screen.dart      # Language + microphone settings
│   │   └── widgets/
│   │       └── home_button.dart                  # Gradient action button
│   └── teacher/                                 # Teacher-facing features
│       ├── screens/
│       │   ├── teacher_home_screen.dart           # Sidebar + page container
│       │   ├── class_overview_page.dart           # Stats, student list, weekly chart
│       │   ├── learner_overview_screen.dart       # Individual learner profile + chart
│       │   └── rewards_manager_screen.dart        # Badge management + encouragement
│       └── widgets/                              # (Future teacher-specific widgets)
```

### 2.2 Layer Responsibilities

| Layer | Purpose | Current Status |
|-------|---------|----------------|
| **Presentation** (`screens/`, `widgets/`) | UI rendering, user interaction | ✅ Implemented |
| **Domain** (`domain/`) | Entities, use cases, repository interfaces | 🔲 Planned for AI integration |
| **Data** (`data/`) | SQLite/Realm repos, Whisper bridge, FL client | 🔲 Planned for AI integration |

---

## 3. UI/UX Layer — Screen Inventory

### 3.1 Auth Flow (2 screens)

| Screen | Purpose | Tech Doc Alignment |
|--------|---------|-------------------|
| **Role Selection** | Student/Teacher role picker | Entry point per user type |
| **Login** | Credentials + social auth | Supports offline local accounts (future) |

### 3.2 Student Flow (6 screens)

| Screen | Purpose | Tech Doc Alignment |
|--------|---------|-------------------|
| **Student Home** | 4-button dashboard | Central navigation hub |
| **Choose a Category** | 6 reading themes (Animals, Family, Nature, etc.) | Maps to LSTM story categories |
| **Reading Session** | Story display + audio waveform + mic button | **Core AI surface**: Whisper-tiny processes mic input; DRL adjusts difficulty; highlighted words show phonetic focus |
| **My Progress** | Accuracy chart, star level, skill bars (Phonics, Vocabulary, Comprehension, Fluency) | Maps directly to HMM learner success metrics and DRL skill tracking |
| **Rewards** | Badges + achievement checklist | Micro-Gamification Feedback output from tech doc |
| **Settings** | 8 ASEAN languages + mic/speech config | Regional Dialect Biometrics input; language selection drives Whisper model variant |

### 3.3 Teacher Flow (4 screens)

| Screen | Purpose | Tech Doc Alignment |
|--------|---------|-------------------|
| **Teacher Home** | Sidebar navigation (Class Overview / Settings) | Teacher management portal |
| **Class Overview** | Aggregate stats (avg accuracy, student count, active today) + per-student progress bars + weekly chart | Federated Learning aggregated metrics |
| **Learner's Overview** | Individual student profile, accuracy-over-time chart, session/badge counts | Maps to HMM "failure point" analysis per learner |
| **Rewards Manager** | Grant progress, badge inventory, recent achievements, encouragement action | Teacher-controlled gamification layer |

---

## 4. AI Architecture — Implementation Insights

This section maps the technical document's AI components to concrete implementation plans for the Flutter app.

### 4.1 On-Device AI Pipeline

```
┌─────────────────────────────────────────────────────┐
│                  READING SESSION                     │
│                                                      │
│  Student speaks → Mic captures audio                 │
│       ↓                                              │
│  Whisper-tiny (INT4) → phoneme extraction + WPM      │
│       ↓                                              │
│  HMM → identifies "failure points" per word          │
│       ↓                                              │
│  DRL (PPO) → adjusts story difficulty in real-time   │
│       ↓                                              │
│  LSTM → generates next story weaving "trouble words" │
│       ↓                                              │
│  UI updates → new story + scaffolding + rewards      │
└─────────────────────────────────────────────────────┘
```

### 4.2 Component Integration Points

#### Whisper-tiny (Speech-to-Text)
- **What:** INT4-quantized Whisper model for phoneme-level pronunciation analysis
- **Where in UI:** `ReadingSessionScreen` — mic button triggers recording; waveform shows real-time audio
- **Flutter integration:** Use `tflite_flutter` or `onnxruntime` plugin to run the quantized model; bridge via platform channels if needed
- **Key metrics output:** Words Per Minute (WPM), phoneme accuracy score, reading cadence
- **File to create:** `lib/features/student/data/speech_recognition_service.dart`

#### Hidden Markov Model (Learner Tracking)
- **What:** Tracks student progress, maps vocabulary retention and letter-sound failure points
- **Where in UI:** `StudentProgressScreen` skill bars (Phonics, Vocabulary, Comprehension, Fluency) directly visualize HMM state
- **Flutter integration:** Pure Dart implementation possible; stores state in SQLite
- **File to create:** `lib/features/student/domain/learner_model.dart`

#### Deep Reinforcement Learning (PPO)
- **What:** Proximal Policy Optimization agent that dynamically adjusts lesson difficulty
- **Where in UI:** Controls which story appears in `ReadingSessionScreen`; adjusts word complexity shown to student
- **Flutter integration:** Pre-trained model exported to TFLite/ONNX; inference runs on each session completion
- **Key signals:** Student accuracy per story, time-to-utterance, HMM failure count
- **File to create:** `lib/features/student/data/difficulty_engine.dart`

#### LSTM Narrative Synthesis
- **What:** Generates personalized "Micro-Stories" that weave the student's trouble words into culturally relevant narratives
- **Where in UI:** Story text in `ReadingSessionScreen` is the LSTM output; `CategoryScreen` themes seed the generation
- **Flutter integration:** Quantized LSTM model via TFLite; vocabulary trees stored in SQLite/Realm
- **File to create:** `lib/features/student/data/story_generator.dart`

#### Federated Learning Client
- **What:** Updates local model weights from dialectal successes without transmitting raw audio
- **Where in UI:** Silent background process; `Settings` shows sync status; `ClassOverviewPage` shows aggregated FL metrics
- **Flutter integration:** Lightweight FL client that syncs weight deltas during Wi-Fi/4G connectivity (Lazy Sync protocol)
- **File to create:** `lib/core/services/federated_learning_client.dart`

### 4.3 Local Data Layer (Planned)

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Student profiles | SQLite / Realm | Offline learner metadata, progress history |
| Vocabulary trees | SQLite | Comprehensive word-phoneme mappings per language |
| Offline thesaurus | Bundled asset | Synonym/scaffolding lookup without internet |
| Phonetic library | Bundled audio files | 10,000-word corrective pronunciation library |
| Model weights | Local filesystem | INT4 Whisper, LSTM, DRL model files (<100MB total) |

### 4.4 Future `data/` and `domain/` Structure

When AI integration begins, each feature gains these layers:

```
features/student/
├── screens/          # ✅ Already built
├── widgets/          # ✅ Already built
├── domain/
│   ├── entities/
│   │   ├── learner_profile.dart
│   │   ├── reading_session.dart
│   │   └── achievement.dart
│   ├── repositories/
│   │   ├── learner_repository.dart        # Interface
│   │   └── story_repository.dart          # Interface
│   └── usecases/
│       ├── evaluate_reading.dart
│       └── get_next_story.dart
└── data/
    ├── datasources/
    │   ├── local_database.dart             # SQLite/Realm
    │   └── speech_recognition_service.dart # Whisper bridge
    ├── models/
    │   ├── learner_profile_model.dart
    │   └── reading_session_model.dart
    └── repositories/
        ├── learner_repository_impl.dart
        └── story_repository_impl.dart
```

---

## 5. Design Constraints (from Tech Doc)

| Constraint | Target |
|------------|--------|
| App size | < 50MB |
| Screen target | 720p (entry-level smartphones) |
| RAM budget | 2GB max |
| AI inference latency | < 100ms |
| Model precision | INT4 quantization |
| Privacy | 100% on-device audio processing |
| Connectivity | Full offline functionality; Lazy Sync when connected |
| Legal compliance | Philippine RA 10173, Indonesian PDP Law |
| Languages | 8 ASEAN languages (English, Tagalog, Tiếng Việt, Indonesia, ภาษาไทย, Burmese, Myanmar, Japanese) |

---

## 6. Development Roadmap Alignment

| Sprint | Period | Focus | UI Status |
|--------|--------|-------|-----------|
| Sprint 1 | May 1–15 | Speech corpora, FL pipeline | N/A (data) |
| Sprint 2 | May 16–31 | DRL agent, LSTM, Whisper | N/A (AI models) |
| Sprint 3 | Jun 1–15 | **Flutter UI**, SQLite, gamification | ✅ UI complete |
| Sprint 4 | Jun 16–25 | Benchmarking, security audit | 🔲 Pending |

---

## 7. Running the App

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Run on specific platform
flutter run -d chrome        # Web
flutter run -d linux          # Linux desktop
flutter run -d <device_id>   # Connected mobile device

# Static analysis
flutter analyze

# Run tests
flutter test

# Build release APK (target platform)
flutter build apk
```
