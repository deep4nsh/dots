import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../insights/presentation/daily_insights_card.dart';
import '../../insights/presentation/weekly_reflection_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "LightNote",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    onPressed: () {}, 
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Hero Text
              const Text(
                "Write anything.\nIt connects everything.",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 16),
              
              Text(
                "Capture thoughts without friction. Let AI find the patterns.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 48),

              // Insight Widgets
              const DailyInsightsCard().animate().slideX(begin: 0.1, delay: 300.ms),
              const SizedBox(height: 16),
              const WeeklyReflectionCard().animate().slideX(begin: 0.1, delay: 400.ms),

              const Spacer(),

              // Temporary Navigation Placeholders
              FilledButton.icon(
                onPressed: () => context.push('/dump'),
                icon: const Icon(Icons.add),
                label: const Text("Just Dump"),
              ).animate().scale(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
