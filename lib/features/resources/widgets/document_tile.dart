import 'package:flutter/material.dart';
import 'package:syndory_prof/app/theme/app_theme.dart';
import '../models/document_model.dart';

class DocumentTile extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onDelete;

  const DocumentTile({
    super.key,
    required this.document,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.insert_drive_file_outlined, color: AppTheme.primaryBlue, size: 24),
        ),
        title: Text(
          document.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${document.date}  •  ${document.fileSize}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFFC7C7CC), size: 22),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
