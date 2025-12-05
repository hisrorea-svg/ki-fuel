import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';

/// Chip widget showing quota status (Open/Closed)
class QuotaStatusChip extends StatelessWidget {
  final bool isActive;
  final bool large;

  const QuotaStatusChip({
    super.key,
    required this.isActive,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 12,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: large ? 10 : 8,
            height: large ? 10 : 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: large ? 8 : 6),
          Text(
            isActive ? l10n.open : l10n.closed,
            style: TextStyle(
              color: isActive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: large ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
