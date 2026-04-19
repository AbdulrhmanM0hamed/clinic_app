import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/clinic_models.dart';
import 'clinic_formatters.dart';

class InvoicePdfService {
  static Future<void> printInvoice({
    required ClinicInvoice invoice,
    required String doctorName,
  }) async {
    final bytes = await buildInvoice(invoice: invoice, doctorName: doctorName);

    await Printing.layoutPdf(
      name: '${invoice.id}.pdf',
      onLayout: (format) async => bytes,
    );
  }

  static Future<void> shareInvoice({
    required ClinicInvoice invoice,
    required String doctorName,
  }) async {
    final bytes = await buildInvoice(invoice: invoice, doctorName: doctorName);

    await Printing.sharePdf(bytes: bytes, filename: '${invoice.id}.pdf');
  }

  static Future<Uint8List> buildInvoice({
    required ClinicInvoice invoice,
    required String doctorName,
  }) async {
    final regularFont = await _loadFont(PdfGoogleFonts.cairoRegular);
    final boldFont = await _loadFont(PdfGoogleFonts.cairoBold);
    final fallbackBase = pw.Font.helvetica();
    final fallbackBold = pw.Font.helveticaBold();

    final theme = pw.ThemeData.withFont(
      base: regularFont ?? fallbackBase,
      bold: boldFont ?? regularFont ?? fallbackBold,
    );

    final document = pw.Document(theme: theme);

    document.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(20),
                      color: PdfColors.teal700,
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'عيادتي',
                              style: pw.TextStyle(
                                fontSize: 24,
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              'فاتورة خدمة طبية / Medical Invoice',
                              style: const pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.circular(14),
                          ),
                          child: pw.Text(
                            invoice.source.label,
                            style: pw.TextStyle(
                              color: PdfColors.teal700,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  pw.TableHelper.fromTextArray(
                    headerAlignment: pw.Alignment.centerRight,
                    cellAlignment: pw.Alignment.centerRight,
                    cellPadding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    headers: const ['البيان', 'القيمة'],
                    data: [
                      ['رقم الفاتورة', invoice.id],
                      ['اسم المريض', invoice.patientName],
                      ['القسم', invoice.source.label],
                      ['الخدمة', invoice.serviceLabel],
                      ['رقم الهوية', invoice.nationalId],
                      ['رقم الجوال', invoice.phoneNumber],
                      ['الطبيب المسؤول', doctorName],
                      [
                        'التاريخ',
                        ClinicFormatters.formatDateTime(invoice.createdAt),
                      ],
                      [
                        'المبلغ',
                        ClinicFormatters.formatCurrency(invoice.amount),
                      ],
                    ],
                  ),
                  pw.SizedBox(height: 24),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(18),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(18),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ملاحظات',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(invoice.notes),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 32),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(18),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(18),
                      border: pw.Border.all(color: PdfColors.teal200),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'الإجمالي النهائي',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        pw.Text(
                          ClinicFormatters.formatCurrency(invoice.amount),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 18,
                            color: PdfColors.teal700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return document.save();
  }

  static Future<pw.Font?> _loadFont(Future<pw.Font> Function() loader) async {
    try {
      return await loader();
    } catch (_) {
      return null;
    }
  }
}
