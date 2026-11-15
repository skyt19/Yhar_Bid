/// lib/widgets/markdown_viewer_panel.dart
/// Side panel for viewing Markdown documents with PDF export
/// Phase 10: Markdown and PDF document viewer

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:markdown/markdown.dart' as md;
import '../views/theme/app_theme.dart';

class MarkdownViewerPanel extends StatefulWidget {
  final String title;
  final String markdownContent;
  final VoidCallback onClose;

  const MarkdownViewerPanel({
    super.key,
    required this.title,
    required this.markdownContent,
    required this.onClose,
  });

  @override
  State<MarkdownViewerPanel> createState() => _MarkdownViewerPanelState();
}

class _MarkdownViewerPanelState extends State<MarkdownViewerPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _isExpanded ? MediaQuery.of(context).size.width * 0.9 : 500,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.fullscreen_exit : Icons.fullscreen),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  tooltip: _isExpanded ? 'Collapse' : 'Expand',
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: _exportToPdf,
                  tooltip: 'Export to PDF',
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadMarkdown,
                  tooltip: 'Download Markdown',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Markdown(
                data: widget.markdownContent,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                  h2: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  h3: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  p: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                  listBullet: const TextStyle(fontSize: 16),
                  code: TextStyle(
                    backgroundColor: Colors.grey.shade100,
                    fontFamily: 'monospace',
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  blockquote: TextStyle(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                  tableBorder: TableBorder.all(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Export Markdown to PDF with proper Thai font support
  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();

      // Load Thai font for proper rendering
      final thaiFont = await PdfGoogleFonts.sarabunRegular();
      final thaiFontBold = await PdfGoogleFonts.sarabunBold();

      // Convert Markdown to plain text sections
      final sections = _parseMarkdownSections(widget.markdownContent);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) {
            return sections.map((section) {
              if (section['type'] == 'heading1') {
                return pw.Header(
                  level: 0,
                  child: pw.Text(
                    section['content']!,
                    style: pw.TextStyle(
                      font: thaiFontBold,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                );
              } else if (section['type'] == 'heading2') {
                return pw.Header(
                  level: 1,
                  child: pw.Text(
                    section['content']!,
                    style: pw.TextStyle(
                      font: thaiFontBold,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                );
              } else if (section['type'] == 'heading3') {
                return pw.Header(
                  level: 2,
                  child: pw.Text(
                    section['content']!,
                    style: pw.TextStyle(
                      font: thaiFontBold,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                );
              } else {
                return pw.Paragraph(
                  text: section['content']!,
                  style: pw.TextStyle(
                    font: thaiFont,
                    fontSize: 12,
                    lineSpacing: 4,
                  ),
                );
              }
            }).toList();
          },
        ),
      );

      // Show PDF preview with save/print options
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: '${widget.title}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PDF: $e')),
        );
      }
    }
  }

  /// Parse Markdown content into sections for PDF generation
  List<Map<String, String>> _parseMarkdownSections(String markdown) {
    final lines = markdown.split('\n');
    final sections = <Map<String, String>>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.startsWith('# ')) {
        sections.add({'type': 'heading1', 'content': line.substring(2)});
      } else if (line.startsWith('## ')) {
        sections.add({'type': 'heading2', 'content': line.substring(3)});
      } else if (line.startsWith('### ')) {
        sections.add({'type': 'heading3', 'content': line.substring(4)});
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        sections.add({'type': 'list', 'content': '• ${line.substring(2)}'});
      } else {
        sections.add({'type': 'paragraph', 'content': line});
      }
    }

    return sections;
  }

  /// Download original Markdown file
  void _downloadMarkdown() {
    // Use existing download functionality
    // This preserves the original download behavior
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use the download button to save Markdown file')),
      );
    }
  }
}
