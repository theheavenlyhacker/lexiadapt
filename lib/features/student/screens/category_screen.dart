import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';
import 'package:lexiadapt/features/student/domain/entities/story.dart';
import 'package:lexiadapt/features/student/presentation/notifiers/session_notifier.dart';
import 'package:lexiadapt/features/student/screens/reading_session_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  static const _categories = [
    {'name': 'Animals', 'asset': 'assets/images/cat_animals.png', 'color': 0xFFFF8A65},
    {'name': 'Favorites', 'asset': 'assets/images/cat_favorites.png', 'color': 0xFFEF5350},
    {'name': 'Fantasy', 'asset': 'assets/images/cat_fantasy.png', 'color': 0xFF42A5F5},
    {'name': 'Nature', 'icon': Icons.eco, 'color': 0xFF66BB6A},
    {'name': 'Learning', 'asset': 'assets/images/cat_learning.png', 'color': 0xFFFFCA28},
    {'name': 'Adventure', 'asset': 'assets/images/cat_adventure.png', 'color': 0xFF8D6E63},
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
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final c = Color(cat['color'] as int);
                  final hasAsset = cat.containsKey('asset');
                  final categories = StoryCategory.values;
                  final storyCategory = i < categories.length ? categories[i] : StoryCategory.animals;
                  return GestureDetector(
                    onTap: () async {
                      try {
                        await context.read<SessionNotifier>().startSession(storyCategory);
                        if (context.mounted) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingSessionScreen()));
                        }
                      } catch (e) {
                        debugPrint('Session start error: $e');
                        if (context.mounted) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingSessionScreen()));
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 10,
                              offset: Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hasAsset)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                cat['asset'] as String,
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
                              child: Icon(cat['icon'] as IconData,
                                  color: c, size: 34),
                            ),
                          const SizedBox(height: 10),
                          Text(cat['name'] as String,
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
