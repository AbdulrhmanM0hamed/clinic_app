import 'package:flutter/material.dart';

import '../../../../app/app_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/clinic_formatters.dart';
import '../../../../core/widgets/metric_card.dart';

class DashboardMetricsSection extends StatelessWidget {
  const DashboardMetricsSection({
    super.key,
    required this.controller,
    required this.cardWidth,
  });

  final ClinicAppController controller;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: cardWidth,
          child: MetricCard(
            label: 'إيراد اليوم',
            value: ClinicFormatters.formatCurrency(controller.todayRevenue),
            icon: Icons.payments_rounded,
            highlightColor: AppTheme.primary,
            hint: 'ناتج عن الفواتير المسجلة اليوم.',
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: MetricCard(
            label: 'إيراد الأسبوع',
            value: ClinicFormatters.formatCurrency(controller.weeklyRevenue),
            icon: Icons.stacked_line_chart_rounded,
            highlightColor: AppTheme.secondary,
            hint: 'يتم احتسابه تلقائيًا من آخر 7 أيام.',
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: MetricCard(
            label: 'إجمالي المرضى',
            value: '${controller.totalPatients}',
            icon: Icons.groups_rounded,
            highlightColor: AppTheme.accent,
            hint: 'يشمل سجلات الاستقبال والتحاليل معًا.',
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: MetricCard(
            label: 'الفواتير المسجلة',
            value: '${controller.invoices.length}',
            icon: Icons.receipt_long_rounded,
            highlightColor: AppTheme.success,
            hint: 'كل فاتورة تغذي صفحة التقارير المالية تلقائيًا.',
          ),
        ),
      ],
    );
  }
}
