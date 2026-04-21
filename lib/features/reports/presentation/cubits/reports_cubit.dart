import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/clinic_models.dart';
import '../../../../core/utils/clinic_formatters.dart';
import '../../../invoices/data/repo/invoices_repo.dart';

part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final InvoicesRepo _invoicesRepo;

  ReportsCubit(this._invoicesRepo) : super(ReportsInitial());

  Future<void> fetchReports() async {
    emit(ReportsLoading());
    final result = await _invoicesRepo.fetchInvoices();
    
    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (invoices) {
        emit(_calculateStats(invoices));
      },
    );
  }

  ReportsLoaded _calculateStats(List<ClinicInvoice> invoices) {
    final now = DateTime.now();

    final todayStart = ClinicFormatters.startOfDay(now);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final todayRev = _revenueBetween(invoices, todayStart, todayEnd);

    final weekStart = ClinicFormatters.startOfWeek(now);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final weeklyRev = _revenueBetween(invoices, weekStart, weekEnd);

    final monthStart = ClinicFormatters.startOfMonth(now);
    final monthEnd = DateTime(now.year, now.month + 1);
    final monthlyRev = _revenueBetween(invoices, monthStart, monthEnd);

    final yearStart = ClinicFormatters.startOfYear(now);
    final yearEnd = DateTime(now.year + 1);
    final yearlyRev = _revenueBetween(invoices, yearStart, yearEnd);

    final avgInvoice = invoices.isEmpty
        ? 0.0
        : invoices.fold<double>(0, (sum, item) => sum + item.amount) / invoices.length;

    final totalInvs = invoices.length;
    // Estimate total patients from invoices (reception + lab)
    final totalPats = invoices.length; // Approximate 1:1 mapping mapping since invoices mirror records
    final recent = invoices.take(8).toList();

    final mix = <CaseSource, double>{
      CaseSource.reception: 0,
      CaseSource.laboratory: 0,
    };
    for (final invoice in invoices) {
      mix[invoice.source] = (mix[invoice.source] ?? 0) + invoice.amount;
    }

    // Monthly Trend
    final monthlyTrend = List.generate(6, (index) {
      final offset = 6 - index - 1;
      final mStart = DateTime(now.year, now.month - offset, 1);
      final mEnd = DateTime(mStart.year, mStart.month + 1, 1);
      return RevenuePoint(
        label: ClinicFormatters.monthLabel(mStart),
        value: _revenueBetween(invoices, mStart, mEnd),
      );
    });

    // Daily Trend
    final dailyTrend = List.generate(7, (index) {
      final days = 7;
      final day = DateTime(now.year, now.month, now.day - (days - index - 1));
      final nextDay = day.add(const Duration(days: 1));
      return RevenuePoint(
        label: ClinicFormatters.weekdayLabel(day),
        value: _revenueBetween(invoices, day, nextDay),
      );
    });

    // Top Services
    final totals = <String, double>{};
    for (final invoice in invoices) {
      totals[invoice.serviceLabel] = (totals[invoice.serviceLabel] ?? 0) + invoice.amount;
    }
    final points = totals.entries
        .map((entry) => RevenuePoint(label: entry.key, value: entry.value))
        .toList()..sort((a, b) => b.value.compareTo(a.value));
    final topServs = points.take(4).toList();

    return ReportsLoaded(
      todayRevenue: todayRev,
      weeklyRevenue: weeklyRev,
      monthlyRevenue: monthlyRev,
      yearlyRevenue: yearlyRev,
      averageInvoice: avgInvoice,
      totalPatients: totalPats,
      totalInvoices: totalInvs,
      recentInvoices: recent,
      revenueBySource: mix,
      monthlyRevenueTrend: monthlyTrend,
      dailyRevenueTrend: dailyTrend,
      topServices: topServs,
    );
  }

  double _revenueBetween(List<ClinicInvoice> invoices, DateTime start, DateTime end) {
    return invoices
        .where((inv) => !inv.createdAt.isBefore(start) && inv.createdAt.isBefore(end))
        .fold<double>(0, (sum, inv) => sum + inv.amount);
  }
}
