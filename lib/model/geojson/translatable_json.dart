extension TranslatableJson on Map<String, dynamic> {
  dynamic translated(String key, String languageCode) {
    String localized = this["${key}_$languageCode"];
    if (localized?.isEmpty == true) { localized = null; }
    return localized ?? this[key];
  }
}