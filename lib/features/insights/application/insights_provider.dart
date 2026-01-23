import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ai_service.dart';
import '../../home/data/notes_provider.dart';

import '../domain/daily_insight.dart';

final dailyInsightProvider = FutureProvider<DailyInsight?>((ref) async {
  // 1. Await the latest notes from the stream
  final notes = await ref.watch(notesStreamProvider.future);
  
  if (notes.isEmpty) {
    return null;
  }

  // 2. Filter for today's notes (last 24 hours)
  final now = DateTime.now();
  final last24Hours = now.subtract(const Duration(hours: 24)).toUtc();
  
  final todaysNotes = notes.where((n) {
    final createdAt = DateTime.parse(n['created_at']).toUtc();
    return createdAt.isAfter(last24Hours);
  }).toList();

  if (todaysNotes.isEmpty) {
    return null;
  }
  
  // Sort notes for timeline/trend (oldest first for chart)
  todaysNotes.sort((a, b) => 
    DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']))
  );

  // 3. Extract and Aggregate Data
  final thoughts = todaysNotes.map((n) => n['content'] as String).toList();
  
  // Mood Trend
  final moodTrend = todaysNotes.map((n) {
    final sentiment = n['sentiment_score'] != null ? (n['sentiment_score'] as num).toDouble() : 0.0;
    return MoodDataPoint(
      time: DateTime.parse(n['created_at']).toLocal(),
      sentiment: sentiment,
      mood: n['mood'] as String?,
    );
  }).toList();

  // Keyword frequency
  final Map<String, int> keywordFreq = {};
  for (final note in todaysNotes) {
    final keywords = note['keywords'];
    if (keywords is List) {
      for (final k in keywords) {
        final key = k.toString().toLowerCase();
        keywordFreq[key] = (keywordFreq[key] ?? 0) + 1;
      }
    }
  }

  // Action Items collection
  final List<String> allActions = [];
  for (final note in todaysNotes) {
    final actions = note['action_items'];
    if (actions is List) {
      allActions.addAll(actions.map((a) => a.toString()));
    }
  }

  // Average Sentiment
  final avgSentiment = moodTrend.isEmpty 
      ? 0.0 
      : moodTrend.map((m) => m.sentiment).reduce((a, b) => a + b) / moodTrend.length;

  // 4. Generate AI Digest
  final digest = await AIService().generateDailyDigest(thoughts) ?? "No patterns could be distilled from today's thoughts.";

  return DailyInsight(
    digest: digest,
    moodTrend: moodTrend,
    topKeywords: keywordFreq,
    actionItems: allActions,
    averageSentiment: avgSentiment,
  );
});
