import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../insights/presentation/daily_insights_card.dart';
import '../../insights/presentation/weekly_reflection_card.dart';
import 'pulsing_dot_fab.dart';
import 'timeline_dot.dart';

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
                    "dots.",
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
                  color: AppColors.greyLight,
                ),
              ).animate().fadeIn(delay: 200.ms),

              // The Universe Timeline
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: const [
                    TimelineDot(
                      title: "Daily Insight",
                      subtitle: "Pattern detected in 3 recent dumps.",
                      openBuilder: DailyInsightsCard(),
                    ),
                    TimelineDot(
                      title: "Weekly Reflection",
                      subtitle: "Sunday Reset for Oct 12-19.",
                      openBuilder: WeeklyReflectionCard(),
                      isLast: true,
                    ),
                  ],
                ).animate().slideX(begin: 0.1, delay: 200.ms),
              ),
              
              const SizedBox(height: 16),
              
              // Key Action: The Pulsing Dot
              const Center(child: PulsingDotFAB()),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
