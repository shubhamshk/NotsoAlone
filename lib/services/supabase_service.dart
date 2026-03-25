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

  // Future<void> joinMatch(String matchId): Register a user as a participant and increment joined_players count.
  Future<void> joinMatch(String matchId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Error joining match: No authenticated user.');
        return;
      }

      // 1. Fetch current joined count and max players
      final matchData = await _supabase
          .from('matches')
          .select('joined_players, max_players')
          .eq('id', matchId)
          .single();
      
      final int currentJoined = int.tryParse(matchData['joined_players'].toString()) ?? 0;
      final int maxPlayers = int.tryParse(matchData['max_players'].toString()) ?? 100;

      if (currentJoined >= maxPlayers) {
        debugPrint('Match is already full.');
        return;
      }

      // 2. Perform join (Insert into participants and Increment count)
      // Note: In a production app, we'd use a Supabase RPC to make this atomic.
      await _supabase.from('match_participants').insert({
        'match_id': matchId,
        'user_id': user.id,
      });

      await _supabase.from('matches').update({
        'joined_players': currentJoined + 1,
      }).eq('id', matchId);

    } catch (e) {
      debugPrint('Error joining match: $e');
      rethrow;
    }
  }
}

