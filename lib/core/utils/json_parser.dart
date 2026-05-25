import 'dart:convert';

class JsonParser {
  static List<Map<String, dynamic>> parseLineBuffer(String buffer) {
    final List<Map<String, dynamic>> results = [];
    final lines = buffer.split('\n');

    for (int i = 0; i < lines.length - 1; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parsed = parseJson(line);
      if (parsed != null) {
        results.add(parsed);
      }
    }

    return results;
  }

  static String getRemainingBuffer(String buffer) {
    final lines = buffer.split('\n');
    return lines.isNotEmpty ? lines.last : '';
  }

  static Map<String, dynamic>? parseJson(String line) {
    try {
      final decoded = jsonDecode(line);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? tryParse(String data) {
    final trimmed = data.trim();
    if (trimmed.isEmpty) return null;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }
}