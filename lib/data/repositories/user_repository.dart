import '../supabase/supabase_client.dart';
import '../types/user_profile.dart';

class UserRepository {
  static Future<UserProfile?> getCurrentProfile() async {
    final user = SupabaseClientProvider.client.auth.currentUser;
    if (user == null) return null;

    final response = await SupabaseClientProvider.client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return UserProfile.fromJson(response);
  }
}
