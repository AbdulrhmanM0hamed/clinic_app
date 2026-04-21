import 'package:clinic_app/features/reports/presentation/cubits/reports_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/clinic_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/section_card.dart';
import 'invoice_row.dart';
import 'shortcut_tile.dart';

class DashboardShortcutsSection extends StatelessWidget {
  const DashboardShortcutsSection({
    super.key,
    required this.onSelectSection,
    required this.isWide,
  });

  final void Function(ClinicSection section) onSelectSection;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: _buildShortcutsCard()),
          const SizedBox(width: 16),
          Expanded(flex: 5, child: _buildRecentInvoicesPanel(context)),
        ],
      );
    }

    return Column(
      children: [
        _buildShortcutsCard(),
        const SizedBox(height: 16),
        _buildRecentInvoicesPanel(context),
      ],
    );
  }

  Widget _buildShortcutsCard() {
    return SectionCard(
      title: 'وصول سريع للأقسام',
      subtitle: 'انتقل مباشرة إلى أكثر الصفحات استخدامًا داخل التطبيق.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 14.0;
          // Calculate width to fit exactly 2 tiles per row
          final tileWidth = (constraints.maxWidth - spacing) / 2;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              SizedBox(
                width: tileWidth,
                child: ShortcutTile(
                  label: 'الاستقبال',
                  subtitle: 'إدخال المرضى وفواتير الكشف',
                  icon: Icons.person_add_alt_1_rounded,
                  color: AppTheme.primary,
                  onTap: () => onSelectSection(ClinicSection.reception),
                ),
              ),
              SizedBox(
                width: tileWidth,
                child: ShortcutTile(
                  label: 'التحاليل',
                  subtitle: 'طلبات التحاليل وطباعة الفواتير',
                  icon: Icons.biotech_rounded,
                  color: AppTheme.secondary,
                  onTap: () => onSelectSection(ClinicSection.laboratory),
                ),
              ),
              SizedBox(
                width: tileWidth,
                child: ShortcutTile(
                  label: 'تشخيص الحالات',
                  subtitle: 'متابعة الحالات حسب المصدر',
                  icon: Icons.monitor_heart_rounded,
                  color: AppTheme.accent,
                  onTap: () => onSelectSection(ClinicSection.diagnosis),
                ),
              ),
              SizedBox(
                width: tileWidth,
                child: ShortcutTile(
                  label: 'التقارير المالية',
                  subtitle: 'إحصائيات الإيرادات والاتجاهات',
                  icon: Icons.query_stats_rounded,
                  color: AppTheme.success,
                  onTap: () => onSelectSection(ClinicSection.reports),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentInvoicesPanel(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ReportsLoaded) {
          final recentInvoices = state.recentInvoices.take(5).toList();
          return SectionCard(
            title: 'أحدث الفواتير',
            subtitle: 'آخر العمليات التي دخلت في النظام حتى الآن.',
            child: Column(
              children: recentInvoices
                  .map((invoice) => InvoiceRow(invoice: invoice))
                  .toList(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
