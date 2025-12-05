/// Represents a quota time window with start and end dates
class QuotaWindow {
  final DateTime start;
  final DateTime end;

  const QuotaWindow({required this.start, required this.end});

  /// Check if the quota is currently active (open)
  bool get isActiveNow {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end) ||
        now.isAtSameMomentAs(start);
  }

  /// Get time remaining until the quota starts
  Duration timeUntilStart() => start.difference(DateTime.now());

  /// Get time remaining until the quota ends
  Duration timeUntilEnd() => end.difference(DateTime.now());

  /// Check if this window is in the past
  bool get isPast => DateTime.now().isAfter(end);

  /// Check if this window is in the future
  bool get isFuture => DateTime.now().isBefore(start);

  @override
  String toString() {
    return 'QuotaWindow(start: $start, end: $end, isActiveNow: $isActiveNow)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuotaWindow && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

/// Utility class for quota calculations
class QuotaCalculator {
  /// Get the current quota window for a vehicle
  static QuotaWindow getCurrentQuotaWindow(
    DateTime firstQuotaStart, {
    int quotaLengthDays = 5,
  }) {
    final now = DateTime.now();

    // If we haven't reached the first quota start yet
    if (now.isBefore(firstQuotaStart)) {
      final end = firstQuotaStart
          .add(Duration(days: quotaLengthDays))
          .subtract(const Duration(minutes: 1));
      return QuotaWindow(start: firstQuotaStart, end: end);
    }

    // Calculate which period we're in
    final totalDays = now.difference(firstQuotaStart).inDays;
    final periodIndex = totalDays ~/ quotaLengthDays;

    final currentStart = firstQuotaStart.add(
      Duration(days: periodIndex * quotaLengthDays),
    );
    final currentEnd = currentStart
        .add(Duration(days: quotaLengthDays))
        .subtract(const Duration(minutes: 1));

    return QuotaWindow(start: currentStart, end: currentEnd);
  }

  /// Get multiple quota windows (past and future)
  static List<QuotaWindow> getQuotaWindows(
    DateTime firstQuotaStart, {
    int quotaLengthDays = 5,
    int pastPeriods = 3,
    int futurePeriods = 3,
  }) {
    final now = DateTime.now();
    final windows = <QuotaWindow>[];

    // Calculate current period index
    int currentPeriodIndex;
    if (now.isBefore(firstQuotaStart)) {
      currentPeriodIndex = 0;
    } else {
      final totalDays = now.difference(firstQuotaStart).inDays;
      currentPeriodIndex = totalDays ~/ quotaLengthDays;
    }

    // Generate windows from (current - pastPeriods) to (current + futurePeriods)
    final startIndex = (currentPeriodIndex - pastPeriods).clamp(
      0,
      currentPeriodIndex,
    );
    final endIndex = currentPeriodIndex + futurePeriods;

    for (int i = startIndex; i <= endIndex; i++) {
      final start = firstQuotaStart.add(Duration(days: i * quotaLengthDays));
      final end = start
          .add(Duration(days: quotaLengthDays))
          .subtract(const Duration(minutes: 1));
      windows.add(QuotaWindow(start: start, end: end));
    }

    return windows;
  }

  /// Get the next quota window after the current one
  static QuotaWindow getNextQuotaWindow(
    DateTime firstQuotaStart, {
    int quotaLengthDays = 5,
  }) {
    final current = getCurrentQuotaWindow(
      firstQuotaStart,
      quotaLengthDays: quotaLengthDays,
    );
    final nextStart = current.end.add(const Duration(minutes: 1));
    final nextEnd = nextStart
        .add(Duration(days: quotaLengthDays))
        .subtract(const Duration(minutes: 1));
    return QuotaWindow(start: nextStart, end: nextEnd);
  }
}
