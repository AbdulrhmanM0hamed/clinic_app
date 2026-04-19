import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/clinic_app_scope.dart';
import '../../../core/models/clinic_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clinic_formatters.dart';
import '../../../core/utils/invoice_pdf_service.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_chip.dart';

class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({super.key});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  CaseSource? _selectedSource;
  String _searchQuery = '';
  String? _selectedCaseId;

  List<DiagnosisCase> _filterCases(List<DiagnosisCase> cases) {
    return cases.where((item) {
      final matchesSource =
          _selectedSource == null || item.source == _selectedSource;
      final normalizedQuery = _searchQuery.trim();
      final matchesQuery =
          normalizedQuery.isEmpty ||
          item.patientName.contains(normalizedQuery) ||
          item.serviceLabel.contains(normalizedQuery) ||
          item.nationalId.contains(normalizedQuery);
      return matchesSource && matchesQuery;
    }).toList();
  }

  Future<void> _printInvoice(
    ClinicAppController controller,
    DiagnosisCase diagnosisCase,
  ) async {
    final invoice = controller.invoiceById(diagnosisCase.invoiceId);
    if (invoice == null) {
      return;
    }

    await InvoicePdfService.printInvoice(
      invoice: invoice,
      doctorName: controller.doctorName,
    );
  }

  Future<void> _shareInvoice(
    ClinicAppController controller,
    DiagnosisCase diagnosisCase,
  ) async {
    final invoice = controller.invoiceById(diagnosisCase.invoiceId);
    if (invoice == null) {
      return;
    }

    await InvoicePdfService.shareInvoice(
      invoice: invoice,
      doctorName: controller.doctorName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ClinicAppScope.of(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1200;
    final allCases = controller.diagnosisCases;
    final filteredCases = _filterCases(allCases);

    DiagnosisCase? activeCase;
    for (final item in filteredCases) {
      if (item.id == _selectedCaseId) {
        activeCase = item;
        break;
      }
    }
    activeCase ??= filteredCases.isNotEmpty ? filteredCases.first : null;

    final labCount = allCases
        .where((item) => item.source == CaseSource.laboratory)
        .length;
    final receptionCount = allCases
        .where((item) => item.source == CaseSource.reception)
        .length;
    final averageInvoice = controller.invoices.isEmpty
        ? 0.0
        : controller.invoices.fold<double>(
                0,
                (sum, item) => sum + item.amount,
              ) /
              controller.invoices.length;

    return SingleChildScrollView(
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
                      label: 'تشخيص الحالات',
                      color: AppTheme.accent,
                      icon: Icons.monitor_heart_rounded,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'متابعة الحالات حسب الاستقبال أو التحاليل',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.ink,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'كل من تم استقباله أو إضافة طلب تحليل له يظهر هنا في سجل موحّد وقابل للفلترة.',
                      style: TextStyle(color: AppTheme.mutedText),
                    ),
                  ],
                ),
                StatusChip(
                  label: 'فلترة + بحث + طباعة فاتورة',
                  color: AppTheme.primary,
                  icon: Icons.tune_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 16.0;
              final crossAxisCount = constraints.maxWidth < 600 ? 2 : (constraints.maxWidth < 900 ? 3 : 4);
              final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: MetricCard(
                      label: 'إجمالي الحالات',
                      value: '${allCases.length}',
                      icon: Icons.medical_information_rounded,
                      highlightColor: AppTheme.primary,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: MetricCard(
                      label: 'حالات الاستقبال',
                      value: '$receptionCount',
                      icon: Icons.person_add_alt_1_rounded,
                      highlightColor: AppTheme.primary,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: MetricCard(
                      label: 'حالات التحاليل',
                      value: '$labCount',
                      icon: Icons.biotech_rounded,
                      highlightColor: AppTheme.secondary,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: MetricCard(
                      label: 'متوسط الفاتورة',
                      value: ClinicFormatters.formatCurrency(averageInvoice),
                      icon: Icons.payments_rounded,
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
                  flex: 5,
                  child: _buildCaseListCard(controller, filteredCases),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 6,
                  child: _buildCaseDetailsCard(
                    controller: controller,
                    diagnosisCase: activeCase,
                  ),
                ),
              ],
            )
          else ...[
            _buildCaseListCard(controller, filteredCases),
            const SizedBox(height: 16),
            _buildCaseDetailsCard(
              controller: controller,
              diagnosisCase: activeCase,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCaseListCard(
    ClinicAppController controller,
    List<DiagnosisCase> filteredCases,
  ) {
    return SectionCard(
      title: 'قائمة الحالات',
      subtitle:
          'ابحث باسم المريض أو رقم الهوية، ثم افتح التفاصيل في الجهة الأخرى.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'ابحث باسم المريض أو الخدمة أو رقم الهوية',
              hintStyle: TextStyle(fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, size: 20),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ChoiceChip(
                label: const Text('الكل'),
                selected: _selectedSource == null,
                onSelected: (_) {
                  setState(() {
                    _selectedSource = null;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('الاستقبال'),
                selected: _selectedSource == CaseSource.reception,
                onSelected: (_) {
                  setState(() {
                    _selectedSource = CaseSource.reception;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('التحاليل'),
                selected: _selectedSource == CaseSource.laboratory,
                onSelected: (_) {
                  setState(() {
                    _selectedSource = CaseSource.laboratory;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (filteredCases.isEmpty)
            const EmptyStateCard(
              icon: Icons.filter_alt_off_rounded,
              title: 'لا توجد نتائج مطابقة',
              message:
                  'جرّب تغيير الفلتر أو البحث باسم آخر للوصول إلى الحالة المطلوبة.',
            )
          else
            Column(
              children: filteredCases.map((item) {
                final isSelected =
                    item.id == _selectedCaseId ||
                    (_selectedCaseId == null &&
                        filteredCases.first.id == item.id);

                return InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    setState(() {
                      _selectedCaseId = item.id;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.08)
                          : AppTheme.softBackground,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.transparent,
                      ),
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
                            item.source.icon,
                            size: 20,
                            color: item.source == CaseSource.reception
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
                                item.patientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.source.label} • ${item.serviceLabel}',
                                style: const TextStyle(
                                  color: AppTheme.mutedText,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ClinicFormatters.formatDateTime(item.createdAt),
                                style: const TextStyle(
                                  color: AppTheme.mutedText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          ClinicFormatters.formatCurrency(item.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCaseDetailsCard({
    required ClinicAppController controller,
    required DiagnosisCase? diagnosisCase,
  }) {
    return SectionCard(
      title: 'تفاصيل الحالة',
      subtitle: 'عرض سريع لبيانات الحالة والهوية وقيمة الفاتورة والملاحظات.',
      child: diagnosisCase == null
          ? const EmptyStateCard(
              icon: Icons.folder_open_rounded,
              title: 'اختر حالة من القائمة',
              message:
                  'عند اختيار حالة ستظهر هنا التفاصيل الكاملة وإجراءات الفاتورة.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    StatusChip(
                      label: diagnosisCase.source.label,
                      color: diagnosisCase.source == CaseSource.reception
                          ? AppTheme.primary
                          : AppTheme.secondary,
                      icon: diagnosisCase.source.icon,
                    ),
                    StatusChip(
                      label: ClinicFormatters.formatCurrency(
                        diagnosisCase.amount,
                      ),
                      color: AppTheme.accent,
                      icon: Icons.payments_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _InfoLine(
                  label: 'اسم المريض',
                  value: diagnosisCase.patientName,
                ),
                _InfoLine(
                  label: 'نوع الخدمة',
                  value: diagnosisCase.serviceLabel,
                ),
                _InfoLine(label: 'الجنسية', value: diagnosisCase.nationality),
                _InfoLine(label: 'رقم الهوية', value: diagnosisCase.nationalId),
                _InfoLine(
                  label: 'رقم الجوال',
                  value: diagnosisCase.phoneNumber,
                ),
                _InfoLine(label: 'العنوان', value: diagnosisCase.address),
                _InfoLine(
                  label: 'تاريخ التسجيل',
                  value: ClinicFormatters.formatDateTime(
                    diagnosisCase.createdAt,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.softBackground,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الملاحظات الطبية / التشغيلية',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        diagnosisCase.notes,
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () =>
                            _shareInvoice(controller, diagnosisCase),
                        icon: const Icon(
                          Icons.file_download_outlined,
                          size: 18,
                        ),
                        label: const Text(
                          'حفظ / مشاركة PDF',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () =>
                            _printInvoice(controller, diagnosisCase),
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: const Text(
                          'طباعة الفاتورة',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.mutedText,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
