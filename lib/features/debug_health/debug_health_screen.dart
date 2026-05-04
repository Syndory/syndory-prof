import 'package:flutter/material.dart';

import '../../app/env/app_env.dart';
import '../../data/supabase/supabase_client.dart';

class DebugHealthScreen extends StatefulWidget {
  const DebugHealthScreen({super.key});

  @override
  State<DebugHealthScreen> createState() => _DebugHealthScreenState();
}

class _DebugHealthScreenState extends State<DebugHealthScreen> {
  bool _isRunningTestCall = false;
  String? _testCallResult;

  Future<void> _runTestCall() async {
    final bool isSupabaseInitialized = SupabaseClientProvider.isInitialized;
    final bool isAuthenticated = isSupabaseInitialized &&
        SupabaseClientProvider.client.auth.currentSession != null;

    if (!isSupabaseInitialized) {
      setState(() {
        _testCallResult = 'Supabase non initialisé (config ENV manquante ?).';
      });
      return;
    }

    if (!isAuthenticated) {
      setState(() {
        _testCallResult =
            'Non connecté. Connecte-toi (Supabase Auth) pour exécuter le test DB.';
      });
      return;
    }

    setState(() {
      _isRunningTestCall = true;
      _testCallResult = null;
    });

    try {
      final response = await SupabaseClientProvider.client
          .from('users')
          .select('id')
          .limit(1);

      setState(() {
        _testCallResult = 'OK: ${response.toString()}';
      });
    } catch (e) {
      setState(() {
        _testCallResult = 'ERREUR: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRunningTestCall = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSupabaseInitialized = SupabaseClientProvider.isInitialized;

    final bool isAuthenticated = isSupabaseInitialized &&
        SupabaseClientProvider.client.auth.currentSession != null;

    final bool canRunDbTest =
        isSupabaseInitialized && isAuthenticated && !_isRunningTestCall;

    return Scaffold(
      appBar: AppBar(title: const Text('Debug / Health')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statut',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _KeyValueRow(
              label: 'Supabase initialisé',
              value: isSupabaseInitialized ? 'Oui' : 'Non',
            ),
            _KeyValueRow(
              label: 'Config ENV présente',
              value: AppEnv.hasSupabaseConfig ? 'Oui' : 'Non',
            ),
            _KeyValueRow(
              label: 'Auth',
              value: isAuthenticated ? 'Connecté' : 'Non connecté',
            ),
            const SizedBox(height: 24),
            const Text(
              'Test non destructif',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canRunDbTest ? _runTestCall : null,
                child: Text(
                  _isRunningTestCall
                      ? 'Test en cours…'
                      : (isAuthenticated
                          ? 'Lire 1 ligne depuis la table users'
                          : 'Lire 1 ligne depuis la table users (login requis)'),
                ),
              ),
            ),
            if (!isAuthenticated) ...[
              const SizedBox(height: 8),
              const Text(
                'Note: le test DB nécessite une session Auth valide (RLS).',
              ),
            ],
            if (_testCallResult != null) ...[
              const SizedBox(height: 12),
              Text(_testCallResult!),
            ],
          ],
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
