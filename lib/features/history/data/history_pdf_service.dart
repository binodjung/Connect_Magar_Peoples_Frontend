import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'history_model.dart';

class HistoryPdfService {
  static Future<void> generateAndDownloadPdf(HistoryModel history) async {
    final pdf = pw.Document();

    // Fetch images and descriptions for all sections
    List<pw.Widget> pages = [];

    // Title Page or Title Header
    pages.add(
      pw.Header(
        level: 0,
        child: pw.Text(
          history.title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.red900,
          ),
        ),
      ),
    );

    if (history.sections != null) {
      for (var section in history.sections!) {
        // Download image if available
        pw.MemoryImage? pdfImage;
        if (section.image != null) {
          try {
            final response = await http.get(Uri.parse(section.image!));
            if (response.statusCode == 200) {
              pdfImage = pw.MemoryImage(response.bodyBytes);
            }
          } catch (e) {
            print('Error fetching image for PDF: $e');
          }
        }

        // Add to page content
        pages.add(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (pdfImage != null)
                pw.Center(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.symmetric(vertical: 20),
                    child: pw.Image(pdfImage, height: 400),
                  ),
                ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Text(
                  section.description,
                  style: const pw.TextStyle(fontSize: 14),
                  textAlign: pw.TextAlign.justify,
                ),
              ),
              pw.Divider(color: PdfColors.grey300),
            ],
          ),
        );
      }
    }

    // Add multi-page layout
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pages,
      ),
    );

    // Show print/share preview or download
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${history.title.replaceAll(' ', '_')}.pdf',
    );
  }
}
