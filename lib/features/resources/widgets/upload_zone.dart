import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syndory_prof/app/theme/app_theme.dart';

class UploadZone extends StatefulWidget {
  const UploadZone({super.key});

  @override
  State<UploadZone> createState() => _UploadZoneState();
}

class _UploadZoneState extends State<UploadZone> {

  String? _fileName;

  Future<void> choisirUnFichier() async {
    FilePickerResult? resultat = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'jpg', 'png'],
    );

    if (resultat != null) {
      // Si on a un fichier, on met à jour l'écran avec setState
      setState(() {
        _fileName = resultat.files.first.name;
      });
      print("Fichier sélectionné : $_fileName");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: choisirUnFichier,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
         
          color: _fileName != null
              ? Colors.blue.withOpacity(0.05)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
           
            color: _fileName != null
                ? AppTheme.primaryBlue
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // L'icône change si on a un fichier
            Icon(
              _fileName != null
                  ? Icons.insert_drive_file
                  : Icons.cloud_upload_outlined,
              size: 42,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 12),
           
            Text(
              _fileName ??
                  "Choisir un fichier", 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _fileName != null
                  ? "Cliquez pour modifier le fichier"
                  : "PDF, DOCX, JPG (Max 20 Mo)",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            // Petit bouton pour annuler si un fichier est choisi
            if (_fileName != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _fileName = null;
                  });
                },
                child: const Text(
                  "Supprimer",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
