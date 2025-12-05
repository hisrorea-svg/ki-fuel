import 'package:intl/intl.dart';

/// Extension methods for DateTime to make formatting easier
extension DateTimeExtensions on DateTime {
  /// Format as readable date (e.g., "3 ديسمبر 2025")
  String toReadableDate({bool arabic = true}) {
    if (arabic) {
      return '$day ${_getArabicMonth(month)} $year';
    }
    return DateFormat('MMM d, yyyy').format(this);
  }

  /// Format as readable date and time (e.g., "3 ديسمبر 2025 - 2:30 م")
  String toReadableDateTime({bool arabic = true}) {
    if (arabic) {
      return '$day ${_getArabicMonth(month)} $year - ${toTime12Hour(arabic: true)}';
    }
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(this);
  }

  /// الحصول على اسم الشهر بالعربية
  static String _getArabicMonth(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month - 1];
  }

  /// Format as short date (e.g., "03/12/25")
  String toShortDate() {
    return '$day/$month/$year';
  }

  /// Format as time only (e.g., "2:30 PM")
  String toTimeOnly() {
    return DateFormat('h:mm a').format(this);
  }

  /// Format as time only in 12-hour format (e.g., "2:30 PM" or "2:30 \u0645")
  String toTime12Hour({bool arabic = false}) {
    final hour = this.hour;
    final minute = this.minute;
    final isPM = hour >= 12;
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    final period = arabic ? (isPM ? '\u0645' : '\u0635') : (isPM ? 'PM' : 'AM');
    return '$hour12:$minuteStr $period';
  }

  /// Format as full date (e.g., "Wednesday, December 3, 2025")
  String toFullDate() {
    return DateFormat('EEEE, MMMM d, yyyy').format(this);
  }

  /// Check if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if this date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Check if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Get a relative date string (e.g., "Today", "Tomorrow", "Dec 3")
  String toRelativeDate() {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    if (isYesterday) return 'Yesterday';
    return toReadableDate();
  }
}

/// Extension methods for Duration to format countdown strings
extension DurationExtensions on Duration {
  /// Format duration as countdown string (e.g., "2 days, 5 hours")
  String toCountdownString() {
    if (isNegative) {
      return 'Now';
    }

    final days = inDays;
    final hours = inHours % 24;
    final minutes = inMinutes % 60;

    if (days > 0) {
      if (hours > 0) {
        return '$days ${days == 1 ? 'day' : 'days'}, $hours ${hours == 1 ? 'hour' : 'hours'}';
      }
      return '$days ${days == 1 ? 'day' : 'days'}';
    }

    if (hours > 0) {
      if (minutes > 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'}, $minutes ${minutes == 1 ? 'min' : 'mins'}';
      }
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }

    if (minutes > 0) {
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    }

    return 'Less than a minute';
  }

  /// Format as short countdown (e.g., "2d 5h")
  String toShortCountdown() {
    if (isNegative) {
      return 'Now';
    }

    final days = inDays;
    final hours = inHours % 24;
    final minutes = inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    }

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${minutes}m';
  }
}
