import 'dart:io';
// pdf model
class PdfFile {
  final FileSystemEntity file;
  final String name;
  final int size;
  final DateTime lastModified;

  PdfFile({
    required this.file,
    required this.name,
    required this.size,
    required this.lastModified,
  });

  static Future<PdfFile> fromFileSystemEntity(FileSystemEntity entity) async {
    final file = File(entity.path);
    final stat = await file.stat();

    return PdfFile(
      file: entity,
      name: entity.path.split('/').last,
      size: stat.size,
      lastModified: stat.modified,
    );
  }

  String get sizeInKB => '${(size / 1024).toStringAsFixed(2)} KB';
  String get formattedDate =>
      '${lastModified.day}-${lastModified.month}-${lastModified.year}';
}
