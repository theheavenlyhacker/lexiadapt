# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LexiAdapt is a Flutter application targeting Android, iOS, web, macOS, Windows, and Linux. It uses Dart SDK ^3.12.2 and Material Design.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Run on a specific device
flutter run -d chrome        # web
flutter run -d macos          # macOS desktop
flutter run -d linux          # Linux desktop

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Static analysis (linting)
flutter analyze

# Build release
flutter build apk             # Android
flutter build ios              # iOS
flutter build web              # Web
flutter build macos            # macOS
flutter build linux            # Linux
```

## Architecture

This is currently a single-file Flutter app (`lib/main.dart`) with the default counter template. As the project grows, organize code under `lib/` following standard Flutter conventions.

## Linting

Uses `package:flutter_lints/flutter.yaml` (configured in `analysis_options.yaml`). Run `flutter analyze` to check for issues.
