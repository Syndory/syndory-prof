import '../data/supabase/supabase_client.dart';
import 'models/seance_du_jour.dart';

class AccueilRepository {
  Future<AccueilData> fetchAccueilData() async {
    final client = SupabaseClientProvider.client;
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Non authentifié');

    final today = DateTime.now().toIso8601String().split('T')[0];

    final results = await Future.wait([
      client.from('users').select('first_name').eq('id', user.id).single(),
      client
          .from('seances')
          .select(
            'id, start_time, end_time, is_exam, matieres(name), classes(name), salles(name)',
          )
          .eq('professor_id', user.id)
          .eq('date', today)
          .eq('status', 'publié')
          .order('start_time'),
    ]);

    final firstName =
        (results[0] as Map<String, dynamic>)['first_name'] as String? ?? '';
    final seancesList = results[1] as List<dynamic>;

    return AccueilData(
      professorFirstName: firstName,
      seances: seancesList
          .map((e) => SeanceDuJour.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
