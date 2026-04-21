import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/reception_cubit.dart';
import '../../invoices/presentation/cubits/invoices_cubit.dart';
import '../../../core/models/clinic_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clinic_formatters.dart';
import '../../../core/utils/invoice_pdf_service.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_chip.dart';

class ReceptionPage extends StatefulWidget {
  const ReceptionPage({super.key});

  @override
  State<ReceptionPage> createState() => _ReceptionPageState();
}

class _ReceptionPageState extends State<ReceptionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _workplaceController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _birthDate;
  VisitType _visitType = VisitType.consultation;
  String? _editingRecordId;
  String? _editingInvoiceId;
  DateTime? _editingCreatedAt;

  bool get _isEditing => _editingRecordId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _nationalityController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _workplaceController.dispose();
    _amountController.dispose();
    _notesController.dispose();
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
        const SnackBar(
          content: Text('يرجى اختيار تاريخ الميلاد لحساب العمر تلقائيًا.'),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال سعر صحيح للخدمة.')),
      );
      return;
    }

    final patient = PatientProfile(
      id:
          _editingRecordId ??
          '', // Empty string for new, signals DB to generate UUID
      fullName: _nameController.text.trim(),
      nationality: _nationalityController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      birthDate: _birthDate!,
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      workplace: _workplaceController.text.trim(),
    );

    final recordCreatedAt = _editingCreatedAt ?? DateTime.now();
    final invoiceId = _editingInvoiceId ?? ''; // Empty string for new

    final record = ReceptionRecord(
      id: _editingRecordId ?? '', // Empty string for new
      patient: patient,
      visitType: _visitType,
      notes: _notesController.text.trim(),
      amount: amount,
      createdAt: recordCreatedAt,
      invoiceId: invoiceId,
    );

    final invoice = ClinicInvoice(
      id: invoiceId,
      patientName: patient.fullName,
      phoneNumber: patient.phoneNumber,
      nationalId: patient.nationalId,
      serviceLabel: _visitType.label,
      source: CaseSource.reception,
      amount: amount,
      createdAt: recordCreatedAt,
      notes: record.notes.isEmpty ? 'مراجعة استقبال' : record.notes,
      nationality: patient.nationality,
      birthDate: patient.birthDate,
    );

    context.read<ReceptionCubit>().addRecord(record, patient, invoice);

    if (!mounted) {
      return;
    }
  }

  void _loadRecordForEditing(ReceptionRecord record) {
    setState(() {
      _editingRecordId = record.id;
      _editingInvoiceId = record.invoiceId;
      _editingCreatedAt = record.createdAt;
      _nameController.text = record.patient.fullName;
      _nationalityController.text = record.patient.nationality;
      _nationalIdController.text = record.patient.nationalId;
      _phoneController.text = record.patient.phoneNumber;
      _addressController.text = record.patient.address;
      _workplaceController.text = record.patient.workplace ?? '';
      _amountController.text = record.amount.toStringAsFixed(0);
      _notesController.text = record.notes;
      _birthDate = record.patient.birthDate;
      _visitType = record.visitType;
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _nationalityController.clear();
    _nationalIdController.clear();
    _phoneController.clear();
    _addressController.clear();
    _workplaceController.clear();
    _amountController.clear();
    _notesController.clear();

    setState(() {
      _birthDate = null;
      _visitType = VisitType.consultation;
      _editingRecordId = null;
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
    return BlocConsumer<ReceptionCubit, ReceptionState>(
      listener: (context, state) {
        if (state is ReceptionOperationSuccess) {
          _resetForm();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ البيانات بنجاح في قاعدة البيانات.'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ReceptionOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is ReceptionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<ReceptionRecord> records = [];
        if (state is ReceptionLoaded ||
            state is ReceptionOperationLoading ||
            state is ReceptionOperationSuccess ||
            state is ReceptionOperationError) {
          if (state is ReceptionLoaded) records = state.records;
          if (state is ReceptionOperationLoading) records = state.records;
          if (state is ReceptionOperationSuccess) records = state.records;
          if (state is ReceptionOperationError) records = state.records;
        }

        final width = MediaQuery.of(context).size.width;
        final isWide = width >= 1180;
        final recentRecords = records.take(6).toList();

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
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusChip(
                          label: 'الاستقبال',
                          color: AppTheme.primary,
                          icon: Icons.person_add_alt_1_rounded,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'إدارة دخول المرضى والفواتير العلاجية',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.ink,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'املأ بيانات المريض، حدّد نوع الخدمة، ثم احفظ أو اطبع الفاتورة مباشرة.',
                          style: TextStyle(color: AppTheme.mutedText),
                        ),
                      ],
                    ),
                    StatusChip(
                      label: _age == null
                          ? 'العمر سيظهر تلقائيًا'
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
                          _buildOperationsCard(recentRecords),
                          const SizedBox(height: 16),
                          //   _buildHelpCard(),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _buildFormCard(),
                const SizedBox(height: 16),
                _buildOperationsCard(recentRecords),
                const SizedBox(height: 16),
                //    _buildHelpCard(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormCard() {
    return SectionCard(
      title: _isEditing ? 'تعديل بيانات' : 'مريض جديد',
      subtitle: 'حساب العمر تلقائياً، والبيانات قابلة للتعديل.',
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Force 2 columns on most screens to save vertical space
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
                      child: _ReceptionInput(
                        controller: _nameController,
                        label: 'اسم المريض',
                        hint: 'الاسم الرباعي',
                        icon: Icons.badge_rounded,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: fullWidth,
                      child: _ReceptionInput(
                        controller: _nationalIdController,
                        label: 'رقم الهوية',
                        hint: 'الرقم القومي',
                        icon: Icons.credit_card_rounded,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: fullWidth,
                      child: _ReceptionInput(
                        controller: _phoneController,
                        label: 'الجوال',
                        hint: 'رقم التواصل',
                        icon: Icons.call_rounded,
                        keyboardType: TextInputType.phone,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _DatePickerField(
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
                      child: _ReceptionInput(
                        controller: _nationalityController,
                        label: 'الجنسية',
                        hint: 'مثل: مصري',
                        icon: Icons.flag_rounded,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: DropdownButtonFormField<VisitType>(
                        initialValue: _visitType,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'نوع الخدمة',
                          labelStyle: TextStyle(fontSize: 13),
                          prefixIcon: Icon(
                            Icons.local_hospital_rounded,
                            size: 20,
                          ),
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
                        items: VisitType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _visitType = value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _ReceptionInput(
                        controller: _amountController,
                        label: 'السعر',
                        hint: 'مثال: 350',
                        icon: Icons.payments_rounded,
                        keyboardType: TextInputType.number,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: fullWidth,
                      child: _ReceptionInput(
                        controller: _workplaceController,
                        label: 'جهة العمل',
                        hint: 'شركة / حر',
                        icon: Icons.apartment_rounded,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: fullWidth,
                      child: _ReceptionInput(
                        controller: _addressController,
                        label: 'العنوان',
                        hint: 'المنطقة',
                        icon: Icons.location_on_rounded,
                        validator: _requiredValidator,
                      ),
                    ),
                    SizedBox(
                      width: fullWidth,
                      child: _ReceptionInput(
                        controller: _notesController,
                        label: 'ملاحظات',
                        hint: 'تفاصيل الحالة أوالشكوى...',
                        icon: Icons.notes_rounded,
                        maxLines: 2, // reduced maxLines to save space
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

  Widget _buildOperationsCard(List<ReceptionRecord> recentRecords) {
    return SectionCard(
      title: 'آخر عمليات الاستقبال',
      subtitle:
          'يمكنك تعديل البيانات أو إعادة طباعة الفاتورة مباشرة من القائمة.',
      child: recentRecords.isEmpty
          ? const EmptyStateCard(
              icon: Icons.receipt_long_rounded,
              title: 'لا توجد عمليات استقبال بعد',
              message: 'ابدأ بإضافة أول مريض وسيظهر هنا آخر السجلات المسجلة.',
            )
          : Column(
              children: recentRecords.map((record) {
                final invoicesState = context.read<InvoicesCubit>().state;
                ClinicInvoice? invoice;
                if (invoicesState is InvoicesLoaded) {
                  invoice = invoicesState.invoices
                      .cast<ClinicInvoice?>()
                      .firstWhere(
                        (inv) => inv?.id == record.invoiceId,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.patient.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${record.visitType.label} • ${ClinicFormatters.formatCurrency(record.amount)}',
                                  style: const TextStyle(
                                    color: AppTheme.mutedText,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ClinicFormatters.formatDateTime(
                                    record.createdAt,
                                  ),
                                  style: const TextStyle(
                                    color: AppTheme.mutedText,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () =>
                                        _loadRecordForEditing(record),
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      size: 20,
                                      color: AppTheme.mutedText,
                                    ),
                                    tooltip: 'تعديل',
                                  ),
                                  if (invoice != null) ...[
                                    const SizedBox(width: 8),
                                    (() {
                                      final nonNullableInvoice = invoice!;
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _shareInvoice(
                                              nonNullableInvoice,
                                            ),
                                            icon: const Icon(
                                              Icons.file_download_outlined,
                                              size: 20,
                                              color: AppTheme.mutedText,
                                            ),
                                            tooltip: 'PDF',
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _printInvoice(
                                              nonNullableInvoice,
                                            ),
                                            icon: const Icon(
                                              Icons.print_rounded,
                                              size: 20,
                                              color: AppTheme.primary,
                                            ),
                                            tooltip: 'طباعة',
                                          ),
                                        ],
                                      );
                                    })(),
                                  ],
                                ],
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

  Widget _buildHelpCard() {
    return SectionCard(
      title: 'تحسينات مضافة داخل الصفحة',
      subtitle: 'أضفت نقاط تشغيلية مهمة عشان التجربة تكون أقرب لنظام حقيقي.',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TipLine(
            text: 'حساب العمر تلقائيًا من تاريخ الميلاد بدون إدخال يدوي.',
          ),
          SizedBox(height: 12),
          _TipLine(text: 'إمكانية تعديل آخر السجلات مباشرة من نفس الصفحة.'),
          SizedBox(height: 12),
          _TipLine(text: 'حفظ الفاتورة كـ PDF أو طباعتها بضغطة واحدة.'),
          SizedBox(height: 12),
          _TipLine(
            text: 'كل مبلغ يتم حفظه يدخل فورًا في صفحة التقارير المالية.',
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

class _ReceptionInput extends StatelessWidget {
  const _ReceptionInput({
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

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
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

class _TipLine extends StatelessWidget {
  const _TipLine({required this.text});

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
            color: AppTheme.primary,
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
