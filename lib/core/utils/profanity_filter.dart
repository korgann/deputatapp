class ProfanityFilter {
  static const List<String> _badWords = [
    'блять', 'блядь', 'хуй', 'пизда', 'ебать', 'ебал', 'ёбать', 'нахуй',
    'пиздец', 'хуйня', 'пиздить', 'блядина', 'сука', 'мудак', 'мудила',
    'залупа', 'ёбаный', 'ёб', 'манда', 'пездить', 'пездёж', 'шлюха',
    'ублюдок', 'хуёво', 'пиздато', 'нахуйник', 'пиздун', 'хуйло',
  ];

  static String filter(String text) {
    String result = text;
    for (final word in _badWords) {
      final regex = RegExp(word, caseSensitive: false);
      result = result.replaceAllMapped(regex, (match) {
        return 'X' * match.group(0)!.length;
      });
    }
    return result;
  }

  static bool containsProfanity(String text) {
    final lower = text.toLowerCase();
    return _badWords.any((word) => lower.contains(word));
  }

  static bool isCeleSseable(String text) {
    return !containsProfanity(text) && text.trim().isNotEmpty;
  }
}
