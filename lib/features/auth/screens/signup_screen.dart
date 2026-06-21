import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/core/widgets/nature_background.dart';
import 'package:lexiadapt/core/widgets/lexiadapt_logo.dart';
import 'package:lexiadapt/core/widgets/top_bar.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/profile_notifier.dart';
import 'package:lexiadapt/features/student/screens/student_home_screen.dart';
import 'package:lexiadapt/features/teacher/screens/teacher_home_screen.dart';

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() => _error = 'All fields are required');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await context
        .read<ProfileNotifier>()
        .signUp(name, username, password, widget.role);

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _error = result;
        _loading = false;
      });
      return;
    }

    final destination = widget.role == 'student'
        ? const StudentHomeScreen()
        : const TeacherHomeScreen();
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => destination), (_) => false);
  }

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
                const LexiAdaptLogo(widthFraction: 0.55),
                const SizedBox(height: 20),
                const Text('Create Account',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(
                    widget.role == 'student'
                        ? 'Start your reading journey today!'
                        : 'Set up your teacher account.',
                    style:
                        const TextStyle(fontSize: 14, color: AppColors.deepBlue)),
                const SizedBox(height: 24),
                _buildTextField(
                  icon: Icons.badge_outlined,
                  hint: 'Display Name',
                  controller: _nameController,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  icon: Icons.person_outline,
                  hint: 'Username',
                  controller: _usernameController,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  icon: Icons.lock_outline,
                  hint: 'Password',
                  controller: _passwordController,
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
                const SizedBox(height: 14),
                _buildTextField(
                  icon: Icons.lock_outline,
                  hint: 'Confirm Password',
                  controller: _confirmController,
                  obscure: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: Colors.grey),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x1AEF5350),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x4DEF5350)),
                    ),
                    child: Text(_error!,
                        style: const TextStyle(
                            color: Color(0xFFEF5350), fontSize: 13)),
                  ),
                ],
                const SizedBox(height: 24),
                _buildSignUpButton(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[600])),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Log in',
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

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.success, AppColors.successDark]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
              color: Color(0x6666BB6A),
              blurRadius: 12,
              offset: Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _loading ? null : _signUp,
          borderRadius: BorderRadius.circular(30),
          splashColor: const Color(0x33FFFFFF),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_loading)
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                else ...[
                  const Icon(Icons.person_add, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  const Text('Sign Up',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
