import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf_manager_app/services/pdf_download_service.dart';
import '../models/pdf_file_model.dart';
import '../widgets/pdf_list_item.dart';

class DownloadedReportsScreen extends StatefulWidget {
  @override
  State<DownloadedReportsScreen> createState() => _DownloadedReportsScreenState();
}

class _DownloadedReportsScreenState extends State<DownloadedReportsScreen> {
  List<PdfFile> pdfFiles = [];
  List<PdfFile> selectedFiles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final entities = await FileService.listDownloadedFiles();
    final files = await Future.wait(entities.map(PdfFile.fromFileSystemEntity));
    setState(() {
      pdfFiles = files;
      selectedFiles.clear();
    });
  }

  void _onFileTap(PdfFile file) {
    if (selectedFiles.isNotEmpty) {
      // Selection mode is active — toggle selection
      _onLongPress(file);
    } else {
      // Normal mode — open file
      OpenFile.open(file.file.path);
    }
  }

  void _onDeleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Selected"),
        content: Text("Are you sure you want to delete ${selectedFiles.length} file(s)?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FileService.deleteFiles(selectedFiles.map((e) => e.file).toList());
      _loadFiles();
    }
  }


  void _onLongPress(PdfFile file) {
    setState(() {
      if (selectedFiles.contains(file)) {
        selectedFiles.remove(file);
      } else {
        selectedFiles.add(file);
      }
    });
  }

  bool isSelected(PdfFile file) => selectedFiles.contains(file);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Downloaded Reports"),
        actions: selectedFiles.isNotEmpty
            ? [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _onDeleteSelected,
          )
        ]
            : [],
      ),
      body: pdfFiles.isEmpty
          ? Center(child: Text("No downloaded reports"))
          : ListView.builder(
        itemCount: pdfFiles.length,
        itemBuilder: (_, index) {
          final pdf = pdfFiles[index];
          return PdfListItem(
            pdf: pdf,
            isSelected: isSelected(pdf),
            onTap: () => _onFileTap(pdf),
            onLongPress: () => _onLongPress(pdf),
          );
        },
      ),
       floatingActionButton: isLoading
        ? FloatingActionButton(
        onPressed: () {},
    backgroundColor: Colors.grey,
    child: CircularProgressIndicator(
    color: Colors.white,
    ),
    )
        : FloatingActionButton(
    child: Icon(Icons.download),
    onPressed: () async {
    setState(() => isLoading = true);
    final url = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
    final filename = 'report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await FileService.downloadPdf(url, filename);
    await _loadFiles();
    setState(() => isLoading = false);
    },
    ),
    );
  }
}
