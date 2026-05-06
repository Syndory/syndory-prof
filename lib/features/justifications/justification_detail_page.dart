// lib/features/justifications/justification_detail_page.dart

import 'package:flutter/material.dart';
import 'justification_model.dart';
import 'justification_repository.dart';

class JustificationDetailPage extends StatefulWidget {
  final JustificationModel justification;

  const JustificationDetailPage({
    super.key,
    required this.justification,
  });

  @override
  State<JustificationDetailPage> createState() =>
      _JustificationDetailPageState();
}

class _JustificationDetailPageState extends State<JustificationDetailPage> {
  // ── État ──────────────────────────────────────────────────────────────────

  final _repo = const JustificationRepository();
  final _commentController = TextEditingController();

  bool _submitting = false;
  bool _imageError = false;

  JustificationModel get j => widget.justification;

  // ── Cycle de vie ─────────────────────────────────────────────────────────

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _review({required String decision}) async {
    // Pour un rejet, le commentaire est fortement recommandé (pas bloquant côté UI)
    final comment = _commentController.text.trim();

    setState(() => _submitting = true);
    try {
      await _repo.review(
        justificatifId: j.id,
        decision: decision,
        rejectionReason: decision == 'rejeté' ? comment : null,
      );
      if (!mounted) return;
      _showResult(decision == 'validé');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: const Color(0xFFEB5757),
        ),
      );
    }
  }

  void _showResult(bool isValidated) {
  if (!mounted) return;

  setState(() => _submitting = false);

  final msg = isValidated ? 'Justificatif validé.' : 'Justificatif refusé.';

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor:
          isValidated ? const Color(0xFF27AE60) : const Color(0xFFEB5757),
    ),
  );

  Navigator.pop(context, true);
}

  void _confirmReview({required String decision}) {
    final isValidation = decision == 'validé';
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isValidation ? 'Valider le justificatif ?' : 'Refuser le justificatif ?',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF092C4C),
          ),
        ),
        content: Text(
          isValidation
              ? 'Cette action notifiera l\'étudiant de la validation de son absence.'
              : 'Cette action notifiera l\'étudiant du refus. Pensez à ajouter un commentaire.',
          style: const TextStyle(color: Color(0xFF4F4F4F), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Color(0xFF828282)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _review(decision: decision);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isValidation
                  ? const Color(0xFF27AE60)
                  : const Color(0xFFEB5757),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
            ),
            child: Text(isValidation ? 'Valider' : 'Refuser'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 18, color: Color(0xFF092C4C)),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          'Détail justificatif',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF092C4C),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentCard(),
              const SizedBox(height: 16),
              _buildInfoGrid(),
              const SizedBox(height: 16),
              _buildAttachmentSection(),
              const SizedBox(height: 16),
              if (j.statut == JustificationStatut.enAttente) ...[
                _buildCommentField(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ] else
                _buildStatusBanner(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Student card ──────────────────────────────────────────────────────────

  Widget _buildStudentCard() {
    Color avatarBg(String name) {
      const colors = [
        Color(0xFF3B82F6),
        Color(0xFF8B5CF6),
        Color(0xFF10B981),
        Color(0xFFF59E0B),
        Color(0xFF092C4C),
      ];
      return colors[name.hashCode.abs() % colors.length];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: avatarBg(j.studentFullName),
            child: Text(
              j.studentInitials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  j.studentFullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF092C4C),
                  ),
                ),
                if (j.studentEmail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    j.studentEmail!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF828282),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info grid ─────────────────────────────────────────────────────────────

  Widget _buildInfoGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow('Matière', j.matiereNom ?? '–'),
          const _Divider(),
          _infoRow('Date absence', j.dateAbsenceDisplay),
          const _Divider(),
          _infoRow('Créneaux', j.creneauxDisplay),
          if (j.reason != null && j.reason!.isNotEmpty) ...[
            const _Divider(),
            _infoRow('Motif étudiant', j.reason!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF828282),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF092C4C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Attachment ────────────────────────────────────────────────────────────

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (j.fileUrl != null) ...[
          Row(
            children: [
              const Icon(Icons.attach_file, size: 15, color: Color(0xFF828282)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  j.fileUrl!.split('/').last,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF828282),
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            height: 200,
            color: const Color(0xFFE8EFF5),
            child: _buildImageContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (j.fileUrl == null || _imageError) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 36, color: Color(0xFFEB5757)),
            SizedBox(height: 8),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF092C4C),
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Impossible de récupérer la liste des justificatifs.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF828282), fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Image.network(
      j.fileUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF092C4C),
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _imageError = true);
        });
        return const SizedBox.shrink();
      },
    );
  }

  // ── Commentaire ───────────────────────────────────────────────────────────

  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Commentaire (optionnel)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF092C4C),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          maxLines: 3,
          enabled: !_submitting,
          style: const TextStyle(fontSize: 14, color: Color(0xFF092C4C)),
          decoration: InputDecoration(
            hintText: 'Ajouter une précision sur votre décision...',
            hintStyle:
                const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF092C4C), width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  // ── Boutons d'action ──────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _submitting
                ? null
                : () => _confirmReview(decision: 'rejeté'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
            ),
            child: _submitting
                ? const _SmallLoader(color: Color(0xFF092C4C))
                : const Text(
                    'Rejeter',
                    style: TextStyle(
                      color: Color(0xFF4F4F4F),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitting
                ? null
                : () => _confirmReview(decision: 'validé'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF092C4C),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF092C4C),
              disabledForegroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
            ),
            child: _submitting
                ? const _SmallLoader(color: Colors.white)
                : const Text(
                    'Valider',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Bannière résultat ─────────────────────────────────────────────────────

  Widget _buildStatusBanner() {
    final isValide = j.statut == JustificationStatut.valide;
    final color =
        isValide ? const Color(0xFF27AE60) : const Color(0xFFEB5757);
    final bg = isValide ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2);
    final icon = isValide ? Icons.check_circle_outline : Icons.cancel_outlined;
    final titre = isValide ? 'Justificatif Validé' : 'Justificatif Refusé';

    String? motif;
    if (isValide && j.reviewedAt != null) {
      final dt = j.reviewedAt!;
      motif =
          'La décision a été transmise à l\'étudiant le ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} à ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}.';
    } else if (!isValide && j.rejectionReason != null) {
      motif = 'Motif : ${j.rejectionReason}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: color,
                  ),
                ),
                if (motif != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    motif,
                    style: TextStyle(
                      fontSize: 13,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF092C4C),
      unselectedItemColor: const Color(0xFFBDBDBD),
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
      onTap: (index) {
        if (index != 2) return; // seul "Mes cours" retourne à la liste
        Navigator.pop(context, false);
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Accueil'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined), label: 'Calendrier'),
        BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined), label: 'Mes cours'),
        BottomNavigationBarItem(
            icon: Icon(Icons.folder_open_outlined), label: 'Ressources'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }
}

// ─── Micro-widgets réutilisables ──────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: Color(0xFFF0F0F0));
}

class _SmallLoader extends StatelessWidget {
  final Color color;
  const _SmallLoader({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color,
      ),
    );
  }
}