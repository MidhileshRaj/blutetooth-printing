import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfViewerScreenPage2 extends StatefulWidget {
  const PdfViewerScreenPage2({super.key});

  @override
  _PdfViewerScreenPage2State createState() => _PdfViewerScreenPage2State();
}

class _PdfViewerScreenPage2State extends State<PdfViewerScreenPage2> {
  String? filePath;

  @override
  void initState() {
    super.initState();
    _pickPdfFile();
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          filePath = result.files.single.path;
        });
      } else {
        // User canceled the picker
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No PDF selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick PDF file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        actions: [
          if (filePath != null)
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () {
                _printPdf(filePath!);
              },
            ),
        ],
      ),
      body: filePath == null
          ? const Center(child: Text('No PDF selected'))
          : PDFView(
        filePath: filePath!,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        onError: (error) {
          print('Error displaying PDF: $error');
        },
      ),
      floatingActionButton: filePath != null
          ? FloatingActionButton(
        onPressed: () {
          _printPdf(filePath!);
        },
        child: const Icon(Icons.print),
      )
          : null,
    );
  }

  void _printPdf(String filePath) async {
    try {
      final file = File(filePath);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final pdfBytes = await file.readAsBytes();
          return pdfBytes;
        },
      );
    } catch (e) {
      print("Error printing PDF: $e");
    }
  }
}
