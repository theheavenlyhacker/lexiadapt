import 'package:flutter/material.dart';
import 'package:lexiadapt/features/auth/screens/role_selection_screen.dart';

class LexiAdaptApp extends StatelessWidget {
  const LexiAdaptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LexiAdapt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const RoleSelectionScreen(),
    );
  }
}
