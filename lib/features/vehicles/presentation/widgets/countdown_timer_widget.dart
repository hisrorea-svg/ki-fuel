import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/kirkuk_quota_system.dart';

/// Header الصفحة الرئيسية - تصميم مع شريط تقدم سفلي
/// ملاحظة: يتم تحديث الويدجت من الصفحة الرئيسية (لا يوجد timer هنا)
class CountdownTimerWidget extends StatelessWidget {
  const CountdownTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentQuota = KirkukQuotaSystem.getCurrentQuota();
    final isActive = currentQuota.isActiveNow;

    var duration = isActive
        ? currentQuota.timeUntilEnd()
        : KirkukQuotaSystem.getNextQuota().timeUntilStart();

    // حماية من الأرقام السالبة
    if (duration.isNegative) {
      duration = Duration.zero;
    }

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    // حساب نسبة التقدم
    final now = DateTime.now();
    final totalDuration = currentQuota.end.difference(currentQuota.start);
    final elapsed = now.difference(currentQuota.start);
    final progress = isActive
        ? (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF00897B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // الجزء العلوي - التحية والعنوان
                _HeaderGreeting(theme: theme, l10n: l10n),

                const SizedBox(height: 8),

                // كارت المعلومات
                _QuotaInfoCard(
                  isActive: isActive,
                  progress: progress,
                  dateRangeText: currentQuota.formattedDateRange,
                  days: days,
                  hours: hours,
                  minutes: minutes,
                  seconds: seconds,
                ),
              ],
            ),

            // شريط التقدم أسفل الهيدر
            Positioned(
              left: 32,
              right: 32,
              bottom: 6,
              child: _BottomProgressBar(progress: progress, isActive: isActive),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// التحية في أعلى الهيدر
// ═══════════════════════════════════════════════════════════════════════════
class _HeaderGreeting extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations l10n;

  const _HeaderGreeting({required this.theme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // التحية مع الأيقونة
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_getGreetingEmoji(), style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${_getGreeting(l10n)} ..',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // العنوان
          Text(
            l10n.translate('app_subtitle'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    return '🌙';
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n
          .translate('good_morning')
          .replaceAll(' ☀️', '')
          .replaceAll('☀️', '');
    }
    if (hour < 17) {
      return l10n
          .translate('good_afternoon')
          .replaceAll(' 🌤️', '')
          .replaceAll('🌤️', '');
    }
    return l10n
        .translate('good_evening')
        .replaceAll(' 🌙', '')
        .replaceAll('🌙', '');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// كارت معلومات الحصة
// ═══════════════════════════════════════════════════════════════════════════
class _QuotaInfoCard extends StatelessWidget {
  final bool isActive;
  final double progress;
  final String dateRangeText;
  final int days, hours, minutes, seconds;

  const _QuotaInfoCard({
    required this.isActive,
    required this.progress,
    required this.dateRangeText,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          // الجزء الأيسر - الحالة والنسبة والتاريخ
          Expanded(
            child: _QuotaStatusSection(
              isActive: isActive,
              progress: progress,
              dateRangeText: dateRangeText,
            ),
          ),

          // الفاصل العمودي
          SizedBox(
            height: 40,
            child: VerticalDivider(
              thickness: 1,
              width: 32,
              color: theme.dividerColor.withValues(alpha: 0.3),
            ),
          ),

          // الجزء الأيمن - العداد
          _QuotaCountdownSection(
            isActive: isActive,
            days: days,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// قسم حالة الحصة (الجزء الأيسر)
// ═══════════════════════════════════════════════════════════════════════════
class _QuotaStatusSection extends StatelessWidget {
  final bool isActive;
  final double progress;
  final String dateRangeText;

  const _QuotaStatusSection({
    required this.isActive,
    required this.progress,
    required this.dateRangeText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // عنوان الحصة الحالية
        Text(
          l10n.currentQuota,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // حالة الحصة مع التاريخ
        Row(
          children: [
            // النقطة الملونة
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),

            // نص الحالة
            Text(
              isActive ? l10n.open : l10n.closed,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // التاريخ من - إلى (على سطرين)
        Text(
          dateRangeText.replaceAll(' - ', '\n${l10n.translate('to')}\n'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// قسم العداد التنازلي (الجزء الأيمن)
// ═══════════════════════════════════════════════════════════════════════════
class _QuotaCountdownSection extends StatelessWidget {
  final bool isActive;
  final int days, hours, minutes, seconds;
  final AppLocalizations l10n;

  const _QuotaCountdownSection({
    required this.isActive,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // جملة تنتهي/تفتح خلال
        Text(
          isActive ? l10n.endsIn : l10n.opensIn,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        // مربع العداد
        _CompactTimer(
          days: days,
          hours: hours,
          minutes: minutes,
          seconds: seconds,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// شريط التقدم السفلي مع تأثير التوهج والألوان المتدرجة
// ═══════════════════════════════════════════════════════════════════════════
class _BottomProgressBar extends StatefulWidget {
  final double progress;
  final bool isActive;

  const _BottomProgressBar({required this.progress, required this.isActive});

  @override
  State<_BottomProgressBar> createState() => _BottomProgressBarState();
}

class _BottomProgressBarState extends State<_BottomProgressBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

    if (widget.isActive) {
      _controller!.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_BottomProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller == null) return;

    if (widget.isActive && !_controller!.isAnimating) {
      _controller!.repeat(reverse: true);
    } else if (!widget.isActive && _controller!.isAnimating) {
      _controller!.stop();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// الحصول على اللون حسب نسبة التقدم
  /// 0-25%: أخضر فاتح (وقت كافي)
  /// 25-75%: برتقالي (وقت متوسط)
  /// 75-100%: أحمر (وقت قليل)
  Color _getProgressColor() {
    if (!widget.isActive) return Colors.grey.shade400;

    if (widget.progress <= 0.25) {
      // أخضر فاتح - بداية الحصة
      return const Color(0xFF4CAF50);
    } else if (widget.progress <= 0.75) {
      // برتقالي - منتصف الحصة
      return const Color(0xFFFF9800);
    } else {
      // أحمر - نهاية الحصة
      return const Color(0xFFF44336);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = _getProgressColor();

    // إذا لم يكن هناك animation، نعرض الشريط بدون توهج
    if (_glowAnimation == null || _controller == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: widget.isActive ? widget.progress : 0.0,
          minHeight: 8,
          backgroundColor: Colors.white.withValues(alpha: 0.25),
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _glowAnimation!,
      builder: (context, child) {
        final glowIntensity = _glowAnimation!.value;

        return Container(
          decoration: widget.isActive
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withValues(
                        alpha: 0.4 * glowIntensity,
                      ),
                      blurRadius: 8 + (8 * glowIntensity),
                      spreadRadius: 1 + (2 * glowIntensity),
                    ),
                  ],
                )
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: widget.isActive ? widget.progress : 0.0,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// عداد الوقت المضغوط
// ═══════════════════════════════════════════════════════════════════════════
class _CompactTimer extends StatelessWidget {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  const _CompactTimer({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dayLabel = l10n.translate('day_short');
    final timeText = days > 0
        ? '$days$dayLabel ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00897B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        timeText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'monospace',
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// ويدجت عداد مصغر للبطاقات
/// ملاحظة: يتم تحديث الويدجت من الصفحة الرئيسية
class MiniCountdownWidget extends StatelessWidget {
  final bool isActive;

  const MiniCountdownWidget({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final quota = isActive
        ? KirkukQuotaSystem.getCurrentQuota()
        : KirkukQuotaSystem.getNextQuota();
    final duration = isActive ? quota.timeUntilEnd() : quota.timeUntilStart();

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: isActive ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
