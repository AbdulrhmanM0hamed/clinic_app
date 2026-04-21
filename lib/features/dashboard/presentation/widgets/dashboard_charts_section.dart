import 'package:clinic_app/features/reports/presentation/cubits/reports_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/mini_bar_chart.dart';
import '../../../../core/widgets/section_card.dart';
import 'revenue_mix_card.dart';

class DashboardChartsSection extends StatelessWidget {
  const DashboardChartsSection({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoaded) {
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: SectionCard(
                    title: 'مؤشر العمل الأسبوعي',
                    subtitle: 'إيرادات آخر 7 أيام مدخلة في النظام.',
                    child: MiniBarChart(
                      points: state.dailyRevenueTrend,
                      color: AppTheme.success,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: SectionCard(
                    title: 'توزيع الإيراد الحالي',
                    subtitle: 'مقارنة بين إيرادات الطوارئ والمواعيد.',
                    child: RevenueMixCard(mix: state.revenueBySource),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              SectionCard(
                title: 'مؤشر العمل الأسبوعي',
                subtitle: 'إيرادات آخر 7 أيام مدخلة في النظام.',
                child: MiniBarChart(
                  points: state.dailyRevenueTrend,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'توزيع الإيراد الحالي',
                subtitle: 'مقارنة بين إيرادات الطوارئ والمواعيد.',
                child: RevenueMixCard(mix: state.revenueBySource),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
