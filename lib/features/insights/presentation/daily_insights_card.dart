import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../application/insights_provider.dart';

class DailyInsightsCard extends ConsumerWidget {
  const DailyInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyInsightAsync = ref.watch(dailyInsightProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.greyMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daily Insights",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.greyDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.sparkles, size: 16, color: AppColors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            dailyInsightAsync.when(
              data: (insight) {
                if (insight == null) {
                  return _buildEmptyState();
                }
                return _buildInsightContent(insight);
              },
              loading: () => _buildLoadingState(),
              error: (err, stack) => _buildErrorState(err.toString()),
            ),
            const SizedBox(height: 12),
            _buildFooter(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightContent(String insight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greyDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Synthesis",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Text(
      "Deep thoughts take time. Capture more dots to unlock today's synthesis.",
      style: TextStyle(
        fontSize: 13,
        color: AppColors.greyLight,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Text(
      "Couldn't connect the dots right now.",
      style: TextStyle(
        fontSize: 13,
        color: Colors.red.withOpacity(0.7),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "AI Synthesis • Live",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.greyLight,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () => ref.refresh(dailyInsightProvider),
          icon: const Icon(LucideIcons.refreshCw, size: 12, color: AppColors.greyLight),
          label: const Text(
            "Regenerate",
            style: TextStyle(color: AppColors.greyLight, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
