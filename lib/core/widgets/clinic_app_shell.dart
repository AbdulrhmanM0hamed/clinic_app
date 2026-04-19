import 'package:flutter/material.dart';

import '../../app/clinic_app_scope.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/diagnosis/presentation/diagnosis_page.dart';
import '../../features/laboratory/presentation/laboratory_page.dart';
import '../../features/reception/presentation/reception_page.dart';
import '../../features/reports/presentation/finance_reports_page.dart';
import '../models/clinic_models.dart';
import '../theme/app_theme.dart';
import 'clinic_app_sidebar.dart';
import 'status_chip.dart';

class ClinicAppShell extends StatelessWidget {
  const ClinicAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClinicAppScope.of(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1080;
    final items = _navigationItems;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 82,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.clinicName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              _titleForSection(controller.selectedSection),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          if (width >= 720)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: StatusChip(
                label:
                    '${controller.doctorName} • ${controller.doctorSpecialty}',
                color: AppTheme.primary,
                icon: Icons.verified_user_rounded,
              ),
            ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            onPressed: controller.logout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Row(
          children: [
            if (isWide)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 20,
                  end: 18,
                  bottom: 20,
                ),
                child: ClinicAppSidebar(
                  selectedSection: controller.selectedSection,
                  items: items,
                  onSelect: controller.selectSection,
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey(controller.selectedSection),
                  child: _buildPage(controller.selectedSection),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: controller.selectedSection.index,
              onDestinationSelected: (index) {
                controller.selectSection(ClinicSection.values[index]);
              },
              destinations: items
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildPage(ClinicSection section) {
    switch (section) {
      case ClinicSection.dashboard:
        return const DashboardPage();
      case ClinicSection.reception:
        return const ReceptionPage();
      case ClinicSection.laboratory:
        return const LaboratoryPage();
      case ClinicSection.diagnosis:
        return const DiagnosisPage();
      case ClinicSection.reports:
        return const FinanceReportsPage();
    }
  }

  String _titleForSection(ClinicSection section) {
    switch (section) {
      case ClinicSection.dashboard:
        return 'لوحة التحكم';
      case ClinicSection.reception:
        return 'إدارة الاستقبال';
      case ClinicSection.laboratory:
        return 'شاشة التحاليل';
      case ClinicSection.diagnosis:
        return 'تشخيص الحالات';
      case ClinicSection.reports:
        return 'التقارير المالية';
    }
  }

  List<NavigationItem> get _navigationItems {
    return const [
      NavigationItem(
        section: ClinicSection.dashboard,
        label: 'الرئيسية',
        icon: Icons.space_dashboard_rounded,
        subtitle: 'ملخص الأداء والاختصارات',
      ),
      NavigationItem(
        section: ClinicSection.reception,
        label: 'الاستقبال',
        icon: Icons.person_add_alt_1_rounded,
        subtitle: 'إدخال المرضى وفواتير الكشف',
      ),
      NavigationItem(
        section: ClinicSection.laboratory,
        label: 'التحاليل',
        icon: Icons.biotech_rounded,
        subtitle: 'طلبات التحليل والطباعة',
      ),
      NavigationItem(
        section: ClinicSection.diagnosis,
        label: 'التشخيص',
        icon: Icons.monitor_heart_rounded,
        subtitle: 'متابعة الحالات حسب المصدر',
      ),
      NavigationItem(
        section: ClinicSection.reports,
        label: 'التقارير',
        icon: Icons.query_stats_rounded,
        subtitle: 'الإيرادات والإحصائيات',
      ),
    ];
  }
}
