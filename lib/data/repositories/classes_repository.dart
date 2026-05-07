import '../supabase/supabase_client.dart';

class ClassesRepository {
  static Future<List<Map<String, dynamic>>> getProfessorClasses() async {
    final user = SupabaseClientProvider.client.auth.currentUser;
    if (user == null) return [];

    final response = await SupabaseClientProvider.client
        .from('professeur_matieres')
        .select('''
          class_id,
          classes (
            id,
            name,
            promotion,
            filieres (name),
            student_classes(count)
          ),
          matieres (name)
        ''')
        .eq('professor_id', user.id);

    // Group by class
    final Map<String, Map<String, dynamic>> grouped = {};

    for (final item in response) {
      final classData = item['classes'] as Map<String, dynamic>;
      final classId = classData['id'] as String;
      final matiereName = item['matieres']['name'] as String;

      if (!grouped.containsKey(classId)) {
        final studentCount = (classData['student_classes'] as List).isNotEmpty
            ? classData['student_classes'][0]['count'] as int
            : 0;

        grouped[classId] = {
          'id': classId,
          'name': classData['name'],
          'promotion': classData['promotion'],
          'filiere_name': classData['filieres']['name'],
          'subjects': <String>[matiereName],
          'student_count': studentCount,
        };
      } else {
        (grouped[classId]!['subjects'] as List<String>).add(matiereName);
      }
    }

    // Add attendance rate for each class
    final List<Map<String, dynamic>> result = [];
    for (final classInfo in grouped.values) {
      final classId = classInfo['id'] as String;
      final attendanceRate = await _calculateClassAttendanceRate(classId);
      result.add({...classInfo, 'attendance_rate': attendanceRate});
    }

    return result;
  }

  static Future<double> _calculateClassAttendanceRate(String classId) async {
    try {
      final response = await SupabaseClientProvider.client
          .from('presences')
          .select('status, sessions!inner(seances!inner(class_id))')
          .eq('sessions.seances.class_id', classId);

      final list = response as List;
      if (list.isEmpty) return 100.0;

      final validCount = list.where((p) {
        final status = p['status'] as String;
        return status == 'present' || status == 'late' || status == 'justified';
      }).length;

      return (validCount / list.length) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  static Future<List<Map<String, dynamic>>> getStudentsForClass(
    String classId,
  ) async {
    final response = await SupabaseClientProvider.client
        .from('student_classes')
        .select('''
          student_id,
          users (
            id,
            first_name,
            last_name,
            email
          )
        ''')
        .eq('class_id', classId)
        .eq('is_active', true);

    // TODO: Join with attendance stats if needed
    return (response as List)
        .cast<Map<String, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<Map<String, dynamic>?> getNextSessionForClass(
    String classId,
  ) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await SupabaseClientProvider.client
        .from('seances')
        .select('*, matieres(name), classes(name), salles(name)')
        .eq('class_id', classId)
        .gte('date', today)
        .eq('status', 'publié')
        .order('date', ascending: true)
        .order('start_time', ascending: true)
        .limit(1)
        .maybeSingle();

    return response;
  }
}
