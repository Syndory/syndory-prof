import 'package:flutter/foundation.dart';
import '../supabase/supabase_client.dart';
import '../types/user_profile.dart';

class UserRepository {
  static Future<UserProfile?> getCurrentProfile() async {
    try {
      final user = SupabaseClientProvider.client.auth.currentUser;
      if (user == null) return null;

      final response = await SupabaseClientProvider.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('[UserRepository] Error fetching profile: $e');
      return null;
    }
  }
}
