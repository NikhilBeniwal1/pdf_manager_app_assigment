# Flutter PDF Manager App 📘

This Flutter application demonstrates how to download, store, view, and delete PDF files locally. It is built as part of an internship assignment to showcase local media management capabilities using Flutter.

---

## ✅ Features

- 📥 Download PDF files from a remote URL
- 🗂️ Save downloaded PDFs in device local storage (`ApplicationDocumentsDirectory`)
- 📄 View list of all saved PDF files with:
    - Filename
    - File size
    - Download timestamp
- 👆 Tap to open PDFs using the native viewer
- 🗑️ Long-press to select and delete one or more files
- ✨ Clean and maintainable project structure

---

## 📂 Project Structure

lib/
├── main.dart # App entry point
├── models/
│ └── pdf_file_model.dart # Model class for PDF metadata
├── screens/
│ └── downloaded_reports_screen.dart # Main UI screen
├── services/
│ └── file_service.dart # Handles download, storage, and deletion
├── widgets/
│ └── pdf_list_item.dart # Reusable list tile for PDF files


---

## 🔧 Dependencies

```yaml
dio: ^5.4.0
path_provider: ^2.0.14
open_file: ^3.3.2
permission_handler: ^11.0.0

