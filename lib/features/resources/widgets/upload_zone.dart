import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syndory_prof/app/theme/app_theme.dart';

class UploadZone extends StatefulWidget {
  final Function(String) onFileSelected;
  const UploadZone({super.key, required this.onFileSelected});

  @override
  State<UploadZone> createState() => _UploadZoneState();
}

class _UploadZoneState extends State<UploadZone> {
  String? _fileName;
  String? _errorMessage;
  final List<String> _allowedExtensions = ['pdf', 'docx', 'pptx', 'jpg', 'png'];
  final int _maxFileSize = 20 * 1024 * 1024; // 20 Mo en octets

  Future<void> choisirUnFichier() async {
    // Réinitialiser l'erreur à chaque tentative
    setState(() => _errorMessage = null);

    FilePickerResult? resultat = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );

    if (resultat != null) {
      PlatformFile file = resultat.files.first;

      // Vérification de l'extension
      if (!_allowedExtensions.contains(file.extension?.toLowerCase())) {
        setState(() {
          _errorMessage =
              "Ce format n'est pas accepté. Formats autorisés : PDF, DOCX, PPTX, JPG, PNG.";
          _fileName = null;
        });
        return;
      }

      // Vérification de la taille (Max 20 Mo)
      if (file.size > _maxFileSize) {
        setState(() {
          _errorMessage = "Le fichier est trop lourd. Taille maximale : 20 Mo.";
          _fileName = null;
        });
        return;
      }

      setState(() {
        _fileName = file.name;
        _errorMessage = null;
      });
      widget.onFileSelected(file.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasError = _errorMessage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: choisirUnFichier,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: hasError
                  ? Colors.red.withOpacity(0.02)
                  : (_fileName != null
                        ? Colors.blue.withOpacity(0.05)
                        : Colors.grey[50]),
              borderRadius: BorderRadius.circular(12),
              // Bordure rouge pointillée en cas d'erreur
              border: Border.all(
                color: hasError
                    ? Colors.red
                    : (_fileName != null
                          ? AppTheme.primaryBlue
                          : Colors.grey.shade300),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasError
                      ? Icons.error_outline
                      : (_fileName != null
                            ? Icons.insert_drive_file
                            : Icons.cloud_upload_outlined),
                  size: 42,
                  color: hasError ? Colors.red : AppTheme.primaryBlue,
                ),
                const SizedBox(height: 12),
                Text(
                  _fileName ?? "Choisir un fichier",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: hasError ? Colors.red : AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _fileName != null
                      ? "Cliquez pour modifier"
                      : "PDF, DOCX, PPTX, JPG, PNG (Max 20 Mo)",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (_fileName != null)
                  TextButton(
                    onPressed: () => setState(() => _fileName = null),
                    child: const Text(
                      "Supprimer",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
        //  Affichage du message d'erreur sous la zone
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
