import 'dart:math';
import 'package:lexiadapt/features/student/domain/entities/story.dart';
import 'package:lexiadapt/features/student/domain/services/story_generator_service.dart';

class TemplateStoryGeneratorService implements StoryGeneratorService {
  final _rng = Random();

  static const _templates = <StoryCategory, List<List<String>>>{
    StoryCategory.animals: [
      ['The {0} cat sat on the mat. It saw a {1} bird in the tree. The cat wanted to play with the bird all day.', 'easy'],
      ['A little dog found a {0} bone near the river. He was so {1}! He ran all the way home to show his friends.', 'easy'],
      ['The {0} elephant walked through the {1} forest. It found a lake and drank the cool water. All the animals came to watch.', 'medium'],
      ['One day, a {0} monkey climbed the tallest tree. From the top, it could see the {1} mountains. The monkey felt brave and happy.', 'medium'],
      ['In the {0} jungle, a tiger and a {1} rabbit became friends. They shared food and stories every evening under the stars.', 'hard'],
    ],
    StoryCategory.favorites: [
      ['I love my {0} toy. It makes me {1}. I play with it every day after school.', 'easy'],
      ['My favorite {0} color is blue. I paint {1} pictures with it. My teacher says they are beautiful.', 'easy'],
      ['The best day was when I got a {0} book. I read it under the {1} tree. Every page was a new adventure.', 'medium'],
      ['My {0} friend and I like to draw. We make {1} shapes and animals. Our art fills the whole wall.', 'medium'],
    ],
    StoryCategory.fantasy: [
      ['A {0} wizard found a magic wand. He turned a rock into a {1} flower. Everyone in the village cheered.', 'easy'],
      ['The {0} princess lived in a tall tower. She had a {1} dragon friend. Together they flew over the kingdom.', 'medium'],
      ['In a land of {0} dreams, a boy discovered a {1} door. Behind it was a world made of candy and stars.', 'medium'],
      ['The {0} fairy granted three wishes. The girl wished for a {1} garden, a kind heart, and a sunny day forever.', 'hard'],
    ],
    StoryCategory.nature: [
      ['The {0} sun rose over the hills. Birds sang their {1} songs. It was a beautiful morning in the village.', 'easy'],
      ['Rain fell on the {0} leaves. The flowers drank the {1} water. After the rain, a rainbow appeared in the sky.', 'easy'],
      ['A {0} river flowed through the valley. Fish jumped in the {1} water. Children played on the grassy banks.', 'medium'],
      ['The {0} mountain was covered in snow. Trees wore {1} white coats. Animals slept warm in their homes below.', 'hard'],
    ],
    StoryCategory.learning: [
      ['I can count to {0}. My teacher is {1}. I learn new things every day at school.', 'easy'],
      ['The {0} alphabet has many letters. Each letter makes a {1} sound. Together they make words we can read.', 'easy'],
      ['Today we learned about {0} shapes. A circle is round and a square has {1} sides. Math is fun when we draw.', 'medium'],
      ['Reading is a {0} adventure. Every book tells a {1} story. The more I read, the more I know about the world.', 'medium'],
    ],
    StoryCategory.adventure: [
      ['The boy went on a {0} trip. He saw a {1} boat on the sea. It was the best day of his life.', 'easy'],
      ['A brave girl climbed the {0} hill. At the top she found a {1} treasure chest. Inside were golden coins.', 'medium'],
      ['The {0} explorer walked through the dark cave. He used a {1} torch to see. At the end, he found a secret room.', 'medium'],
      ['Two {0} friends sailed across the ocean. They faced {1} storms and big waves. But they never gave up.', 'hard'],
    ],
  };

  static const _fillerWords = [
    'big', 'small', 'happy', 'funny', 'bright', 'warm', 'cool', 'soft',
    'tall', 'kind', 'fast', 'slow', 'clean', 'loud', 'quiet', 'sweet',
    'round', 'flat', 'new', 'old', 'long', 'short', 'dark', 'light',
  ];

  @override
  Future<Story> generateStory({
    required StoryCategory category,
    required double difficulty,
    required List<String> troubleWords,
  }) async {
    final templates = _templates[category] ?? _templates[StoryCategory.animals]!;

    final tier = difficulty < 0.35 ? 'easy' : (difficulty < 0.7 ? 'medium' : 'hard');
    final matching = templates.where((t) => t[1] == tier).toList();
    final pool = matching.isNotEmpty ? matching : templates;
    final template = pool[_rng.nextInt(pool.length)];

    final words = List<String>.from(troubleWords);
    while (words.length < 2) {
      words.add(_fillerWords[_rng.nextInt(_fillerWords.length)]);
    }
    words.shuffle(_rng);

    var text = template[0];
    for (int i = 0; i < 2; i++) {
      text = text.replaceFirst('{$i}', words[i]);
    }

    return Story(
      id: '${category.name}_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      category: category,
      difficulty: difficulty,
      highlightWords: troubleWords.take(3).toList(),
    );
  }
}
