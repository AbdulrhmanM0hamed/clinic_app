import 'package:flutter/material.dart';

import '../../app/clinic_app_scope.dart';
import '../models/clinic_models.dart';
import '../theme/app_theme.dart';
import 'status_chip.dart';

class ClinicAppSidebar extends StatelessWidget {
  const ClinicAppSidebar({
    super.key,
    required this.selectedSection,
    required this.items,
    required this.onSelect,
  });

  final ClinicSection selectedSection;
  final List<NavigationItem> items;
  final ValueChanged<ClinicSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.softBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusChip(
                  label: 'Clinic Suite',
                  color: AppTheme.primary,
                  icon: Icons.health_and_safety_rounded,
                ),
                SizedBox(height: 14),
                Text(
                  'واجهة تشغيل كاملة للعيادة مع بيانات تجريبية جاهزة للربط.',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.section == selectedSection;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => onSelect(item.section),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.border.withValues(alpha: 0.75),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.softBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.mutedText,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? AppTheme.primary
                                        : AppTheme.ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    color: AppTheme.mutedText,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  const NavigationItem({
    required this.section,
    required this.label,
    required this.icon,
    required this.subtitle,
  });

  final ClinicSection section;
  final String label;
  final IconData icon;
  final String subtitle;
}
