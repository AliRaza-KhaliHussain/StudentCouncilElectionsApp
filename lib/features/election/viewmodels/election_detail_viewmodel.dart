import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/election_result_model.dart';

class ElectionDetailViewModel extends ChangeNotifier {
  final ElectionResultModel election;
  final Map<String, Color> candidateColors;
  final bool isBlockchainValid;

  ElectionDetailViewModel({
    required this.election,
    required this.candidateColors,
    required this.isBlockchainValid,
  });

  Future<void> exportAsPDF() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (_) => _buildPdfContent()));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> downloadAsPDF() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (_) => _buildPdfContent()));
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${election.electionTitle}_results.pdf',
    );
  }

  void shareAsText() {
    final buffer = StringBuffer();
    buffer.writeln('📊 Election: ${election.electionTitle}');
    buffer.writeln('📅 From: ${election.startDate} — To: ${election.endDate}');
    if (!isBlockchainValid) {
      buffer.writeln('⚠ Blockchain validation failed. Results may be tampered!');
    }
    for (var entry in election.positionVotes.entries) {
      final position = entry.key;
      final votes = entry.value;
      final total = votes.values.fold(0, (a, b) => a + b);
      buffer.writeln('\n🏛️ Position: $position');
      for (var e in votes.entries) {
        final percent = total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0.0';
        buffer.writeln('• ${e.key}: ${e.value} votes ($percent%)');
      }
      buffer.writeln('Total Votes: $total');
    }
    Share.share(buffer.toString(), subject: 'Election Results: ${election.electionTitle}');
  }

  pw.Widget _buildPdfContent() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('📊 Election: ${election.electionTitle}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text('📅 From: ${election.startDate} — To: ${election.endDate}'),
        if (!isBlockchainValid)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            child: pw.Text('⚠ Blockchain validation failed. Results may be tampered!',
                style: pw.TextStyle(color: PdfColors.red, fontWeight: pw.FontWeight.bold)),
          ),
        pw.SizedBox(height: 10),
        ...election.positionVotes.entries.map((entry) {
          final pos = entry.key;
          final votes = entry.value;
          final total = votes.values.fold(0, (a, b) => a + b);
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('🏛️ Position: $pos',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ...votes.entries.map((c) {
                final percent = total > 0 ? (c.value / total * 100).toStringAsFixed(1) : '0.0';
                return pw.Text('• ${c.key}: ${c.value} votes ($percent%)');
              }),
              pw.Text('Total Votes: $total'),
              pw.SizedBox(height: 10),
            ],
          );
        }),
        pw.Divider(),
      ],
    );
  }
}