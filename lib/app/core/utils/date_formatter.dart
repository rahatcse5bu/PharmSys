import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormatter = DateFormat('dd MMM yyyy HH:mm');
  static final DateFormat _timeFormatter = DateFormat('HH:mm');
  
  static String formatDate(DateTime date) {
    return _dateTimeFormatter.format(date);
  }

  static String formatDateOnly(DateTime date) {
    return _dateFormatter.format(date);
  }

  static String formatTime(DateTime time) {
    return _timeFormatter.format(time);
  }

  static DateTime? tryParse(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    return '$hours:$minutes';
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
