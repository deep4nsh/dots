class DailyInsight {
  final String digest;
  final List<MoodDataPoint> moodTrend;
  final Map<String, int> topKeywords;
  final List<String> actionItems;
  final double averageSentiment;

  DailyInsight({
    required this.digest,
    required this.moodTrend,
    required this.topKeywords,
    required this.actionItems,
    required this.averageSentiment,
  });
}

class MoodDataPoint {
  final DateTime time;
  final double sentiment;
  final String? mood;

  MoodDataPoint({
    required this.time,
    required this.sentiment,
    this.mood,
  });
}
