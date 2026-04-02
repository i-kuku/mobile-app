class Language {
  final String label;
  final String value;

  Language({required this.label, required this.value});
}

final List<Language> languages = [
  Language(label: "english", value: "en"),
  Language(label: "swahili", value: "sw"),
];
