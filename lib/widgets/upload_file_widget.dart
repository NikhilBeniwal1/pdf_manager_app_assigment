import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UploadFilesWidget extends StatefulWidget {
  const UploadFilesWidget({Key? key}) : super(key: key);

  @override
  State<UploadFilesWidget> createState() => _UploadFilesWidgetState();
}

class _UploadFilesWidgetState extends State<UploadFilesWidget> {
  List<PlatformFile> queuedFiles = [];
  bool isUploading = false;
  late StreamSubscription connectivitySub;
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    _listenToConnection();
  }

  @override
  void dispose() {
    connectivitySub.cancel();
    super.dispose();
  }

  void _listenToConnection() {
    connectivitySub = Connectivity().onConnectivityChanged.listen((status) {
      final nowConnected = status != ConnectivityResult.none;
      if (nowConnected && !isConnected && queuedFiles.isNotEmpty) {
        _uploadQueuedFiles();
      }
      isConnected = nowConnected;
    });
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      final newFiles = result.files;
      if (isConnected) {
        await _uploadFiles(newFiles);
      } else {
        setState(() {
          queuedFiles.addAll(newFiles);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${newFiles.length} file(s) queued for upload.')),
        );
      }
    }
  }

  Future<void> _uploadFiles(List<PlatformFile> files) async {
    setState(() => isUploading = true);
    for (final file in files) {
      try {
        final path = file.path!;
        final name = file.name;
        final isImage = name.endsWith('.jpg') || name.endsWith('.png') || name.endsWith('.jpeg');
        final storagePath = isImage ? 'images/$name' : 'pdfs/$name';

        final ref = FirebaseStorage.instance.ref().child(storagePath);
        await ref.putFile(File(path));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name uploaded.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${file.name}')));
      }
    }
    setState(() => isUploading = false);
  }

  Future<void> _uploadQueuedFiles() async {
    if (queuedFiles.isEmpty) return;
    final filesToUpload = List<PlatformFile>.from(queuedFiles);
    queuedFiles.clear();
    await _uploadFiles(filesToUpload);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickFiles,
          icon: Icon(Icons.upload),
          label: Text('Upload Files'),
        ),
        if (isUploading)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: LinearProgressIndicator(),
          ),
        if (!isConnected)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Offline: Queued ${queuedFiles.length} file(s)',
              style: TextStyle(color: Colors.orange),
            ),
          ),
      ],
    );
  }
}
