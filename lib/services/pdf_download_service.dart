import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

// A utility class for handling local file operations like downloading, listing, and deleting PDFs
class FileService {

  // Returns the path to the app's document directory
  static Future<String> getLocalPath() async {
    final dir = await getApplicationDocumentsDirectory(); // Platform-specific safe storage
    return dir.path;
  }

  // Downloads a PDF from the given URL and saves it with the specified file name
  static Future<File> downloadPdf(String url, String fileName,context) async {
    final path = await getLocalPath();
    final file = File('$path/$fileName');

    // If file already exists, return it directly
    if (await file.exists()) return file;


    // Download the file and save it
    await Dio().download(url, file.path);
    return file;
  }

  // Lists all downloaded PDF files from the local directory
  static Future<List<FileSystemEntity>> listDownloadedFiles() async {
    final dir = Directory(await getLocalPath());

    // Filter and return only .pdf files
    return dir.listSync().where((f) => f.path.endsWith('.pdf')).toList();
  }

  // Deletes the given list of files from the storage
  static Future<void> deleteFiles(List<FileSystemEntity> files) async {
    for (var file in files) {
      if (await File(file.path).exists()) {
        await File(file.path).delete(); // Remove file if it exists
      }
    }
  }
}
