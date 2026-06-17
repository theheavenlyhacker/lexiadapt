# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LexiAdapt is an offline-first AI reading tutor for ASEAN children (Grades 1–3), built with Flutter. It targets Android, iOS, web, macOS, Windows, and Linux. Uses Dart SDK ^3.12.2 and Material Design 3.

The AI stack (planned) includes Whisper-tiny (INT4), DRL with PPO, LSTM narrative synthesis, and Federated Learning — all running on-device for privacy and offline capability.

## Common Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Run (debug mode)
flutter run -d chrome        # Web
flutter run -d linux         # Linux desktop
flutter test                 # Run all tests
flutter analyze              # Static analysis
flutter build apk            # Build Android release
flutter build linux          # Build Linux release
```

## Architecture (Feature-First)

```
lib/
├── main.dart                           # Entry point
├── app.dart                            # MaterialApp configuration
├── core/                               # Shared across all features
│   ├── theme/app_colors.dart           # Centralized color palette
│   ├── widgets/                        # NatureBackground, LexiAdaptLogo, TopBar, SectionHeader
│   └── painters/                       # HillsPainter, AreaChartPainter, WaveformPainter
├── features/
│   ├── auth/                           # Role selection + login
│   │   ├── screens/
│   │   └── widgets/
│   ├── student/                        # Student dashboard, reading, progress, rewards, settings
│   │   ├── screens/
│   │   └── widgets/
│   └── teacher/                        # Teacher sidebar, class overview, learner view, rewards manager
│       ├── screens/
│       └── widgets/
```

Each feature will gain `domain/` and `data/` layers when AI integration begins. See `docs/TECHNICAL_DOCUMENTATION.md` for the full planned architecture.

## Key Patterns

- **AppColors**: All colors centralized in `core/theme/app_colors.dart`
- **CustomPainters**: Charts and visualizations use zero external dependencies
- **No state management library yet**: Screens use StatefulWidget; will add Riverpod/Bloc when data layer arrives
- **Hex colors with alpha**: Use `Color(0xAARRGGBB)` or `Color.fromRGBO()` — avoid deprecated `withOpacity()`

## Linting

Uses `package:flutter_lints/flutter.yaml` (configured in `analysis_options.yaml`). Run `flutter analyze` to check for issues. Current target: **zero issues**.
