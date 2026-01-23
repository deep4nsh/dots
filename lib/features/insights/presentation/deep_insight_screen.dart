import 'package:dots_mobile/features/insights/domain/daily_insight.dart';
import 'package:dots_mobile/features/insights/presentation/widgets/mood_trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../application/insights_provider.dart';

class DeepInsightScreen extends ConsumerWidget {
  const DeepInsightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyInsightAsync = ref.watch(dailyInsightProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Today's Depth",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: dailyInsightAsync.when(
          data: (insight) {
            if (insight == null) {
              return _buildEmptyState();
            }
            return _buildInsightContent(context, insight, ref);
          },
          loading: () => _buildLoadingState(),
          error: (err, stack) => _buildErrorState(err.toString()),
        ),
      ),
    );
  }

  Widget _buildInsightContent(BuildContext context, DailyInsight insight, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildSentimentHeader(insight.averageSentiment),
            const SizedBox(height: 32),
            _buildSectionTitle(LucideIcons.lineChart, "Mood Over Time"),
            const SizedBox(height: 16),
            MoodTrendChart(dataPoints: insight.moodTrend)
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.1),
            const SizedBox(height: 40),
            _buildSectionTitle(LucideIcons.hash, "Core Topics"),
            const SizedBox(height: 16),
            _buildTopicCloud(insight.topKeywords),
            const SizedBox(height: 40),
            _buildSectionTitle(LucideIcons.sparkles, "AI Synthesis"),
            const SizedBox(height: 16),
            _buildDigestBox(insight.digest),
            const SizedBox(height: 40),
            if (insight.actionItems.isNotEmpty) ...[
              _buildSectionTitle(LucideIcons.checkSquare, "Action Items"),
              const SizedBox(height: 16),
              _buildActionItems(insight.actionItems),
              const SizedBox(height: 40),
            ],
            _buildActionButtons(context, ref),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.white.withOpacity(0.5), size: 18),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: AppColors.white.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.05);
  }

  Widget _buildSentimentHeader(double average) {
    final bool isPositive = average >= 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? LucideIcons.smile : LucideIcons.frown,
              color: isPositive ? Colors.greenAccent : Colors.orangeAccent,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Overall Vibe",
                  style: TextStyle(color: AppColors.greyLight, fontSize: 13),
                ),
                Text(
                  isPositive ? "Elevated & Positive" : "Quiet & Reflective",
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${(average.abs() * 100).toInt()}%",
            style: TextStyle(
              color: isPositive ? Colors.greenAccent : Colors.orangeAccent,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTopicCloud(Map<String, int> keywords) {
    if (keywords.isEmpty) return const SizedBox.shrink();
    
    // Sort by frequency
    final sorted = keywords.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: sorted.take(12).map((entry) {
        final double opacity = (entry.value / sorted.first.value).clamp(0.3, 1.0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.05 * opacity),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.white.withOpacity(0.1 * opacity)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.key,
                style: TextStyle(
                  color: AppColors.white.withOpacity(opacity),
                  fontWeight: entry.value > 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (entry.value > 1) ...[
                const SizedBox(width: 6),
                Text(
                  "x${entry.value}",
                  style: TextStyle(color: AppColors.greyLight, fontSize: 10),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildDigestBox(String digest) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white.withOpacity(0.05)),
      ),
      child: Text(
        digest,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          height: 1.6,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05);
  }

  Widget _buildActionItems(List<String> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.circle, color: AppColors.greyLight, size: 14),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  items[index],
                  style: const TextStyle(color: AppColors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
          const SizedBox(height: 24),
          Text(
            "Synthesizing your day...",
            style: TextStyle(color: AppColors.greyLight, fontSize: 16),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.cloudMoon, color: AppColors.greyMedium, size: 64),
          const SizedBox(height: 24),
          Text(
            "The data is still quiet.",
            style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Accumulate more thoughts today\nto unlock deep patterns.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.greyMedium, fontSize: 14),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, color: Colors.red, size: 40),
            const SizedBox(height: 16),
            Text(
              "Something went sideways.",
              style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.greyLight, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InsightActionButton(
                icon: LucideIcons.refreshCw,
                label: "Regenerate",
                onPressed: () => ref.refresh(dailyInsightProvider),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _InsightActionButton(
                icon: LucideIcons.share2,
                label: "Share",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sharing reflection...")),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 1000.ms);
  }
}

class _InsightActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _InsightActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        side: BorderSide(color: AppColors.white.withOpacity(0.1)),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
