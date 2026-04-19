import 'package:flutter/material.dart';

enum ClinicSection { dashboard, reception, laboratory, diagnosis, reports }

enum VisitType { consultation, treatment, emergency }

extension VisitTypeX on VisitType {
  String get label {
    switch (this) {
      case VisitType.consultation:
        return 'كشف';
      case VisitType.treatment:
        return 'علاج';
      case VisitType.emergency:
        return 'خدمات طوارئ';
    }
  }
}

enum CaseSource { reception, laboratory }

extension CaseSourceX on CaseSource {
  String get label {
    switch (this) {
      case CaseSource.reception:
        return 'الاستقبال';
      case CaseSource.laboratory:
        return 'التحاليل';
    }
  }

  IconData get icon {
    switch (this) {
      case CaseSource.reception:
        return Icons.person_add_alt_1_rounded;
      case CaseSource.laboratory:
        return Icons.biotech_rounded;
    }
  }
}

class PatientProfile {
  const PatientProfile({
    required this.id,
    required this.fullName,
    required this.nationality,
    required this.nationalId,
    required this.birthDate,
    required this.phoneNumber,
    required this.address,
    this.workplace,
  });

  final String id;
  final String fullName;
  final String nationality;
  final String nationalId;
  final DateTime birthDate;
  final String phoneNumber;
  final String address;
  final String? workplace;

  PatientProfile copyWith({
    String? id,
    String? fullName,
    String? nationality,
    String? nationalId,
    DateTime? birthDate,
    String? phoneNumber,
    String? address,
    String? workplace,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nationality: nationality ?? this.nationality,
      nationalId: nationalId ?? this.nationalId,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      workplace: workplace ?? this.workplace,
    );
  }
}

class ReceptionRecord {
  const ReceptionRecord({
    required this.id,
    required this.patient,
    required this.visitType,
    required this.notes,
    required this.amount,
    required this.createdAt,
    required this.invoiceId,
  });

  final String id;
  final PatientProfile patient;
  final VisitType visitType;
  final String notes;
  final double amount;
  final DateTime createdAt;
  final String invoiceId;

  ReceptionRecord copyWith({
    String? id,
    PatientProfile? patient,
    VisitType? visitType,
    String? notes,
    double? amount,
    DateTime? createdAt,
    String? invoiceId,
  }) {
    return ReceptionRecord(
      id: id ?? this.id,
      patient: patient ?? this.patient,
      visitType: visitType ?? this.visitType,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      invoiceId: invoiceId ?? this.invoiceId,
    );
  }
}

class LaboratoryOrder {
  const LaboratoryOrder({
    required this.id,
    required this.patient,
    required this.analysisType,
    required this.notes,
    required this.amount,
    required this.createdAt,
    required this.invoiceId,
  });

  final String id;
  final PatientProfile patient;
  final String analysisType;
  final String notes;
  final double amount;
  final DateTime createdAt;
  final String invoiceId;

  LaboratoryOrder copyWith({
    String? id,
    PatientProfile? patient,
    String? analysisType,
    String? notes,
    double? amount,
    DateTime? createdAt,
    String? invoiceId,
  }) {
    return LaboratoryOrder(
      id: id ?? this.id,
      patient: patient ?? this.patient,
      analysisType: analysisType ?? this.analysisType,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      invoiceId: invoiceId ?? this.invoiceId,
    );
  }
}

class ClinicInvoice {
  const ClinicInvoice({
    required this.id,
    required this.patientName,
    required this.phoneNumber,
    required this.nationalId,
    required this.serviceLabel,
    required this.source,
    required this.amount,
    required this.createdAt,
    required this.notes,
  });

  final String id;
  final String patientName;
  final String phoneNumber;
  final String nationalId;
  final String serviceLabel;
  final CaseSource source;
  final double amount;
  final DateTime createdAt;
  final String notes;

  ClinicInvoice copyWith({
    String? id,
    String? patientName,
    String? phoneNumber,
    String? nationalId,
    String? serviceLabel,
    CaseSource? source,
    double? amount,
    DateTime? createdAt,
    String? notes,
  }) {
    return ClinicInvoice(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nationalId: nationalId ?? this.nationalId,
      serviceLabel: serviceLabel ?? this.serviceLabel,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }
}

class DiagnosisCase {
  const DiagnosisCase({
    required this.id,
    required this.invoiceId,
    required this.patientName,
    required this.nationality,
    required this.nationalId,
    required this.phoneNumber,
    required this.address,
    required this.source,
    required this.serviceLabel,
    required this.notes,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final String invoiceId;
  final String patientName;
  final String nationality;
  final String nationalId;
  final String phoneNumber;
  final String address;
  final CaseSource source;
  final String serviceLabel;
  final String notes;
  final double amount;
  final DateTime createdAt;
}

class RevenuePoint {
  const RevenuePoint({required this.label, required this.value});

  final String label;
  final double value;
}
