import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Singleton Pattern
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  final _supabase = Supabase.instance.client;

  // Future<List<Map<String, dynamic>>> getMatches(): Fetch all entries from the matches table, ordered by created_at descending.
  Future<List<Map<String, dynamic>>> getMatches() async {
    try {
      final response = await _supabase
          .from('matches')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching matches: $e');
      return [];
    }
  }

  // Future<void> createMatch(...): Insert a new match into the matches table.
  Future<void> createMatch(
    String title,
    String sport,
    String location,
    int maxPlayers, {
    String? description,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Error creating match: No authenticated user.');
        return;
      }

      await _supabase.from('matches').insert({
        'title': title,
        'sport': sport,
        'location': location,
        'max_players': maxPlayers,
        'organizer_id': user.id,
        'description': description,
        'image_url': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      debugPrint('Error creating match: $e');
    }
  }

  // Future<void> sendMessage(String matchId, String content): Insert a new message into the messages table.
  Future<void> sendMessage(String matchId, String content) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Error sending message: No authenticated user.');
        return;
      }

      await _supabase.from('messages').insert({
        'match_id': matchId,
        'user_id': user.id,
        'text': content,
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  // Stream<List<Map<String, dynamic>>> getChatStream(String matchId): Return a real-time stream of messages for a specific match.
  Stream<List<Map<String, dynamic>>> getChatStream(String matchId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('match_id', matchId)
        .order('created_at', ascending: true);
  }
}
