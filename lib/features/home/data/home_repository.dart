import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/supabase/supabase_client.dart';
import 'home_models.dart';

class HomeRepository {
  SupabaseClient get _client => SupabaseClientProvider.client;

  Future<HomePageData> fetchHomeData() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Non authentifié');

    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final results = await Future.wait([
      _fetchUser(userId),
      _fetchTodaySeances(userId, today),
      _fetchActiveSession(userId),
      _fetchPendingJustificatifsCount(),
      _fetchClasses(userId),
      _fetchNextSeance(userId, today),
    ]);

    final user = results[0] as Map<String, dynamic>;
    final seances = results[1] as List<SeanceModel>;
    final session = results[2] as ActiveSessionModel?;
    final justifCount = results[3] as int;
    final classes = results[4] as List<ClasseModel>;
    final nextSeance = results[5] as SeanceModel?;

    return HomePageData(
      firstName: user['first_name'] as String? ?? '',
      lastName: user['last_name'] as String? ?? '',
      pendingJustificatifs: justifCount,
      todaySeances: seances,
      activeSession: session,
      nextSeance: nextSeance,
      classes: classes,
    );
  }

  Future<Map<String, dynamic>> _fetchUser(String userId) {
    return _client
        .from('users')
        .select('first_name, last_name')
        .eq('id', userId)
        .single();
  }

  Future<List<SeanceModel>> _fetchTodaySeances(
      String userId, String today) async {
    final data = await _client
        .from('seances')
        .select(
            'id, date, start_time, end_time, status, matieres(name), classes(name), salles(name)')
        .eq('professor_id', userId)
        .eq('date', today)
        .eq('status', 'publié')
        .order('start_time');
    return (data as List)
        .map((e) => SeanceModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<ActiveSessionModel?> _fetchActiveSession(String userId) async {
    final data = await _client
        .from('sessions')
        .select('id, opened_at, seances(matieres(name), classes(name))')
        .eq('professor_id', userId)
        .eq('status', 'ouverte')
        .maybeSingle();
    if (data == null) return null;
    return ActiveSessionModel.fromMap(data);
  }

  Future<int> _fetchPendingJustificatifsCount() async {
    final data = await _client
        .from('justificatifs')
        .select('id')
        .eq('status', 'en_attente');
    return (data as List).length;
  }

  Future<SeanceModel?> _fetchNextSeance(String userId, String today) async {
    final data = await _client
        .from('seances')
        .select('id, date, start_time, end_time, matieres(name), classes(name), salles(name)')
        .eq('professor_id', userId)
        .eq('status', 'publié')
        .gt('date', today)
        .order('date')
        .order('start_time')
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return SeanceModel.fromMap(data);
  }

  Future<List<ClasseModel>> _fetchClasses(String userId) async {
    final data = await _client
        .from('professeur_matieres')
        .select('class_id, classes(id, name)')
        .eq('professor_id', userId);

    // Dédoublonnage par class_id (un prof peut enseigner plusieurs matières dans la même classe)
    final seen = <String>{};
    final uniqueClasses = <Map<String, dynamic>>[];
    for (final row in data as List) {
      final classId = row['class_id'] as String;
      if (seen.add(classId)) {
        uniqueClasses.add(row as Map<String, dynamic>);
      }
    }

    if (uniqueClasses.isEmpty) return [];

    final classIds = uniqueClasses.map((c) => c['class_id'] as String).toList();
    final students = await _client
        .from('student_classes')
        .select('class_id')
        .eq('is_active', true)
        .inFilter('class_id', classIds);

    final Map<String, int> countByClass = {};
    for (final s in students as List) {
      final cid = s['class_id'] as String;
      countByClass[cid] = (countByClass[cid] ?? 0) + 1;
    }

    return uniqueClasses.map((row) {
      final classId = row['class_id'] as String;
      final classData = row['classes'] as Map<String, dynamic>;
      return ClasseModel(
        id: classId,
        nom: classData['name'] as String? ?? '',
        studentCount: countByClass[classId] ?? 0,
      );
    }).toList();
  }
}
