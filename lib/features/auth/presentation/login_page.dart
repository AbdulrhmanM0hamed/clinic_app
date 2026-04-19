import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/clinic_app_scope.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clinic_formatters.dart';
import '../../../core/widgets/status_chip.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController(
    text: 'dr.salim',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '123456',
  );

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(ClinicAppController controller) async {
    final success = await controller.login(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted || success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'بيانات الدخول غير صحيحة. استخدم الحسابات التجريبية المعروضة.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ClinicAppScope.of(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1100;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Expanded(
                        //   child: _MarketingPanel(controller: controller),
                        // ),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 420,
                          child: _LoginCard(
                            controller: controller,
                            usernameController: _usernameController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            onTogglePassword: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            onSubmit: () => _submit(controller),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        //   _MarketingPanel(controller: controller, compact: true),
                        const SizedBox(height: 20),
                        _LoginCard(
                          controller: controller,
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          onTogglePassword: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          onSubmit: () => _submit(controller),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketingPanel extends StatelessWidget {
  const _MarketingPanel({required this.controller, this.compact = false});

  final ClinicAppController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0F766E), Color(0xFF0E7490), Color(0xFF14532D)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F172A),
            blurRadius: 42,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatusChip(
            label: 'بيانات تجريبية جاهزة للربط مع API',
            color: Colors.white,
            icon: Icons.cloud_done_rounded,
          ),
          const SizedBox(height: 28),
          Text(
            'عيادتي',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'إدارة سلسة وأنيقة للاستقبال، التحاليل، التشخيص، والفواتير من لوحة واحدة مصممة بعقلية تشغيل حقيقية للعيادات.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _GlassMetric(
                label: 'إيراد اليوم',
                value: ClinicFormatters.formatCurrency(controller.todayRevenue),
              ),
              _GlassMetric(
                label: 'مراجعين اليوم',
                value: '${controller.todayPatientsCount}',
              ),
              _GlassMetric(
                label: 'إجمالي السجلات',
                value: '${controller.totalPatients}',
              ),
            ],
          ),
          const SizedBox(height: 32),
          const _BenefitRow(
            icon: Icons.receipt_long_rounded,
            title: 'فواتير PDF جاهزة',
            description:
                'حفظ أو طباعة الفاتورة لكل خدمة من داخل التطبيق مباشرة.',
          ),
          const SizedBox(height: 18),
          const _BenefitRow(
            icon: Icons.analytics_rounded,
            title: 'تقارير مالية تلقائية',
            description:
                'إيرادات أسبوعية وشهرية وسنوية تتحدث تلقائيًا مع كل فاتورة.',
          ),
          const SizedBox(height: 18),
          const _BenefitRow(
            icon: Icons.badge_rounded,
            title: 'ملفات مرضى منظمة',
            description:
                'بيانات هوية كاملة، حساب عمر تلقائي، وتتبّع للحالات حسب المصدر.',
          ),
          if (!compact) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الحسابات التجريبية',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _CredentialLine(
                    username: 'dr.salim',
                    password: '123456',
                    specialty: 'باطنة',
                  ),
                  const SizedBox(height: 10),
                  const _CredentialLine(
                    username: 'dr.mariam',
                    password: '123456',
                    specialty: 'تحاليل وتشخيص',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.controller,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final ClinicAppController controller;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تسجيل دخول الطبيب',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'ادخل ببيانات الطبيب المختص للوصول إلى الاستقبال والتحاليل والتقارير الإدارية.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم',
                hintText: 'dr.salim',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                hintText: '123456',
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.softBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملاحظات سريعة',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 10),
                  Text('اسم المستخدم: dr.salim أو dr.mariam'),
                  SizedBox(height: 4),
                  Text('كلمة المرور: 123456'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.isAuthenticating ? null : onSubmit,
                icon: controller.isAuthenticating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login_rounded),
                label: Text(
                  controller.isAuthenticating
                      ? 'جاري التحقق...'
                      : 'الدخول إلى النظام',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassMetric extends StatelessWidget {
  const _GlassMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CredentialLine extends StatelessWidget {
  const _CredentialLine({
    required this.username,
    required this.password,
    required this.specialty,
  });

  final String username;
  final String password;
  final String specialty;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(specialty, style: const TextStyle(color: Colors.white70)),
        const SizedBox(width: 12),
        Text(
          password,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
