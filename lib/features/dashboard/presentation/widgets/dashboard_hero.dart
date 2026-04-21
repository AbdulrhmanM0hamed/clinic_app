import 'package:flutter/material.dart';


import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_chip.dart';

class DashboardHero extends StatelessWidget {
  const DashboardHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        color: AppTheme.softBackground,
        border: Border.all(color: AppTheme.border),
      ),
      child: Wrap(
        spacing: 22,
        runSpacing: 22,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatusChip(
                  label: 'لوحة تحكم تشغيلية للعيادة',
                  color: AppTheme.primary,
                  icon: Icons.dashboard_customize_rounded,
                ),
                const SizedBox(height: 18),
                Text(
                  'كل ما تحتاجه لإدارة العيادة من مكان واحد',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'الاستقبال، التحاليل، متابعة الحالات، وإيرادات العيادة كلها مترابطة في تجربة واحدة نظيفة وسريعة.',
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _HeroTag(
                icon: Icons.cloud_sync_rounded,
                label: 'Dummy data بهيئة API',
              ),
              _HeroTag(
                icon: Icons.print_rounded,
                label: 'فواتير قابلة للطباعة',
              ),
              _HeroTag(icon: Icons.shield_rounded, label: 'تسجيل دخول للطبيب'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
