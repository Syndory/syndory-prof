import 'package:flutter/material.dart';

class MissingSupabaseConfigScreen extends StatelessWidget {
  const MissingSupabaseConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration requise',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12),
              Text(
                'SUPABASE_URL et SUPABASE_ANON_KEY ne sont pas configurés.\n'
                'L’application ne peut pas démarrer sans Supabase.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
