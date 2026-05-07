import 'package:flutter/material.dart';
import '../../domain/justification_model.dart';
import '../../data/justification_repository.dart';

class JustificationDetailPage extends StatefulWidget {
  final Justification justification;

  const JustificationDetailPage({
    super.key,
    required this.justification,
  });

  @override
  State<JustificationDetailPage> createState() => _JustificationDetailPageState();
}

class _JustificationDetailPageState extends State<JustificationDetailPage> {
  final _commentController = TextEditingController();
  final _repository = const JustificationRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleReview(String decision) async {
    setState(() => _isLoading = true);
    
    try {
      await _repository.review(
        justificatifId: widget.justification.id,
        decision: decision,
        rejectionReason: decision == 'rejeté' ? _commentController.text : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Justificatif ${decision == 'validé' ? 'validé' : 'refusé'} avec succès.'),
            backgroundColor: decision == 'validé' ? Colors.green : Colors.red,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.justification;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF092C4C), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détails de l\'absence',
          style: TextStyle(color: Color(0xFF092C4C), fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentInfo(j),
            const SizedBox(height: 32),
            _buildDetailItem('Matière', j.subjectName, Icons.book_outlined),
            _buildDetailItem('Date de l\'absence', '${j.date.day}/${j.date.month}/${j.date.year}', Icons.calendar_today_outlined),
            if (j.reason != null && j.reason!.isNotEmpty)
              _buildDetailItem('Motif fourni', j.reason!, Icons.notes_rounded),
            const SizedBox(height: 32),
            const Text(
              'Justificatif',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF092C4C)),
            ),
            const SizedBox(height: 12),
            _buildDocumentPreview(j),
            const SizedBox(height: 40),
            if (j.status == JustificationStatus.pending) _buildActionForm()
            else _buildStatusInfo(j),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfo(Justification j) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFF092C4C),
          child: Text(
            j.initials,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              j.studentName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF092C4C)),
            ),
            if (j.studentEmail != null)
              Text(
                j.studentEmail!,
                style: const TextStyle(color: Color(0xFF828282), fontSize: 14),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF092C4C), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF828282), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF4F4F4F))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(Justification j) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
        image: j.imageUrl != null && j.imageUrl!.startsWith('http')
            ? DecorationImage(image: NetworkImage(j.imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: j.imageUrl == null || !j.imageUrl!.startsWith('http')
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_drive_file_outlined, size: 48, color: Color(0xFFBDBDBD)),
                  SizedBox(height: 8),
                  Text('Document non disponible', style: TextStyle(color: Color(0xFF828282))),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildActionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            labelText: 'Commentaire / Motif du refus',
            hintText: 'Optionnel si validé, conseillé si refusé',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => _handleReview('rejeté'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Refuser', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _handleReview('validé'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Valider', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusInfo(Justification j) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: j.status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(j.status.icon, color: j.status.color),
          const SizedBox(width: 12),
          Text(
            'Ce justificatif a été ${j.status.label.toLowerCase()}.',
            style: TextStyle(color: j.status.color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
