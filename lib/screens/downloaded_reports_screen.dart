import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pdf_manager_app/screens/pdf_viewer_screen.dart';
import 'package:pdf_manager_app/services/pdf_download_service.dart';
import '../models/pdf_file_model.dart';
import '../widgets/pdf_list_item.dart';
import 'package:file_picker/file_picker.dart';

class DownloadedReportsScreen extends StatefulWidget {
  @override
  State<DownloadedReportsScreen> createState() => _DownloadedReportsScreenState();
}

class _DownloadedReportsScreenState extends State<DownloadedReportsScreen> with TickerProviderStateMixin {
  List<PdfFile> pdfFiles = [];
  List<PdfFile> imageFiles = [];
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
      pdfFiles = files.where((f) => f.name.endsWith(".pdf")).toList();
      imageFiles = files.where((f) => f.name.endsWith(".png") || f.name.endsWith(".jpg") || f.name.endsWith(".jpeg")).toList();
      selectedFiles.clear();
    });
  }

  void _onFileTap(PdfFile file) {
    if (selectedFiles.isNotEmpty) {
      _onLongPress(file);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(path: file.file.path),
        ),
      );
    }
  }

  void _onDeleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Selected"),
        content: Text("Are you sure you want to delete ${selectedFiles.length} ${selectedFiles.length == 1 ? "file" : "files"}?"),
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
      await _loadFiles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${selectedFiles.length} ${selectedFiles.length == 1 ? "file" : "files"} deleted successfully."),
          duration: Duration(seconds: 2),
        ),
      );
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Downloaded Files"),
          bottom: TabBar(
            tabs: [
              Tab(text: "PDFs"),
              Tab(text: "Images"),
            ],
          ),
          actions: selectedFiles.isNotEmpty
              ? [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _onDeleteSelected,
            )
          ]
              : [],
        ),
        body: Column(
          children: [
            Expanded(child: TabBarView(
              children: [
                buildListView(pdfFiles),
                buildListView(imageFiles),
              ],
            )),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickAndUploadImage,
                    icon: Icon(Icons.image),
                    label: Text('Upload Image'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickAndUploadPdf,
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text('Upload PDF'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 70,),
          ],
        ),
          floatingActionButton: isLoading
            ? FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.grey,
          child: CircularProgressIndicator(color: Colors.white),
        )
            : FloatingActionButton(
          child: Icon(Icons.download),
          onPressed: () async {
            setState(() => isLoading = true);
            final url = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
            final filename = 'report_${DateTime.now().millisecondsSinceEpoch}.pdf';
            await FileService.downloadPdf(url, filename, context);
            await _loadFiles();
            setState(() => isLoading = false);
          },
        ),
      ),
    );
  }

  Widget buildListView(List<PdfFile> files) {
    if (files.isEmpty) {
      return Center(child: Text("No files found"));
    }
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (_, index) {
        final file = files[index];
        return PdfListItem(
          pdf: file,
          isSelected: isSelected(file),
          onTap: () => _onFileTap(file),
          onLongPress: () => _onLongPress(file),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final fileName = result.files.single.name;
      final ref = FirebaseStorage.instance.ref().child('images/$fileName');

      await ref.putFile(File(path));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image uploaded')));
    }
  }

  Future<void> _pickAndUploadPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final fileName = result.files.single.name;
      final ref = FirebaseStorage.instance.ref().child('pdfs/$fileName');

      await ref.putFile(File(path));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF uploaded')));
    }
  }




}


/// loading indicator of train
/*
VandeBharatLottieLoader(
width: 100,
height: 100,
);*/
