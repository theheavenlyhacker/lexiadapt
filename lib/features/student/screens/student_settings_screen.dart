import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/core/widgets/section_header.dart';
import 'package:lexiadapt/features/auth/screens/role_selection_screen.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/profile_notifier.dart';

class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({super.key});

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  String _selectedLanguage = 'English';
  bool _micEnabled = true;

  static const _languages = [
    {'name': 'English', 'icon': Icons.language},
    {'name': 'Tagalog', 'icon': Icons.translate},
    {'name': 'Tiếng Việt', 'icon': Icons.translate},
    {'name': 'Indonesia', 'icon': Icons.translate},
    {'name': 'ภาษาไทย', 'icon': Icons.translate},
    {'name': 'Burmese', 'icon': Icons.translate},
    {'name': 'Myanmar', 'icon': Icons.translate},
    {'name': 'Japanese', 'icon': Icons.translate},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Settings',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const SectionHeader(
              title: 'Multi-Language Support',
              subtitle:
                  'Choose your language. This will translate\nstories for you.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _languages.map((lang) {
                final selected = _selectedLanguage == lang['name'];
                return GestureDetector(
                  onTap: () => setState(
                      () => _selectedLanguage = lang['name'] as String),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: selected
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300),
                      boxShadow: selected
                          ? const [
                              BoxShadow(
                                  color: Color(0x4D5B9BD5),
                                  blurRadius: 8,
                                  offset: Offset(0, 2))
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(lang['icon'] as IconData,
                            size: 16,
                            color: selected
                                ? Colors.white
                                : Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(lang['name'] as String,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textDark)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            const SectionHeader(
              title: 'Microphone & Speech',
              subtitle:
                  'Configure your microphone for read-aloud exercises.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  _settingsRow(
                    icon: Icons.mic,
                    label: 'Enable Microphone',
                    trailing: Switch(
                      value: _micEnabled,
                      onChanged: (v) => setState(() => _micEnabled = v),
                      activeTrackColor: AppColors.primaryBlue,
                    ),
                  ),
                  const Divider(height: 24),
                  _settingsRow(
                    icon: Icons.volume_up,
                    label: 'Speech Feedback',
                    trailing: Switch(
                      value: true,
                      onChanged: (v) {},
                      activeTrackColor: AppColors.primaryBlue,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Icon(Icons.speed, color: Colors.grey[700], size: 22),
                      const SizedBox(width: 10),
                      const Text('Reading Speed',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text('Normal',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[500])),
                      Icon(Icons.chevron_right,
                          color: Colors.grey[400], size: 22),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<ProfileNotifier>().logout();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RoleSelectionScreen()),
                      (_) => false);
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('Log Out',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF5350),
                  side: const BorderSide(color: Color(0xFFEF5350)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _settingsRow(
      {required IconData icon,
      required String label,
      required Widget trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 22),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
        trailing,
      ],
    );
  }
}
