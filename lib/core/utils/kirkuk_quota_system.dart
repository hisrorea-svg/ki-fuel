/// نظام حصص الوقود في كركوك
/// الحصة تبدأ كل 5 أيام من تاريخ 1-12-2025 الساعة 12:00 صباحاً
/// وتنتهي الساعة 11:59 مساءً في اليوم الخامس
library;

class KirkukQuotaSystem {
  /// تاريخ بداية النظام الثابت: 1 ديسمبر 2025 الساعة 12:00 صباحاً
  static final DateTime systemStartDate = DateTime(2025, 12, 1, 0, 0, 0);

  /// مدة كل حصة بالأيام
  static const int quotaPeriodDays = 5;

  /// الحصول على رقم الحصة الحالية (تبدأ من 1)
  static int getCurrentQuotaNumber() {
    final now = DateTime.now();

    // إذا لم يبدأ النظام بعد
    if (now.isBefore(systemStartDate)) {
      return 1;
    }

    // حساب عدد الأيام منذ بداية النظام
    final daysSinceStart = now.difference(systemStartDate).inDays;

    // حساب رقم الحصة (تبدأ من 1)
    return (daysSinceStart ~/ quotaPeriodDays) + 1;
  }

  /// الحصول على نافذة الحصة الحالية
  static QuotaPeriod getCurrentQuota() {
    final quotaNumber = getCurrentQuotaNumber();
    return getQuotaByNumber(quotaNumber);
  }

  /// الحصول على حصة معينة برقمها
  static QuotaPeriod getQuotaByNumber(int quotaNumber) {
    // الحصة رقم 1 تبدأ من systemStartDate
    final daysFromStart = (quotaNumber - 1) * quotaPeriodDays;

    final start = systemStartDate.add(Duration(days: daysFromStart));
    final end = DateTime(
      start.year,
      start.month,
      start.day + quotaPeriodDays - 1,
      23,
      59,
      59,
    );

    return QuotaPeriod(number: quotaNumber, start: start, end: end);
  }

  /// الحصول على الحصة القادمة
  static QuotaPeriod getNextQuota() {
    final currentNumber = getCurrentQuotaNumber();
    return getQuotaByNumber(currentNumber + 1);
  }

  /// الحصول على قائمة بالحصص (الماضية والحالية والمستقبلية)
  static List<QuotaPeriod> getQuotaList({
    int pastPeriods = 2,
    int futurePeriods = 3,
  }) {
    final currentNumber = getCurrentQuotaNumber();
    final List<QuotaPeriod> quotas = [];

    // الحصص الماضية
    for (int i = pastPeriods; i > 0; i--) {
      final number = currentNumber - i;
      if (number >= 1) {
        quotas.add(getQuotaByNumber(number));
      }
    }

    // الحصة الحالية
    quotas.add(getQuotaByNumber(currentNumber));

    // الحصص المستقبلية
    for (int i = 1; i <= futurePeriods; i++) {
      quotas.add(getQuotaByNumber(currentNumber + i));
    }

    return quotas;
  }

  /// التحقق إذا كانت الحصة مفتوحة الآن
  static bool isQuotaActiveNow() {
    return getCurrentQuota().isActiveNow;
  }

  /// الوقت المتبقي حتى نهاية الحصة الحالية
  static Duration timeUntilQuotaEnd() {
    return getCurrentQuota().timeUntilEnd();
  }

  /// الوقت المتبقي حتى بداية الحصة القادمة
  static Duration timeUntilNextQuota() {
    return getNextQuota().timeUntilStart();
  }

  /// تنسيق المدة بشكل مقروء
  static String formatDuration(Duration duration) {
    if (duration.isNegative) {
      return 'انتهت';
    }

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    if (days > 0) {
      return '$days يوم، $hours ساعة';
    } else if (hours > 0) {
      return '$hours ساعة، $minutes دقيقة';
    } else {
      return '$minutes دقيقة';
    }
  }

  /// تنسيق المدة بالإنجليزية
  static String formatDurationEn(Duration duration) {
    if (duration.isNegative) {
      return 'Ended';
    }

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

/// نموذج فترة الحصة
class QuotaPeriod {
  final int number;
  final DateTime start;
  final DateTime end;

  const QuotaPeriod({
    required this.number,
    required this.start,
    required this.end,
  });

  /// هل الحصة نشطة الآن؟
  bool get isActiveNow {
    final now = DateTime.now();
    return (now.isAfter(start) || now.isAtSameMomentAs(start)) &&
        (now.isBefore(end) || now.isAtSameMomentAs(end));
  }

  /// هل الحصة في الماضي؟
  bool get isPast {
    return DateTime.now().isAfter(end);
  }

  /// هل الحصة في المستقبل؟
  bool get isFuture {
    return DateTime.now().isBefore(start);
  }

  /// الوقت المتبقي حتى البداية
  Duration timeUntilStart() {
    return start.difference(DateTime.now());
  }

  /// الوقت المتبقي حتى النهاية
  Duration timeUntilEnd() {
    return end.difference(DateTime.now());
  }

  /// تنسيق التاريخ
  String get formattedDateRange {
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  /// تنسيق التاريخ بالتفصيل
  String get formattedDateRangeDetailed {
    return '${start.day}/${start.month}/${start.year} 12:00 AM - ${end.day}/${end.month}/${end.year} 11:59 PM';
  }

  @override
  String toString() {
    return 'Quota #$number: $formattedDateRange (${isActiveNow
        ? "ACTIVE"
        : isPast
        ? "PAST"
        : "UPCOMING"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuotaPeriod && other.number == number;
  }

  @override
  int get hashCode => number.hashCode;
}
