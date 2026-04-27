import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/laboratory_cubit.dart';
import '../../invoices/presentation/cubits/invoices_cubit.dart';
import '../../reports/presentation/cubits/reports_cubit.dart';
import '../../../core/models/clinic_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clinic_formatters.dart';
import '../../../core/utils/invoice_pdf_service.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_chip.dart';

class LaboratoryPage extends StatefulWidget {
  const LaboratoryPage({super.key});

  @override
  State<LaboratoryPage> createState() => _LaboratoryPageState();
}

class _LaboratoryPageState extends State<LaboratoryPage> {
  static const List<String> _analysisOptions = [
    'CBC + Iron Profile',
    'Vitamin D + B12',
    'Thyroid Profile',
    'Liver Function Test',
    'Kidney Function Test',
    'HbA1c + Glucose',
    'تحاليل شاملة أخرى',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _birthDate;
  String _analysisType = _analysisOptions.first;
  String? _editingOrderId;
  String? _editingInvoiceId;
  DateTime? _editingCreatedAt;

  final ScrollController _scrollController = ScrollController();

  bool get _isEditing => _editingOrderId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _nationalityController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int? get _age =>
      _birthDate == null ? null : ClinicFormatters.calculateAge(_birthDate!);

  Future<void> _pickBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      locale: const Locale('ar'),
      initialDate: _birthDate ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _birthDate = pickedDate;
    });
  }

  Future<void> _submit({required bool printAfterSaving}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار تاريخ الميلاد أولًا.')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال سعر صحيح للتحليل.')),
      );
      return;
    }

    final patient = PatientProfile(
      id: _editingOrderId ?? '', // Signals DB to generate UUID
      fullName: _nameController.text.trim(),
      nationality: _nationalityController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      birthDate: _birthDate!,
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    final orderCreatedAt = _editingCreatedAt ?? DateTime.now();
    final invoiceId = _editingInvoiceId ?? '';

    final order = LaboratoryOrder(
      id: _editingOrderId ?? '',
      patient: patient,
      analysisType: _analysisType,
      notes: _notesController.text.trim(),
      amount: amount,
      createdAt: orderCreatedAt,
      invoiceId: invoiceId,
    );

    final invoice = ClinicInvoice(
      id: invoiceId,
      patientName: patient.fullName,
      phoneNumber: patient.phoneNumber,
      nationalId: patient.nationalId,
      serviceLabel: _analysisType,
      source: CaseSource.laboratory,
      amount: amount,
      createdAt: orderCreatedAt,
      notes: order.notes.isEmpty ? 'تحليل معمل' : order.notes,
      nationality: patient.nationality,
      birthDate: patient.birthDate,
    );

    context.read<LaboratoryCubit>().addOrder(order, patient, invoice);

    if (!mounted) {
      return;
    }

    if (printAfterSaving) {
      await InvoicePdfService.printInvoice(
        invoice: invoice,
        doctorName: 'طبيب معتمد',
      );
    }

    if (!mounted) {
      return;
    }
  }

  void _loadOrderForEditing(LaboratoryOrder order) {
    setState(() {
      _editingOrderId = order.id;
      _editingInvoiceId = order.invoiceId;
      _editingCreatedAt = order.createdAt;
      _nameController.text = order.patient.fullName;
      _nationalityController.text = order.patient.nationality;
      _nationalIdController.text = order.patient.nationalId;
      _phoneController.text = order.patient.phoneNumber;
      _addressController.text = order.patient.address;
      _amountController.text = order.amount.toStringAsFixed(0);
      _notesController.text = order.notes;
      _analysisType = order.analysisType;
      _birthDate = order.patient.birthDate;
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _nationalityController.clear();
    _nationalIdController.clear();
    _phoneController.clear();
    _addressController.clear();
    _amountController.clear();
    _notesController.clear();

    setState(() {
      _birthDate = null;
      _analysisType = _analysisOptions.first;
      _editingOrderId = null;
      _editingInvoiceId = null;
      _editingCreatedAt = null;
    });
  }

  Future<void> _shareInvoice(ClinicInvoice invoice) async {
    await InvoicePdfService.shareInvoice(
      invoice: invoice,
      doctorName: 'طبيب معتمد',
    );
  }

  Future<void> _printInvoice(ClinicInvoice invoice) async {
    await InvoicePdfService.printInvoice(
      invoice: invoice,
      doctorName: 'طبيب معتمد',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LaboratoryCubit, LaboratoryState>(
      listener: (context, state) {
        if (state is LaboratoryOperationSuccess) {
          _resetForm();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ التحليل بنجاح.'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is LaboratoryOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is LaboratoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<LaboratoryOrder> currentOrders = [];
        if (state is LaboratoryLoaded ||
            state is LaboratoryOperationLoading ||
            state is LaboratoryOperationSuccess ||
            state is LaboratoryOperationError) {
          if (state is LaboratoryLoaded) currentOrders = state.orders;
          if (state is LaboratoryOperationLoading) currentOrders = state.orders;
          if (state is LaboratoryOperationSuccess) currentOrders = state.orders;
          if (state is LaboratoryOperationError) currentOrders = state.orders;
        }

        final width = MediaQuery.of(context).size.width;
        final isWide = width >= 1180;
        final orders = currentOrders.take(6).toList();

        final isLoading = state is LaboratoryOperationLoading;

        return Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(isWide ? 28 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4FBFB),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusChip(
                              label: 'التحاليل',
                              color: AppTheme.secondary,
                              icon: Icons.biotech_rounded,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'تسجيل طلبات التحاليل وإصدار الفواتير',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.ink,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'الصفحة مجهزة لإدخال بيانات العميل، اختيار التحليل، ثم حفظ أو طباعة الفاتورة فورًا.',
                              style: TextStyle(color: AppTheme.mutedText),
                            ),
                          ],
                        ),
                        StatusChip(
                          label: _age == null
                              ? 'العمر سيُحتسب تلقائيًا'
                              : 'العمر: $_age سنة',
                          color: AppTheme.accent,
                          icon: Icons.cake_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildFormCard()),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              _buildOrdersCard(orders),
                              const SizedBox(height: 16),
                              //  _buildInsightsCard(context),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildFormCard(),
                    const SizedBox(height: 16),
                    _buildOrdersCard(orders),
                    const SizedBox(height: 16),
                    //  _buildInsightsCard(context),
                  ],
                ],
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.secondary,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'جاري حفظ البيانات...',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFormCard() {
    return SectionCard(
      title: _isEditing ? 'تعديل طلب التحليل' : 'إضافة طلب تحليل جديد',
      subtitle:
          'كل ما يلزم لإدخال بيانات العميل وإصدار فاتورة التحليل من مكان واحد.',
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final spacing = 12.0;
            final itemWidth = (constraints.maxWidth - spacing) / 2;
            final fullWidth = constraints.maxWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: spacing,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: fullWidth,
                      child: _LabInput(
                        controller: _nameController,
                        label: 'اسم العميل',
                        hint: 'الاسم الرباعي',
                        icon: Icons.badge_rounded,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: fullWidth,
                      child: _LabInput(
                        controller: _nationalIdController,
                        label: 'رقم الهوية',
                        hint: 'الرقم القومي',
                        icon: Icons.credit_card_rounded,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: fullWidth,
                      child: _LabInput(
                        controller: _phoneController,
                        label: 'رقم الجوال',
                        hint: 'رقم التواصل',
                        icon: Icons.call_rounded,
                        keyboardType: TextInputType.phone,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _LabDatePickerField(
                        label: 'تاريخ الميلاد',
                        value: _birthDate == null
                            ? 'اختر التاريخ'
                            : ClinicFormatters.formatDate(_birthDate!),
                        icon: Icons.calendar_month_rounded,
                        onTap: _pickBirthDate,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _LabInput(
                        controller: _nationalityController,
                        label: 'الجنسية',
                        hint: 'مثل: مصري',
                        icon: Icons.flag_rounded,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: DropdownButtonFormField<String>(
                        initialValue: _analysisType,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'نوع التحليل',
                          labelStyle: TextStyle(fontSize: 13),
                          prefixIcon: Icon(Icons.biotech_rounded, size: 20),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.ink,
                        ),
                        items: _analysisOptions
                            .map(
                              (option) => DropdownMenuItem(
                                value: option,
                                child: Text(
                                  option,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _analysisType = value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _LabInput(
                        controller: _amountController,
                        label: 'سعر التحليل',
                        hint: 'مثال: 430',
                        icon: Icons.payments_rounded,
                        keyboardType: TextInputType.number,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: fullWidth,
                      child: _LabInput(
                        controller: _addressController,
                        label: 'العنوان',
                        hint: 'المنطقة',
                        icon: Icons.location_on_rounded,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: fullWidth,
                      child: _LabInput(
                        controller: _notesController,
                        label: 'ملاحظات الطلب',
                        hint: 'تفاصيل أو توصيات...',
                        icon: Icons.notes_rounded,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () => _submit(printAfterSaving: false),
                      icon: Icon(
                        _isEditing ? Icons.save_as_rounded : Icons.save_rounded,
                        size: 18,
                      ),
                      label: Text(
                        _isEditing ? 'تحديث' : 'حفظ',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () => _submit(printAfterSaving: true),
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text(
                        'وطباعة',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _resetForm,
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text(
                        'تفريغ',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrdersCard(List<LaboratoryOrder> orders) {
    return SectionCard(
      title: 'آخر طلبات التحاليل',
      subtitle: 'عدّل البيانات أو أعد حفظ الفاتورة وطباعتها مباشرة.',
      child: orders.isEmpty
          ? const EmptyStateCard(
              icon: Icons.biotech_rounded,
              title: 'لا توجد طلبات تحاليل بعد',
              message:
                  'عند إضافة أول طلب تحليل سيظهر هنا آخر السجلات تلقائيًا.',
            )
          : Column(
              children: orders.map((order) {
                final invoicesState = context.read<InvoicesCubit>().state;
                ClinicInvoice? invoice;
                if (invoicesState is InvoicesLoaded) {
                  invoice = invoicesState.invoices
                      .cast<ClinicInvoice?>()
                      .firstWhere(
                        (inv) => inv?.id == order.invoiceId,
                        orElse: () => null,
                      );
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.softBackground,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.biotech_rounded,
                              color: AppTheme.secondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.patient.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${order.analysisType} • ${ClinicFormatters.formatCurrency(order.amount)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.mutedText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: () => _loadOrderForEditing(order),
                            icon: const Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: AppTheme.mutedText,
                            ),
                            tooltip: 'تعديل',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ClinicFormatters.formatDateTime(order.createdAt),
                            style: const TextStyle(
                              color: AppTheme.mutedText,
                              fontSize: 11,
                            ),
                          ),
                          if (invoice != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  onPressed: () => _shareInvoice(invoice!),
                                  icon: const Icon(
                                    Icons.file_download_outlined,
                                    size: 18,
                                    color: AppTheme.mutedText,
                                  ),
                                  tooltip: 'PDF',
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  onPressed: () => _printInvoice(invoice!),
                                  icon: const Icon(
                                    Icons.print_rounded,
                                    size: 18,
                                    color: AppTheme.primary,
                                  ),
                                  tooltip: 'طباعة',
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildInsightsCard(BuildContext context) {
    final reportsState = context.watch<ReportsCubit>().state;
    List<RevenuePoint> topServices = [];
    if (reportsState is ReportsLoaded) {
      topServices = reportsState.topServices.take(3).toList();
    }

    return SectionCard(
      title: 'ملاحظات تشغيلية',
      subtitle: 'إضافات عملية تساعد موظف المعمل على إنجاز الشغل بسرعة.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InsightLine(text: 'حساب العمر يتم تلقائيًا من تاريخ الميلاد.'),
          const SizedBox(height: 12),
          const _InsightLine(
            text: 'يمكن تعديل الطلبات السابقة مباشرة من القائمة الجانبية.',
          ),
          const SizedBox(height: 12),
          const _InsightLine(
            text: 'سعر كل تحليل يدخل فورًا في صفحة الإيرادات.',
          ),
          const SizedBox(height: 18),
          if (topServices.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.softBackground,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'أعلى خدمات دخلاً',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  ...topServices.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(child: Text(item.label)),
                          const SizedBox(width: 12),
                          Text(
                            ClinicFormatters.formatCurrency(item.value),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }
}

class _LabInput extends StatelessWidget {
  const _LabInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontSize: 13),
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, size: 20),
        alignLabelWithHint: maxLines > 1,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        isDense: true,
      ),
    );
  }
}

class _LabDatePickerField extends StatelessWidget {
  const _LabDatePickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: Icon(icon, size: 20),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          isDense: true,
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: value == 'اختر التاريخ' ? AppTheme.mutedText : AppTheme.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InsightLine extends StatelessWidget {
  const _InsightLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(
            Icons.check_circle_rounded,
            color: AppTheme.secondary,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.ink, height: 1.5),
          ),
        ),
      ],
    );
  }
}
