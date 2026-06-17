import 'package:flutter/material.dart';
import 'package:lexiadapt/core/di/service_locator.dart';
import 'package:lexiadapt/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final services = createServices();
  runApp(LexiAdaptApp(services: services));
}
