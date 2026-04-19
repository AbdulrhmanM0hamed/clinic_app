import 'package:flutter/material.dart';

import '../../../../core/models/clinic_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/clinic_formatters.dart';

class RevenueMixCard extends StatelessWidget {
  const RevenueMixCard({super.key, required this.mix});

  final Map<CaseSource, double> mix;

  @override
  Widget build(BuildContext context) {
    final total = mix.values.fold<double>(0, (sum, value) => sum + value);

    return Column(
      children: [
        for (final source in CaseSource.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _MixRow(
              source: source,
              amount: mix[source] ?? 0,
              ratio: total == 0 ? 0 : (mix[source] ?? 0) / total,
            ),
          ),
      ],
    );
  }
}

class _MixRow extends StatelessWidget {
  const _MixRow({
    required this.source,
    required this.amount,
    required this.ratio,
  });

  final CaseSource source;
  final double amount;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final color = source == CaseSource.reception
        ? AppTheme.primary
        : AppTheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(source.icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                source.label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              ClinicFormatters.formatCurrency(amount),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: ratio == 0 ? 0.02 : ratio,
            minHeight: 10,
            backgroundColor: AppTheme.softBackground,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
