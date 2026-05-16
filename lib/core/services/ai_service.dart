import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY';
  static const String _model = 'claude-sonnet-4-20250514';

  Future<String> getHabitCoaching({
    required String habitTitle,
    required String category,
    required int streak,
    required int totalCompletions,
    required bool completedToday,
    required String mood,
    required String reflection,
  }) async {
    final prompt = '''
You are an expert habit coach. A user is tracking a habit and needs personalized advice.

Habit: $habitTitle
Category: $category
Current streak: $streak days
Total completions: $totalCompletions
Completed today: $completedToday
Today's mood: ${mood.isEmpty ? 'Not logged' : mood}
Today's reflection: ${reflection.isEmpty ? 'None' : reflection}

Give a SHORT, personalized, motivating coaching message (2-3 sentences max). 
Be specific to their habit and streak. Sound human and encouraging, not generic.
If they have a reflection, respond to it directly.
End with one specific actionable tip for tomorrow.
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 200,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else {
        return _fallbackInsight(streak, totalCompletions, completedToday);
      }
    } catch (e) {
      return _fallbackInsight(streak, totalCompletions, completedToday);
    }
  }

  Future<String> getMoodResponse({
    required String habitTitle,
    required String mood,
    required String reflection,
    required int streak,
  }) async {
    final prompt = '''
You are a supportive habit coach. A user just completed their habit and shared how they feel.

Habit: $habitTitle
Current streak: $streak days
Mood: ${mood.isEmpty ? 'neutral' : mood}
Reflection: ${reflection.isEmpty ? 'No reflection added' : reflection}

Reply with a SHORT, warm, personalized response (2 sentences max).
Acknowledge their mood and reflection directly. Be encouraging but real.
Do NOT use generic phrases like "Great job!" or "Keep it up!".
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 150,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else {
        return _fallbackMoodResponse(mood, reflection);
      }
    } catch (e) {
      return _fallbackMoodResponse(mood, reflection);
    }
  }

  Future<String> getWeeklyInsight({
    required int totalHabits,
    required int completedToday,
    required int longestStreak,
    required int totalCompletions,
    required List<String> categories,
  }) async {
    final prompt = '''
You are a habit analytics coach. Give a weekly insight for this user.

Stats:
- Total habits: $totalHabits
- Completed today: $completedToday
- Longest streak: $longestStreak days
- Total completions: $totalCompletions
- Categories: ${categories.join(', ')}

Give a SHORT personalized weekly insight (3 sentences max).
Be specific to their numbers. Identify one strength and one area to improve.
Sound like a real coach, not a bot.
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 200,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else {
        return _fallbackWeeklyInsight(longestStreak, totalCompletions);
      }
    } catch (e) {
      return _fallbackWeeklyInsight(longestStreak, totalCompletions);
    }
  }

  String _fallbackInsight(int streak, int total, bool completedToday) {
    if (streak >= 10) return '👑 You\'re unstoppable. $streak days strong!';
    if (streak >= 5) return '🔥 $streak day streak — strong momentum building.';
    if (completedToday) return '✅ Great work completing this today!';
    return '🌱 Every day you show up makes the next day easier.';
  }

  String _fallbackMoodResponse(String mood, String reflection) {
    if (reflection.toLowerCase().contains('tired')) {
      return '😴 Rest is part of the process. You still showed up today — that matters.';
    }
    if (reflection.toLowerCase().contains('great') ||
        reflection.toLowerCase().contains('good')) {
      return '🔥 That energy is exactly what builds momentum. Ride it tomorrow too!';
    }
    return '💪 You completed it — that\'s what counts. Tomorrow is another chance.';
  }

  String _fallbackWeeklyInsight(int streak, int total) {
    if (streak >= 7) return '🔥 A $streak-day streak is elite. Most people quit by day 3.';
    if (total >= 10) return '📈 $total total completions shows real commitment forming.';
    return '🌱 You\'re building the foundation. Consistency now = results later.';
  }
}