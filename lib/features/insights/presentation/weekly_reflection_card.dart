import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class WeeklyReflectionCard extends StatelessWidget {
  const WeeklyReflectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFEEF2FF), // Indigo 50
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SUNDAY RESET",
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.accentBlueForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Weekly Reflection",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(LucideIcons.calendar, color: AppColors.accentBlueForeground.withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Your ideas on Product Strategy are taking shape. You cleared 12 dumps this week.",
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.indigo.shade900,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.6),
                  side: BorderSide.none,
                  foregroundColor: Colors.black,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Text("Read Full Digest", style: TextStyle(fontWeight: FontWeight.w600)),
                label: const Icon(LucideIcons.arrowRight, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
