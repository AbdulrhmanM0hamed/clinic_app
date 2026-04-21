import 'package:clinic_app/features/reports/presentation/cubits/reports_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/clinic_formatters.dart';
import '../../../../core/widgets/metric_card.dart';

class DashboardMetricsSection extends StatelessWidget {
  const DashboardMetricsSection({super.key, required this.cardWidth});

  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoaded) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: cardWidth,
                child: MetricCard(
                  label: 'إيراد اليوم',
                  value: ClinicFormatters.formatCurrency(state.todayRevenue),
                  icon: Icons.payments_rounded,
                  highlightColor: AppTheme.primary,
                  hint: 'ناتج عن الفواتير المسجلة اليوم.',
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: MetricCard(
                  label: 'إيراد الأسبوع',
                  value: ClinicFormatters.formatCurrency(state.weeklyRevenue),
                  icon: Icons.stacked_line_chart_rounded,
                  highlightColor: AppTheme.secondary,
                  hint: 'يتم احتسابه تلقائيًا من آخر 7 أيام.',
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: MetricCard(
                  label: 'إجمالي المرضى',
                  value: '${state.totalPatients}',
                  icon: Icons.groups_rounded,
                  highlightColor: AppTheme.accent,
                  hint: 'يشمل سجلات الاستقبال والتحاليل معًا.',
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: MetricCard(
                  label: 'الفواتير المسجلة',
                  value: '${state.totalInvoices}',
                  icon: Icons.receipt_long_rounded,
                  highlightColor: AppTheme.success,
                  hint: 'كل فاتورة تغذي صفحة التقارير المالية تلقائيًا.',
                ),
              ),
            ],
          );
        }
        return const SizedBox(
          height: 140,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
