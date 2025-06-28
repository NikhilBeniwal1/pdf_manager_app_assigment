import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf_manager_app/services/pdf_download_service.dart';
import '../models/pdf_file_model.dart';
import '../widgets/pdf_list_item.dart';

// Screen to display and manage downloaded PDF reports
class DownloadedReportsScreen extends StatefulWidget {
  @override
  State<DownloadedReportsScreen> createState() => _DownloadedReportsScreenState();
}

class _DownloadedReportsScreenState extends State<DownloadedReportsScreen> {
  // List to hold all downloaded PDF files
  List<PdfFile> pdfFiles = [];

  // List to keep track of selected files for deletion
  List<PdfFile> selectedFiles = [];

  // Flag to show download loading state
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFiles(); // Load files when screen is initialized
  }

  // Load all downloaded PDF files from storage
  Future<void> _loadFiles() async {
    final entities = await FileService.listDownloadedFiles();
    final files = await Future.wait(entities.map(PdfFile.fromFileSystemEntity));
    setState(() {
      pdfFiles = files;
      selectedFiles.clear(); // Clear selection when refreshing list
    });
  }

  // Handle tap on a PDF file item
  void _onFileTap(PdfFile file) {
    if (selectedFiles.isNotEmpty) {
      // If selection mode is active, treat tap as toggle selection
      _onLongPress(file);
    } else {
      // Otherwise, open the file using system viewer
      OpenFile.open(file.file.path);
    }
  }

  // Show confirmation dialog and delete selected files
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
      // Delete the selected files
      await FileService.deleteFiles(selectedFiles.map((e) => e.file).toList());
      _loadFiles(); // Refresh file list after deletion
    }
  }

  // Handle long press to select or deselect a file
  void _onLongPress(PdfFile file) {
    setState(() {
      if (selectedFiles.contains(file)) {
        selectedFiles.remove(file); // Deselect if already selected
      } else {
        selectedFiles.add(file); // Add to selection
      }
    });
  }

  // Check if a given file is currently selected
  bool isSelected(PdfFile file) => selectedFiles.contains(file);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Downloaded Reports"),
        actions: selectedFiles.isNotEmpty
            ? [
          // Show delete icon only when files are selected
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _onDeleteSelected,
          )
        ]
            : [],
      ),
      body: pdfFiles.isEmpty
          ? Center(child: Text("No downloaded reports")) // Show message if no files
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
        onPressed: () {}, // Disabled button during download
        backgroundColor: Colors.grey,
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      )
          : FloatingActionButton(
        child: Icon(Icons.download),
        onPressed: () async {
          setState(() => isLoading = true); // Start loading state
          final url = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
          final filename = 'report_${DateTime.now().millisecondsSinceEpoch}.pdf';

          // Download and save PDF
          await FileService.downloadPdf(url, filename);
          await _loadFiles(); // Refresh list with new file
          setState(() => isLoading = false); // End loading state
        },
      ),
    );
  }
}
