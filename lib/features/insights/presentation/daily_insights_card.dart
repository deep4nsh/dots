import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class DailyInsightsCard extends StatelessWidget {
  const DailyInsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
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
            Container(
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
                          "Pattern Detected",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white, 
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "You've mentioned \"scaling\" in 3 notes this week, linking it to \"Redis\" from yesterday.",
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
            ),
            const SizedBox(height: 12),
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
                  "Generated 2h ago based on new entries",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.greyLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
