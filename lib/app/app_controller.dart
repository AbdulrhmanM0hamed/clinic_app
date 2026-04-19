import 'package:flutter/foundation.dart';

import '../core/models/clinic_models.dart';
import '../core/utils/clinic_formatters.dart';

class ClinicAppController extends ChangeNotifier {
  ClinicAppController() {
    _seedDummyData();
  }

  final List<_DoctorAccount> _accounts = const [
    _DoctorAccount(
      username: 'dr.salim',
      password: '123456',
      displayName: 'د. سليم الحكيم',
      specialty: 'باطنة',
    ),
    _DoctorAccount(
      username: 'dr.mariam',
      password: '123456',
      displayName: 'د. مريم عادل',
      specialty: 'تحاليل وتشخيص',
    ),
  ];

  final List<ReceptionRecord> _receptionRecords = [];
  final List<LaboratoryOrder> _laboratoryOrders = [];
  final List<ClinicInvoice> _invoices = [];

  bool _isLoggedIn = false;
  bool _isAuthenticating = false;
  ClinicSection _selectedSection = ClinicSection.dashboard;
  String _doctorName = 'د. سليم الحكيم';
  String _doctorSpecialty = 'باطنة';

  bool get isLoggedIn => _isLoggedIn;
  bool get isAuthenticating => _isAuthenticating;
  ClinicSection get selectedSection => _selectedSection;
  String get doctorName => _doctorName;
  String get doctorSpecialty => _doctorSpecialty;
  String get clinicName => 'عيادتي';

  List<ReceptionRecord> get receptionRecords =>
      List.of(_receptionRecords)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<LaboratoryOrder> get laboratoryOrders =>
      List.of(_laboratoryOrders)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<ClinicInvoice> get invoices =>
      List.of(_invoices)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  int get totalPatients => _receptionRecords.length + _laboratoryOrders.length;

  int get todayPatientsCount => _countCasesBetween(
    ClinicFormatters.startOfDay(DateTime.now()),
    ClinicFormatters.startOfDay(DateTime.now()).add(const Duration(days: 1)),
  );

  double get todayRevenue => revenueBetween(
    ClinicFormatters.startOfDay(DateTime.now()),
    ClinicFormatters.startOfDay(DateTime.now()).add(const Duration(days: 1)),
  );

  double get weeklyRevenue => revenueBetween(
    ClinicFormatters.startOfWeek(DateTime.now()),
    ClinicFormatters.startOfWeek(DateTime.now()).add(const Duration(days: 7)),
  );

  double get monthlyRevenue => revenueBetween(
    ClinicFormatters.startOfMonth(DateTime.now()),
    DateTime(DateTime.now().year, DateTime.now().month + 1),
  );

  double get yearlyRevenue => revenueBetween(
    ClinicFormatters.startOfYear(DateTime.now()),
    DateTime(DateTime.now().year + 1),
  );

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isAuthenticating = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 850));

    _isAuthenticating = false;
    _DoctorAccount? matchedAccount;

    for (final account in _accounts) {
      if (account.username == username.trim().toLowerCase() &&
          account.password == password.trim()) {
        matchedAccount = account;
        break;
      }
    }

    if (matchedAccount == null) {
      notifyListeners();
      return false;
    }

    _doctorName = matchedAccount.displayName;
    _doctorSpecialty = matchedAccount.specialty;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _isLoggedIn = false;
    _selectedSection = ClinicSection.dashboard;
    notifyListeners();
  }

  void selectSection(ClinicSection section) {
    if (_selectedSection == section) {
      return;
    }
    _selectedSection = section;
    notifyListeners();
  }

  ClinicInvoice saveReceptionRecord({
    required String fullName,
    required String nationality,
    required String nationalId,
    required DateTime birthDate,
    required String phoneNumber,
    required String address,
    required String workplace,
    required VisitType visitType,
    required String notes,
    required double amount,
    String? existingRecordId,
    String? existingInvoiceId,
    DateTime? createdAt,
  }) {
    final patient = PatientProfile(
      id: existingRecordId ?? _nextId('PAT'),
      fullName: fullName,
      nationality: nationality,
      nationalId: nationalId,
      birthDate: birthDate,
      phoneNumber: phoneNumber,
      address: address,
      workplace: workplace,
    );

    final recordCreatedAt = createdAt ?? DateTime.now();
    final invoiceId = existingInvoiceId ?? _nextId('INV');

    final record = ReceptionRecord(
      id: existingRecordId ?? _nextId('REC'),
      patient: patient,
      visitType: visitType,
      notes: notes,
      amount: amount,
      createdAt: recordCreatedAt,
      invoiceId: invoiceId,
    );

    final invoice = ClinicInvoice(
      id: invoiceId,
      patientName: fullName,
      phoneNumber: phoneNumber,
      nationalId: nationalId,
      serviceLabel: visitType.label,
      source: CaseSource.reception,
      amount: amount,
      createdAt: recordCreatedAt,
      notes: notes.isEmpty ? 'مراجعة استقبال' : notes,
    );

    _upsertReceptionRecord(record);
    _upsertInvoice(invoice);
    notifyListeners();
    return invoice;
  }

  ClinicInvoice saveLaboratoryOrder({
    required String fullName,
    required String nationality,
    required String nationalId,
    required DateTime birthDate,
    required String phoneNumber,
    required String address,
    required String analysisType,
    required String notes,
    required double amount,
    String? existingOrderId,
    String? existingInvoiceId,
    DateTime? createdAt,
  }) {
    final patient = PatientProfile(
      id: existingOrderId ?? _nextId('PAT'),
      fullName: fullName,
      nationality: nationality,
      nationalId: nationalId,
      birthDate: birthDate,
      phoneNumber: phoneNumber,
      address: address,
    );

    final orderCreatedAt = createdAt ?? DateTime.now();
    final invoiceId = existingInvoiceId ?? _nextId('INV');

    final order = LaboratoryOrder(
      id: existingOrderId ?? _nextId('LAB'),
      patient: patient,
      analysisType: analysisType,
      notes: notes,
      amount: amount,
      createdAt: orderCreatedAt,
      invoiceId: invoiceId,
    );

    final invoice = ClinicInvoice(
      id: invoiceId,
      patientName: fullName,
      phoneNumber: phoneNumber,
      nationalId: nationalId,
      serviceLabel: analysisType,
      source: CaseSource.laboratory,
      amount: amount,
      createdAt: orderCreatedAt,
      notes: notes.isEmpty ? 'طلب تحاليل' : notes,
    );

    _upsertLaboratoryOrder(order);
    _upsertInvoice(invoice);
    notifyListeners();
    return invoice;
  }

  ClinicInvoice? invoiceById(String invoiceId) {
    for (final invoice in _invoices) {
      if (invoice.id == invoiceId) {
        return invoice;
      }
    }
    return null;
  }

  List<DiagnosisCase> get diagnosisCases {
    final cases = <DiagnosisCase>[
      ..._receptionRecords.map(
        (record) => DiagnosisCase(
          id: record.id,
          invoiceId: record.invoiceId,
          patientName: record.patient.fullName,
          nationality: record.patient.nationality,
          nationalId: record.patient.nationalId,
          phoneNumber: record.patient.phoneNumber,
          address: record.patient.address,
          source: CaseSource.reception,
          serviceLabel: record.visitType.label,
          notes: record.notes.isEmpty
              ? 'مراجعة أولية في الاستقبال'
              : record.notes,
          amount: record.amount,
          createdAt: record.createdAt,
        ),
      ),
      ..._laboratoryOrders.map(
        (order) => DiagnosisCase(
          id: order.id,
          invoiceId: order.invoiceId,
          patientName: order.patient.fullName,
          nationality: order.patient.nationality,
          nationalId: order.patient.nationalId,
          phoneNumber: order.patient.phoneNumber,
          address: order.patient.address,
          source: CaseSource.laboratory,
          serviceLabel: order.analysisType,
          notes: order.notes.isEmpty ? 'طلب تحليل جديد' : order.notes,
          amount: order.amount,
          createdAt: order.createdAt,
        ),
      ),
    ];

    cases.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return cases;
  }

  Map<CaseSource, double> revenueBySource() {
    final totals = <CaseSource, double>{
      CaseSource.reception: 0,
      CaseSource.laboratory: 0,
    };

    for (final invoice in _invoices) {
      totals[invoice.source] = (totals[invoice.source] ?? 0) + invoice.amount;
    }

    return totals;
  }

  List<RevenuePoint> monthlyRevenueTrend({int months = 6}) {
    final now = DateTime.now();
    return List.generate(months, (index) {
      final offset = months - index - 1;
      final monthStart = DateTime(now.year, now.month - offset, 1);
      final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 1);
      return RevenuePoint(
        label: ClinicFormatters.monthLabel(monthStart),
        value: revenueBetween(monthStart, monthEnd),
      );
    });
  }

  List<RevenuePoint> dailyRevenueTrend({int days = 7}) {
    final now = DateTime.now();
    return List.generate(days, (index) {
      final day = DateTime(now.year, now.month, now.day - (days - index - 1));
      final nextDay = day.add(const Duration(days: 1));
      return RevenuePoint(
        label: ClinicFormatters.weekdayLabel(day),
        value: revenueBetween(day, nextDay),
      );
    });
  }

  List<RevenuePoint> topServices({int limit = 4}) {
    final totals = <String, double>{};
    for (final invoice in _invoices) {
      totals[invoice.serviceLabel] =
          (totals[invoice.serviceLabel] ?? 0) + invoice.amount;
    }

    final points =
        totals.entries
            .map((entry) => RevenuePoint(label: entry.key, value: entry.value))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return points.take(limit).toList();
  }

  double revenueBetween(DateTime start, DateTime end) {
    return _invoices
        .where(
          (invoice) =>
              !invoice.createdAt.isBefore(start) &&
              invoice.createdAt.isBefore(end),
        )
        .fold<double>(0, (sum, invoice) => sum + invoice.amount);
  }

  int _countCasesBetween(DateTime start, DateTime end) {
    final totalReception = _receptionRecords.where(
      (record) =>
          !record.createdAt.isBefore(start) && record.createdAt.isBefore(end),
    );
    final totalLab = _laboratoryOrders.where(
      (order) =>
          !order.createdAt.isBefore(start) && order.createdAt.isBefore(end),
    );
    return totalReception.length + totalLab.length;
  }

  void _upsertReceptionRecord(ReceptionRecord record) {
    final index = _receptionRecords.indexWhere(
      (element) => element.id == record.id,
    );
    if (index == -1) {
      _receptionRecords.add(record);
      return;
    }
    _receptionRecords[index] = record;
  }

  void _upsertLaboratoryOrder(LaboratoryOrder order) {
    final index = _laboratoryOrders.indexWhere(
      (element) => element.id == order.id,
    );
    if (index == -1) {
      _laboratoryOrders.add(order);
      return;
    }
    _laboratoryOrders[index] = order;
  }

  void _upsertInvoice(ClinicInvoice invoice) {
    final index = _invoices.indexWhere((element) => element.id == invoice.id);
    if (index == -1) {
      _invoices.add(invoice);
      return;
    }
    _invoices[index] = invoice;
  }

  void _seedDummyData() {
    if (_invoices.isNotEmpty) {
      return;
    }

    final now = DateTime.now();

    final receptionSeed = <ReceptionRecord>[
      ReceptionRecord(
        id: 'REC-1001',
        patient: PatientProfile(
          id: 'PAT-1001',
          fullName: 'أحمد سامح',
          nationality: 'مصري',
          nationalId: '29801011234567',
          birthDate: DateTime(1998, 1, 1),
          phoneNumber: '01001234567',
          address: 'مدينة نصر - القاهرة',
          workplace: 'مهندس مدني',
        ),
        visitType: VisitType.consultation,
        notes: 'شكوى من صداع متكرر وارتفاع بسيط في الضغط.',
        amount: 350,
        createdAt: now.subtract(const Duration(hours: 2)),
        invoiceId: 'INV-7001',
      ),
      ReceptionRecord(
        id: 'REC-1002',
        patient: PatientProfile(
          id: 'PAT-1002',
          fullName: 'سارة محمود',
          nationality: 'سعودية',
          nationalId: '2045897761',
          birthDate: DateTime(1991, 4, 12),
          phoneNumber: '0551234567',
          address: 'الرياض - حي الندى',
          workplace: 'معلمة',
        ),
        visitType: VisitType.treatment,
        notes: 'جلسة متابعة وخطة علاج أسبوعية.',
        amount: 520,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        invoiceId: 'INV-7002',
      ),
      ReceptionRecord(
        id: 'REC-1003',
        patient: PatientProfile(
          id: 'PAT-1003',
          fullName: 'يوسف طارق',
          nationality: 'مصري',
          nationalId: '30111251234562',
          birthDate: DateTime(2001, 11, 25),
          phoneNumber: '01144556677',
          address: 'المعادي - القاهرة',
          workplace: 'طالب',
        ),
        visitType: VisitType.emergency,
        notes: 'حالة طوارئ مع ألم حاد بالصدر وتم التوجيه للفحوصات.',
        amount: 780,
        createdAt: now.subtract(const Duration(days: 4, hours: 1)),
        invoiceId: 'INV-7003',
      ),
      ReceptionRecord(
        id: 'REC-1004',
        patient: PatientProfile(
          id: 'PAT-1004',
          fullName: 'لينا خالد',
          nationality: 'أردنية',
          nationalId: '9876543210',
          birthDate: DateTime(1987, 7, 10),
          phoneNumber: '0799988776',
          address: 'عمان - الجبيهة',
          workplace: 'محاسبة',
        ),
        visitType: VisitType.consultation,
        notes: 'كشف دوري ومراجعة نتائج سابقة.',
        amount: 300,
        createdAt: now.subtract(const Duration(days: 36)),
        invoiceId: 'INV-7004',
      ),
    ];

    final laboratorySeed = <LaboratoryOrder>[
      LaboratoryOrder(
        id: 'LAB-2001',
        patient: PatientProfile(
          id: 'PAT-2001',
          fullName: 'نهى جابر',
          nationality: 'مصري',
          nationalId: '29507041234565',
          birthDate: DateTime(1995, 7, 4),
          phoneNumber: '01099887766',
          address: 'الهرم - الجيزة',
        ),
        analysisType: 'CBC + Iron Profile',
        notes: 'تحليل عاجل مع إرسال نسخة للطبيب.',
        amount: 430,
        createdAt: now.subtract(const Duration(hours: 5)),
        invoiceId: 'INV-7101',
      ),
      LaboratoryOrder(
        id: 'LAB-2002',
        patient: PatientProfile(
          id: 'PAT-2002',
          fullName: 'عبدالله عادل',
          nationality: 'كويتي',
          nationalId: '2845563321',
          birthDate: DateTime(1989, 2, 19),
          phoneNumber: '66990011',
          address: 'السالمية - الكويت',
        ),
        analysisType: 'Vitamin D + B12',
        notes: 'نتيجة خلال 24 ساعة.',
        amount: 640,
        createdAt: now.subtract(const Duration(days: 2, hours: 2)),
        invoiceId: 'INV-7102',
      ),
      LaboratoryOrder(
        id: 'LAB-2003',
        patient: PatientProfile(
          id: 'PAT-2003',
          fullName: 'ريم إبراهيم',
          nationality: 'مصري',
          nationalId: '29003021234560',
          birthDate: DateTime(1990, 3, 2),
          phoneNumber: '01233445566',
          address: 'طنطا - الغربية',
        ),
        analysisType: 'Thyroid Profile',
        notes: 'متابعة غدة درقية.',
        amount: 590,
        createdAt: now.subtract(const Duration(days: 14)),
        invoiceId: 'INV-7103',
      ),
      LaboratoryOrder(
        id: 'LAB-2004',
        patient: PatientProfile(
          id: 'PAT-2004',
          fullName: 'محمد الحسن',
          nationality: 'سوداني',
          nationalId: 'A12233445',
          birthDate: DateTime(1984, 9, 16),
          phoneNumber: '0912233445',
          address: 'الخرطوم - المنشية',
        ),
        analysisType: 'Liver Function Test',
        notes: 'مراجعة استجابة علاجية بعد 3 أشهر.',
        amount: 460,
        createdAt: now.subtract(const Duration(days: 70)),
        invoiceId: 'INV-7104',
      ),
    ];

    _receptionRecords.addAll(receptionSeed);
    _laboratoryOrders.addAll(laboratorySeed);

    for (final record in receptionSeed) {
      _invoices.add(
        ClinicInvoice(
          id: record.invoiceId,
          patientName: record.patient.fullName,
          phoneNumber: record.patient.phoneNumber,
          nationalId: record.patient.nationalId,
          serviceLabel: record.visitType.label,
          source: CaseSource.reception,
          amount: record.amount,
          createdAt: record.createdAt,
          notes: record.notes,
        ),
      );
    }

    for (final order in laboratorySeed) {
      _invoices.add(
        ClinicInvoice(
          id: order.invoiceId,
          patientName: order.patient.fullName,
          phoneNumber: order.patient.phoneNumber,
          nationalId: order.patient.nationalId,
          serviceLabel: order.analysisType,
          source: CaseSource.laboratory,
          amount: order.amount,
          createdAt: order.createdAt,
          notes: order.notes,
        ),
      );
    }
  }

  String _nextId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}

class _DoctorAccount {
  const _DoctorAccount({
    required this.username,
    required this.password,
    required this.displayName,
    required this.specialty,
  });

  final String username;
  final String password;
  final String displayName;
  final String specialty;
}
