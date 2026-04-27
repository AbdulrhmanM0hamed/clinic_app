import 'package:flutter/material.dart';

import '../../../../core/models/clinic_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/clinic_formatters.dart';

class InvoiceRow extends StatelessWidget {
  const InvoiceRow({super.key, required this.invoice});

  final ClinicInvoice invoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.softBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              invoice.source.icon,
              color: invoice.source == CaseSource.reception
                  ? AppTheme.primary
                  : AppTheme.secondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${invoice.source.label} • ${invoice.serviceLabel}',
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
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ClinicFormatters.formatCurrency(invoice.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ClinicFormatters.formatDateTime(invoice.createdAt),
                style: const TextStyle(color: AppTheme.mutedText, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
