extension ParsedMap on Map<String, dynamic> {
  Map<String, dynamic> parseValues() {
    Map<String, dynamic> parsedMap = {};

    for (var entry in entries) {
      String key = entry.key;
      dynamic value = entry.value;

      if (value is String) {
        // Try to parse the string to a number or boolean
        if (int.tryParse(value) != null) {
          parsedMap[key] = int.tryParse(value);
        } else if (double.tryParse(value) != null) {
          parsedMap[key] = double.tryParse(value);
        } else if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false') {
          parsedMap[key] = value.toLowerCase() == 'true';
        } else {
          parsedMap[key] = value;
        }
      } else {
        parsedMap[key] = value;
      }
    }

    return parsedMap;
  }
}
