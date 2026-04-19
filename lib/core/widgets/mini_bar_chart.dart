import 'package:flutter/material.dart';

import '../models/clinic_models.dart';
import '../theme/app_theme.dart';

class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.points,
    this.color,
    this.maxHeight = 180,
  });

  final List<RevenuePoint> points;
  final Color? color;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final accent = color ?? AppTheme.primary;
    final maxValue = points
        .map((point) => point.value)
        .fold<double>(0, (current, next) => next > current ? next : current);

    return SizedBox(
      height: maxHeight + 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((point) {
          final ratio = maxValue == 0
              ? 0.12
              : (point.value / maxValue).clamp(0.12, 1.0);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      point.value == 0 ? '0' : point.value.toStringAsFixed(0),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        width: double.infinity,
                        height: maxHeight * ratio,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [accent.withValues(alpha: 0.85), accent],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      point.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mutedText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
