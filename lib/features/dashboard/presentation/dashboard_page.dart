import 'package:flutter/material.dart';

import '../../../../core/models/clinic_models.dart';
import 'widgets/dashboard_charts_section.dart';
import 'widgets/dashboard_metrics_section.dart';
import 'widgets/dashboard_shortcuts_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, this.onSelectSection});

  final void Function(ClinicSection section)? onSelectSection;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1100;
    // On wide screens, 4 cards in a row. On smaller screens, 2 in a row (grid).
    final cardWidth = isWide ? (width - 160) / 4.4 : (width - 40 - 16) / 2;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 20 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //    const DashboardHero(),
          const SizedBox(height: 24),
          DashboardShortcutsSection(
            onSelectSection: onSelectSection ?? (_) {},
            isWide: isWide,
          ),
          const SizedBox(height: 24),
          DashboardMetricsSection(cardWidth: cardWidth),
          const SizedBox(height: 24),
          DashboardChartsSection(isWide: isWide),
        ],
      ),
    );
  }
}
