import 'package:flutter/material.dart';

import '../../../core/models/clinic_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clinic_formatters.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/mini_bar_chart.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_chip.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/reports_cubit.dart';

class FinanceReportsPage extends StatelessWidget {
  const FinanceReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ReportsError) {
          return Center(child: Text(state.message));
        } else if (state is ReportsLoaded) {
          final width = MediaQuery.of(context).size.width;
          final isWide = width >= 1180;
          final mix = state.revenueBySource;
          final monthlyTrend = state.monthlyRevenueTrend;
          final topServices = state.topServices;
          final recentInvoices = state.recentInvoices;
          final averageInvoice = state.averageInvoice;

          return RefreshIndicator(
            onRefresh: () => context.read<ReportsCubit>().fetchReports(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isWide ? 28 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: AppTheme.softBackground,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusChip(
                              label: 'التقارير المالية والإدارية',
                              color: AppTheme.success,
                              icon: Icons.query_stats_rounded,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'إيرادات أسبوعية وشهرية وسنوية محسوبة تلقائيًا',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.ink,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'كل فاتورة علاجية أو تحليلية يتم احتسابها مباشرة داخل الإحصائيات والاتجاهات المالية.',
                              style: TextStyle(color: AppTheme.mutedText),
                            ),
                          ],
                        ),
                        StatusChip(
                          label: 'تقارير حية مرتبطة بكل الفواتير',
                          color: AppTheme.primary,
                          icon: Icons.auto_graph_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final spacing = 16.0;
                      final crossAxisCount = constraints.maxWidth < 600
                          ? 2
                          : (constraints.maxWidth < 900 ? 3 : 4);
                      final itemWidth =
                          (constraints.maxWidth -
                              (spacing * (crossAxisCount - 1))) /
                          crossAxisCount;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: MetricCard(
                              label: 'إيراد الأسبوع',
                              value: ClinicFormatters.formatCurrency(
                                state.weeklyRevenue,
                              ),
                              icon: Icons.date_range_rounded,
                              highlightColor: AppTheme.primary,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: MetricCard(
                              label: 'إيراد الشهر',
                              value: ClinicFormatters.formatCurrency(
                                state.monthlyRevenue,
                              ),
                              icon: Icons.calendar_view_month_rounded,
                              highlightColor: AppTheme.secondary,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: MetricCard(
                              label: 'إيراد السنة',
                              value: ClinicFormatters.formatCurrency(
                                state.yearlyRevenue,
                              ),
                              icon: Icons.event_repeat_rounded,
                              highlightColor: AppTheme.success,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: MetricCard(
                              label: 'متوسط الفاتورة',
                              value: ClinicFormatters.formatCurrency(
                                averageInvoice,
                              ),
                              icon: Icons.price_check_rounded,
                              highlightColor: AppTheme.accent,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: SectionCard(
                            title: 'الاتجاه الشهري للإيرادات',
                            subtitle:
                                'ملخص آخر 6 أشهر من الأداء المالي الحالي داخل التطبيق.',
                            child: MiniBarChart(
                              points: monthlyTrend,
                              color: AppTheme.success,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 5,
                          child: SectionCard(
                            title: 'توزيع الإيراد حسب القسم',
                            subtitle:
                                'مقارنة بين مساهمة الاستقبال والتحاليل في الإيراد.',
                            child: _FinanceMixCard(mix: mix),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    SectionCard(
                      title: 'الاتجاه الشهري للإيرادات',
                      subtitle:
                          'ملخص آخر 6 أشهر من الأداء المالي الحالي داخل التطبيق.',
                      child: MiniBarChart(
                        points: monthlyTrend,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'توزيع الإيراد حسب القسم',
                      subtitle:
                          'مقارنة بين مساهمة الاستقبال والتحاليل في الإيراد.',
                      child: _FinanceMixCard(mix: mix),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: SectionCard(
                            title: 'أعلى الخدمات دخلاً',
                            subtitle:
                                'الخدمات الأكثر مساهمة في الإيراد من واقع الفواتير الحالية.',
                            child: Column(
                              children: topServices
                                  .map((item) => _TopServiceRow(item: item))
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 6,
                          child: SectionCard(
                            title: 'أحدث الفواتير المالية',
                            subtitle:
                                'سجل تفصيلي لآخر الفواتير التي دخلت في التقارير.',
                            child: Column(
                              children: recentInvoices
                                  .map(
                                    (invoice) =>
                                        _FinanceInvoiceRow(invoice: invoice),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    SectionCard(
                      title: 'أعلى الخدمات دخلاً',
                      subtitle:
                          'الخدمات الأكثر مساهمة في الإيراد من واقع الفواتير الحالية.',
                      child: Column(
                        children: topServices
                            .map((item) => _TopServiceRow(item: item))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'أحدث الفواتير المالية',
                      subtitle:
                          'سجل تفصيلي لآخر الفواتير التي دخلت في التقارير.',
                      child: Column(
                        children: recentInvoices
                            .map(
                              (invoice) => _FinanceInvoiceRow(invoice: invoice),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _FinanceMixCard extends StatelessWidget {
  const _FinanceMixCard({required this.mix});

  final Map<CaseSource, double> mix;

  @override
  Widget build(BuildContext context) {
    final total = mix.values.fold<double>(0, (sum, value) => sum + value);

    return Column(
      children: CaseSource.values.map((source) {
        final amount = mix[source] ?? 0;
        final ratio = total == 0 ? 0.0 : amount / total;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.softBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    source.icon,
                    size: 20,
                    color: source == CaseSource.reception
                        ? AppTheme.primary
                        : AppTheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      source.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    ClinicFormatters.formatCurrency(amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: ratio == 0 ? 0.02 : ratio,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    source == CaseSource.reception
                        ? AppTheme.primary
                        : AppTheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TopServiceRow extends StatelessWidget {
  const _TopServiceRow({required this.item});

  final RevenuePoint item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.softBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            ClinicFormatters.formatCurrency(item.value),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _FinanceInvoiceRow extends StatelessWidget {
  const _FinanceInvoiceRow({required this.invoice});

  final ClinicInvoice invoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.softBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              invoice.source.icon,
              size: 20,
              color: invoice.source == CaseSource.reception
                  ? AppTheme.primary
                  : AppTheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${invoice.source.label} • ${invoice.serviceLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ClinicFormatters.formatDateTime(invoice.createdAt),
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ClinicFormatters.formatCurrency(invoice.amount),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
