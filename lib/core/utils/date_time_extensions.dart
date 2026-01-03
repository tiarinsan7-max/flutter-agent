import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Format date as 'dd/MM/yyyy'
  String toDateString() => DateFormat('dd/MM/yyyy').format(this);

  /// Format time as 'HH:mm'
  String toTimeString() => DateFormat('HH:mm').format(this);

  /// Format date and time as 'dd/MM/yyyy HH:mm'
  String toDateTimeString() => DateFormat('dd/MM/yyyy HH:mm').format(this);

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Get relative time string (e.g., '2 hours ago')
  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return toDateString();
    }
  }

  /// Check if date is in past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in future
  bool get isFuture => isAfter(DateTime.now());
}
