// lib/features/justifications/justification_repository.dart

import 'package:syndory_prof/data/supabase/supabase_client.dart';
import 'justification_model.dart';

class JustificationRepository {
  const JustificationRepository();

  /// Récupère tous les justificatifs visibles par le professeur connecté.
  ///
  /// La RLS garantit que seuls les justificatifs liés aux séances du prof
  /// sont retournés. On joint :
  ///   - users (étudiant)
  ///   - presences -> sessions -> seances -> matieres
  Future<List<JustificationModel>> fetchAll() async {
    final rows = await SupabaseClientProvider.client
        .from('justificatifs')
        .select(
          'id, student_id, presence_id, status, file_url, reason, '
          'rejection_reason, created_at, reviewed_at, '
          'users!student_id(first_name, last_name, email), '
          'presences(sessions(seances(date, start_time, end_time, '
          'matieres(name))))',
        )
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) =>
            JustificationModel.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  /// Valide ou rejette un justificatif via l'Edge Function `review-justification`.
  ///
  /// [decision] : `'valide'` ou `'rejete'`
  /// [rejectionReason] : obligatoire si decision == 'rejete'
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

    final session = SupabaseClientProvider.client.auth.currentSession;

final response = await SupabaseClientProvider.client.functions.invoke(
  'review-justification',
  body: body,
  headers: {
    'Authorization': 'Bearer ${session?.accessToken}',
  },
);

    if (response.status != null && response.status! >= 400) {
      final data = response.data;
      final message = (data is Map ? data['error'] ?? data['message'] : null)
              ?.toString() ??
          'Erreur lors du traitement du justificatif.';
      throw Exception(message);
    }
  }
}