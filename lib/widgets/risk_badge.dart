import 'package:flutter/material.dart';
import '../models/enums.dart';

/// Widget Reutilizável: Badge de Classificação de Risco Clínico (RF03)
class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final bool compact;

  const RiskBadge({
    super.key,
    required this.level,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: level.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: level.color.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            level.icon,
            size: compact ? 14 : 16,
            color: level.color,
          ),
          const SizedBox(width: 5),
          Text(
            compact ? level.label.split(' ')[0] : level.label.toUpperCase(),
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.bold,
              color: level.color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
