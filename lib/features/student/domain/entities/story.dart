enum StoryCategory {
  animals('Animals', 'assets/images/cat_animals.png'),
  favorites('Favorites', 'assets/images/cat_favorites.png'),
  fantasy('Fantasy', 'assets/images/cat_fantasy.png'),
  nature('Nature', null),
  learning('Learning', 'assets/images/cat_learning.png'),
  adventure('Adventure', 'assets/images/cat_adventure.png');

  final String label;
  final String? asset;
  const StoryCategory(this.label, this.asset);
}

class Story {
  final String id;
  final String text;
  final StoryCategory category;
  final double difficulty;
  final List<String> highlightWords;
  final String imageAsset;

  const Story({
    required this.id,
    required this.text,
    required this.category,
    required this.difficulty,
    this.highlightWords = const [],
    this.imageAsset = 'assets/images/story_fishing.png',
  });
}
