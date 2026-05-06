import '../../../data/supabase/supabase_client.dart';
import '../domain/justification_model.dart';

class JustificationRepository {
  const JustificationRepository();

  /// Récupère tous les justificatifs visibles par le professeur connecté.
  Future<List<Justification>> fetchAll() async {
    try {
      final rows = await SupabaseClientProvider.client
          .from('justificatifs')
          .select('id, student_id, statut, file_url, reason, rejection_reason, created_at')
          .order('created_at', ascending: false);

      return (rows as List)
          .map((row) => Justification.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    } catch (e) {
      print('ERREUR SUPABASE : $e');
      rethrow;
    }
  }

  /// Valide ou rejette un justificatif DIRECTEMENT en base de données.
  Future<void> review({
    required String justificatifId,
    required String decision,
    String? rejectionReason,
  }) async {
    await SupabaseClientProvider.client
        .from('justificatifs')
        .update({
          'statut': decision,
          'rejection_reason': rejectionReason,
          'reviewed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', justificatifId);
  }
}
