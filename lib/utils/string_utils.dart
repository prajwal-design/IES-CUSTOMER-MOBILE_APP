extension StringExtensions on String {
  String toHumanReadable() {
    if (isEmpty) return this;

    // Replace underscores and hyphens with spaces
    String result = replaceAll(RegExp(r'(_|-)'), ' ');

    // Split by space and capitalize each word
    return result.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
