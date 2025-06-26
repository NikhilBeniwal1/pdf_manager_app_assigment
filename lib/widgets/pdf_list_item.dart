import 'package:flutter/material.dart';
import '../models/pdf_file_model.dart';

class PdfListItem extends StatelessWidget {
  final PdfFile pdf;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PdfListItem({
    Key? key,
    required this.pdf,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: isSelected ? Colors.grey[300] : null,
      title: Text(pdf.name),
      subtitle: Text('${pdf.sizeInKB} • ${pdf.formattedDate}'),
      trailing: isSelected ? Icon(Icons.check_circle, color: Colors.green) : null,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
