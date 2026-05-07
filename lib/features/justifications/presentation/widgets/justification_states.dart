import 'package:flutter/material.dart';

class JustificationEmptyState extends StatelessWidget {
  final String message;
  const JustificationEmptyState({
    super.key, 
    this.message = 'Aucun justificatif à afficher pour le moment.'
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFF5).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in_outlined,
                size: 64,
                color: Color(0xFF092C4C),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tout est en ordre !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF092C4C),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF828282),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JustificationErrorState extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const JustificationErrorState({
    super.key,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFEB5757),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oups ! Une erreur est survenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF092C4C),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'Impossible de charger les justificatifs. Vérifiez votre connexion.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF828282),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF092C4C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
