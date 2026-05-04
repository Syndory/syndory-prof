import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientProvider {
  SupabaseClientProvider._();

  static bool get isInitialized {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  static SupabaseClient get client {
    return Supabase.instance.client;
  }

  static Future<bool> init({required String url, required String anonKey}) async {
    if (url.trim().isEmpty || anonKey.trim().isEmpty) {
      return false;
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    return true;
  }

  static Future<FunctionResponse> callEdgeFunction(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    final response = await client.functions.invoke(
      functionName,
      body: body == null ? null : jsonEncode(body),
    );
    return response;
  }
}
