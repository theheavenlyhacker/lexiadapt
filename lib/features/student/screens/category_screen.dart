import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/features/student/domain/entities/story.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/session_notifier.dart';
import 'package:lexiadapt/features/student/screens/reading_session_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  static const _categoryColors = {
    StoryCategory.animals: Color(0xFFFF8A65),
    StoryCategory.favorites: Color(0xFFEF5350),
    StoryCategory.fantasy: Color(0xFF42A5F5),
    StoryCategory.nature: Color(0xFF66BB6A),
    StoryCategory.learning: Color(0xFFFFCA28),
    StoryCategory.adventure: Color(0xFF8D6E63),
  };

  @override
  Widget build(BuildContext context) {
    final categories = StoryCategory.values;
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
        title: const Text('Choose a Category',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Center(
              child: Text(
                  'Pick a category to find a reading\ntheme for your story!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final c = _categoryColors[cat] ?? const Color(0xFF90A4AE);
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 2,
                    shadowColor: const Color(0x1A000000),
                    child: InkWell(
                      onTap: () async {
                        try {
                          await context.read<SessionNotifier>().startSession(cat);
                        } catch (e) {
                          debugPrint('Session start error: $e');
                        }
                        if (context.mounted) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingSessionScreen()));
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (cat.asset != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                cat.asset!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.contain,
                                cacheWidth: 140,
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(c.r.toInt(),
                                    c.g.toInt(), c.b.toInt(), 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.eco, color: c, size: 34),
                            ),
                          const SizedBox(height: 10),
                          Text(cat.label,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
