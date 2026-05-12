import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order_model.dart';
import '../models/customer_model.dart';

class ReceiptService {
  static final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  static Future<void> printReceipt({
    required OrderModel order,
    required CustomerModel? customer,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text("BENGKEL APP", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                    pw.Text("Jl. Raya Bengkel No. 123", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text("Telp: 0812-3456-7890", style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 10),
                    pw.Text("STRUK PEMBAYARAN", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Nota: #${order.id}", style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(dateFormat.format(order.tanggal), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Text("Pelanggan: ${customer?.nama ?? 'Umum'}", style: const pw.TextStyle(fontSize: 10)),
              if (customer?.noPlat != null && customer!.noPlat.isNotEmpty) 
                pw.Text("No. Plat: ${customer.noPlat}", style: const pw.TextStyle(fontSize: 10)),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),

              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text("Item", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                  pw.Container(width: 30, child: pw.Text("Qty", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                  pw.Container(width: 70, child: pw.Text("Total", textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                ],
              ),
              pw.SizedBox(height: 5),

              ...items.map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      children: [
                        pw.Expanded(child: pw.Text(item['name'], style: const pw.TextStyle(fontSize: 10))),
                        pw.Container(width: 30, child: pw.Text("${item['qty']}", textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10))),
                        pw.Container(width: 70, child: pw.Text(currencyFormat.format(item['subtotal']), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10))),
                      ],
                    ),
                  )),

              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TOTAL", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(currencyFormat.format(order.total), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text("Terima Kasih Atas Kunjungan Anda", style: const pw.TextStyle(fontSize: 8)),
                    pw.Text("Semoga Kendaraan Anda Selalu Prima", style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Struk_${order.id}.pdf',
    );
  }

  static Future<void> printReport({
    required String title,
    required String dateLabel,
    required List<OrderModel> orders,
    required double totalIncome,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("LAPORAN TRANSAKSI - BENGKEL APP", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                      pw.Text("Periode: $dateLabel", style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['No', 'ID Transaksi', 'Tanggal', 'Pelanggan', 'Total'],
              data: List<List<dynamic>>.generate(
                orders.length,
                (index) => [
                  index + 1,
                  "#${orders[index].id}",
                  dateFormat.format(orders[index].tanggal),
                  orders[index].customerName ?? "-",
                  currencyFormat.format(orders[index].total),
                ],
              ),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("TOTAL PENDAPATAN", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(currencyFormat.format(totalIncome), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.orange)),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_${title}_$dateLabel.pdf',
    );
  }
}
