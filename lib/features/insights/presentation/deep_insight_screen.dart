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
          "Deep Insight",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: dailyInsightAsync.when(
                  data: (insight) {
                    if (insight == null) {
                      return _buildEmptyState();
                    }
                    return _buildInsightContent(insight);
                  },
                  loading: () => _buildLoadingState(),
                  error: (err, stack) => _buildErrorState(err.toString()),
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightContent(String insight) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, color: AppColors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                "Today's Patterns",
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 24),
          Text(
            insight,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              height: 1.6,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
          const SizedBox(height: 24),
          Text(
            "Connecting the dots...",
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
          const SizedBox(height: 16),
          Text(
            "The universe is quiet.",
            style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "No patterns found today yet.\nKeep dumping your thoughts.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.greyMedium, fontSize: 13),
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
              "AI is having a moment.",
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
                icon: LucideIcons.share2,
                label: "Share",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sharing preview...")),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _InsightActionButton(
                icon: LucideIcons.bookmark,
                label: "Save",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Insight saved to your universe.")),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => ref.refresh(dailyInsightProvider),
              icon: const Icon(LucideIcons.refreshCw, size: 14, color: AppColors.greyLight),
              label: const Text(
                "Regenerate Insight",
                style: TextStyle(color: AppColors.greyLight, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
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
        side: const BorderSide(color: AppColors.greyMedium),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}
