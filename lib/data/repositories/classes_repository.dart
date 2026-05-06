import '../supabase/supabase_client.dart';
import '../types/class_info.dart';

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
            filieres (name)
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
        grouped[classId] = {
          'id': classId,
          'name': classData['name'],
          'promotion': classData['promotion'],
          'filiere_name': classData['filieres']['name'],
          'subjects': <String>[matiereName],
        };
      } else {
        (grouped[classId]!['subjects'] as List<String>).add(matiereName);
      }
    }

    return grouped.values.toList();
  }

  static Future<List<Map<String, dynamic>>> getStudentsForClass(String classId) async {
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
    return response as List<Map<String, dynamic>>;
  }
}
