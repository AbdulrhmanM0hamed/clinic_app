import 'package:flutter/material.dart';

import '../../../../app/app_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/mini_bar_chart.dart';
import '../../../../core/widgets/section_card.dart';
import 'revenue_mix_card.dart';

class DashboardChartsSection extends StatelessWidget {
  const DashboardChartsSection({
    super.key,
    required this.controller,
    required this.isWide,
  });

  final ClinicAppController controller;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: SectionCard(
              title: 'حركة الإيرادات اليومية',
              subtitle: 'آخر 7 أيام مع تحديث مباشر من الفواتير الحالية.',
              child: MiniBarChart(
                points: controller.dailyRevenueTrend(),
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: SectionCard(
              title: 'توزيع الإيراد حسب القسم',
              subtitle: 'نسبة مساهمة كل قسم في إجمالي الفواتير الحالية.',
              child: RevenueMixCard(mix: controller.revenueBySource()),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SectionCard(
          title: 'حركة الإيرادات اليومية',
          subtitle: 'آخر 7 أيام مع تحديث مباشر من الفواتير الحالية.',
          child: MiniBarChart(
            points: controller.dailyRevenueTrend(),
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'توزيع الإيراد حسب القسم',
          subtitle: 'نسبة مساهمة كل قسم في إجمالي الفواتير الحالية.',
          child: RevenueMixCard(mix: controller.revenueBySource()),
        ),
      ],
    );
  }
}
