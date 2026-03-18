import '../../domain/trip.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../presentation/utils/expense_category_utils.dart';

Future<void> exportPDF(Trip trip) async {
  final pdf = pw.Document();
  final totals = getCategoryTotals(trip);
  final grandTotal = totals.isEmpty
      ? 0.0
      : totals.values.reduce((a, b) => a + b);
  final remaining = trip.budget - grandTotal;

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
          'Trip Summary: ${trip.name}',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Destination: ${trip.destination}',
          style: const pw.TextStyle(fontSize: 14),
        ),
        pw.Text(
          'Dates: ${DateFormat('MMM d, y').format(trip.startDate)} - '
          '${trip.endDate == null ? 'Ongoing' : DateFormat('MMM d, y').format(trip.endDate!)}',
          style: const pw.TextStyle(fontSize: 14),
        ),
        pw.SizedBox(height: 16),
        pw.Text(
          'Budget: ${trip.budget.toStringAsFixed(2)} ${trip.currency}',
          style: const pw.TextStyle(fontSize: 16),
        ),
        pw.Text(
          'Total Spent: ${grandTotal.toStringAsFixed(2)} ${trip.currency}',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Remaining: ${remaining.toStringAsFixed(2)} ${trip.currency}',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: remaining < 0 ? PdfColors.red : PdfColors.green,
          ),
        ),
        pw.SizedBox(height: 24),
        pw.Text(
          'Breakdown by Category',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        ...totals.entries.map((entry) {
          final percentage = grandTotal > 0
              ? (entry.value / grandTotal) * 100
              : 0.0;
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 12,
                  height: 12,
                  color: categoryPdfColor(entry.key),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    categoryLabel(entry.key),
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ),
                pw.Text(
                  '${entry.value.toStringAsFixed(2)} ${trip.currency}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(width: 12),
                pw.Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                ),
              ],
            ),
          );
        }),
        pw.SizedBox(height: 24),
        pw.Text(
          'All Expenses',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                'Title',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                'Amount',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                'Category',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                'Date',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        pw.Divider(),
        ...trip.expenses.map(
          (e) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    e.title,
                    style: const pw.TextStyle(fontSize: 13),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    '${e.currency} ${e.amount.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 13),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    categoryLabel(e.category),
                    style: const pw.TextStyle(fontSize: 13),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    DateFormat('MMM d, y').format(e.date),
                    style: const pw.TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: '${trip.name}_summary.pdf',
  );
}
