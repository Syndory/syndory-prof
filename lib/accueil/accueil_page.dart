import 'dart:async';

import 'package:flutter/material.dart';

import '../data/supabase/supabase_client.dart';
import 'accueil_error.dart';
import 'accueil_loaded.dart';
import 'accueil_skeleton.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  Future<AccueilLoadedData>? _future;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    // Rafraîchit chaque minute pour mettre à jour les statuts EN COURS / À VENIR
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _load() => setState(() {
        _future = _fetchData();
      });

  Future<AccueilLoadedData> _fetchData() async {
    final client = SupabaseClientProvider.client;
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Non authentifié');

    final today = DateTime.now().toIso8601String().split('T')[0];
    final userId = user.id;

    final results = await Future.wait<dynamic>([
      _fetchUser(userId),
      _fetchTodaySeances(userId, today),
      _fetchPendingJustificatifsCount(),
      _fetchClasses(userId),
    ]);

    final userMap = results[0] as Map<String, dynamic>;
    final seancesList = results[1] as List<dynamic>;
    final pendingCount = results[2] as int;
    final classes = results[3] as List<ClasseData>;

    return AccueilLoadedData(
      firstName: userMap['first_name'] as String? ?? '',
      lastName: userMap['last_name'] as String? ?? '',
      pendingJustificatifs: pendingCount,
      todaySeances: seancesList
          .map((e) => SeanceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      classes: classes,
    );
  }

  Future<Map<String, dynamic>> _fetchUser(String userId) async {
    return await SupabaseClientProvider.client
        .from('users')
        .select('first_name, last_name')
        .eq('id', userId)
        .single();
  }

  Future<List<dynamic>> _fetchTodaySeances(
      String userId, String today) async {
    return await SupabaseClientProvider.client
        .from('seances')
        .select(
          'id, date, start_time, end_time, is_exam, matieres(name), classes(name), salles(name)',
        )
        .eq('professor_id', userId)
        .eq('date', today)
        .eq('status', 'publié')
        .order('start_time');
  }

  Future<int> _fetchPendingJustificatifsCount() async {
    try {
      final rows = await SupabaseClientProvider.client
          .from('justificatifs')
          .select('id')
          .eq('status', 'en_attente');
      return (rows as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<List<ClasseData>> _fetchClasses(String userId) async {
    try {
      final client = SupabaseClientProvider.client;
      final rows = await client
          .from('professeur_matieres')
          .select('classes(id, name)')
          .eq('professor_id', userId);

      final seen = <String>{};
      final uniqueClasses = <Map<String, dynamic>>[];

      for (final row in rows as List) {
        final classData = row['classes'] as Map<String, dynamic>?;
        if (classData == null) continue;
        final classId = classData['id'] as String;
        if (seen.add(classId)) uniqueClasses.add(classData);
      }

      if (uniqueClasses.isEmpty) return [];

      final counts = await Future.wait(uniqueClasses.map((c) async {
        try {
          final students = await client
              .from('student_classes')
              .select('id')
              .eq('class_id', c['id'] as String);
          return (students as List).length;
        } catch (_) {
          return 0;
        }
      }));

      return List.generate(
        uniqueClasses.length,
        (i) => ClasseData(
          id: uniqueClasses[i]['id'] as String,
          nom: uniqueClasses[i]['name'] as String,
          studentCount: counts[i],
        ),
      );
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AccueilLoadedData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const AccueilSkeleton();
        }
        if (snap.hasError) {
          return NoConnectionPage(onRetry: _load);
        }
        return AccueilLoadedPage(
          data: snap.requireData,
          onRefresh: _load,
        );
      },
    );
  }
}
