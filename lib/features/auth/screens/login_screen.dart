import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/core/widgets/nature_background.dart';
import 'package:lexiadapt/core/widgets/lexiadapt_logo.dart';
import 'package:lexiadapt/core/widgets/top_bar.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/profile_notifier.dart';
import 'package:lexiadapt/features/student/screens/student_home_screen.dart';
import 'package:lexiadapt/features/teacher/screens/teacher_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  final _usernameController = TextEditingController(text: 'Juan');
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NatureBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const TopBar(),
                const SizedBox(height: 16),
                const LexiAdaptLogo(height: 52),
                const SizedBox(height: 24),
                const Text('Welcome!',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 4),
                const Text('Log in to continue your learning journey.',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.deepBlue)),
                const SizedBox(height: 28),
                _buildTextField(
                  icon: Icons.person_outline,
                  hint: 'Username',
                  controller: _usernameController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  icon: Icons.lock_outline,
                  hint: 'Password',
                  obscure: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: Colors.grey),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                        activeColor: AppColors.teal,
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Remember me',
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 20),
                Text('continue with',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(Icons.g_mobiledata, AppColors.google),
                    const SizedBox(width: 16),
                    _socialButton(Icons.facebook, AppColors.facebook),
                    const SizedBox(width: 16),
                    _socialButton(Icons.apple, Colors.black),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[600])),
                    GestureDetector(
                      child: const Text('Sign up',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBlue)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('© LexiAdapt 2026 All Rights Reserved',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xD9FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x8080CBC4)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.teal, size: 22),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: () async {
        final name = _usernameController.text.trim();
        if (name.isEmpty) return;
        final id = name.toLowerCase().replaceAll(' ', '_');
        await context.read<ProfileNotifier>().loadOrCreate(id, name);
        if (!mounted) return;
        final destination = widget.role == 'student'
            ? const StudentHomeScreen()
            : const TeacherHomeScreen();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => destination));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.loginYellow, AppColors.orange]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
                color: Color(0x66FF9800),
                blurRadius: 12,
                offset: Offset(0, 5)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_open, color: AppColors.loginBrown, size: 20),
            SizedBox(width: 10),
            Text('Log in',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.loginBrown)),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}
