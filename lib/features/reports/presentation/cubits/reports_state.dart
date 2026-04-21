part of 'reports_cubit.dart';

sealed class ReportsState {}

class ReportsInitial extends ReportsState {}
class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final double todayRevenue;
  final double weeklyRevenue;
  final double monthlyRevenue;
  final double yearlyRevenue;
  final double averageInvoice;
  final int totalPatients;
  final int totalInvoices;
  final List<ClinicInvoice> recentInvoices;
  final Map<CaseSource, double> revenueBySource;
  final List<RevenuePoint> monthlyRevenueTrend;
  final List<RevenuePoint> dailyRevenueTrend;
  final List<RevenuePoint> topServices;

  ReportsLoaded({
    required this.todayRevenue,
    required this.weeklyRevenue,
    required this.monthlyRevenue,
    required this.yearlyRevenue,
    required this.averageInvoice,
    required this.totalPatients,
    required this.totalInvoices,
    required this.recentInvoices,
    required this.revenueBySource,
    required this.monthlyRevenueTrend,
    required this.dailyRevenueTrend,
    required this.topServices,
  });
}

class ReportsError extends ReportsState {
  final String message;
  ReportsError(this.message);
}
