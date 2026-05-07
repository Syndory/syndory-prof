import 'package:flutter/foundation.dart';

import '../../../data/supabase/supabase_client.dart';
import '../domain/justification_model.dart';

class JustificationRepository {
  const JustificationRepository();

  /// Récupère tous les justificatifs visibles par le professeur connecté.
  Future<List<Justification>> fetchAll() async {
    try {
      final rows = await SupabaseClientProvider.client
          .from('justificatifs')
          .select('''
            id, student_id, status, file_url, reason, rejection_reason, created_at,
            users!student_id(first_name, last_name, email),
            presences(sessions(seances(date, start_time, end_time, matieres(name))))
          ''')
          .order('created_at', ascending: false);

      return (rows as List)
          .map((row) => Justification.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    } catch (e) {
      debugPrint('[JustificationRepository] Error fetching: $e');
      rethrow;
    }
  }

  /// Valide ou rejette un justificatif via l'Edge Function `review-justification`.
  Future<void> review({
    required String justificatifId,
    required String decision,
    String? rejectionReason,
  }) async {
    final body = <String, dynamic>{
      'justificatif_id': justificatifId,
      'decision': decision,
      if (rejectionReason != null && rejectionReason.isNotEmpty)
        'rejection_reason': rejectionReason,
    };

    final response = await SupabaseClientProvider.callEdgeFunction(
      'review-justification',
      body: body,
    );

    final status = response.status;
    if (status >= 400) {
      final data = response.data;
      final message = (data is Map<String, dynamic>
              ? data['error'] ?? data['message']
              : null)
          ?.toString() ??
          'Erreur lors du traitement du justificatif.';
      throw Exception(message);
    }
  }
}
