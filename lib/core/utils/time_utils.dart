class TimeUtils {
  static int currentEpoch() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  static String formatDate(DateTime dt) {
    return '${dt.year} ${_twoDigits(dt.month)} ${_twoDigits(dt.day)}';
  }

  static String formatTime(DateTime dt) {
    return '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}:${_twoDigits(dt.second)}';
  }

  static String formatDateTime(DateTime dt) {
    return '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)} '
        '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}:${_twoDigits(dt.second)}';
  }

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static DateTime? parseDeviceTime(String time) {
    try {
      return DateTime.tryParse(time);
    } catch (_) {
      return null;
    }
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  static DateTime startOfDay(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  static DateTime startOfWeek(DateTime dt) {
    final weekday = dt.weekday;
    return DateTime(dt.year, dt.month, dt.day - weekday + 1);
  }

  static DateTime startOfMonth(DateTime dt) {
    return DateTime(dt.year, dt.month, 1);
  }
}