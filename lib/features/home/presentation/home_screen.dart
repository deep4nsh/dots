import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../insights/presentation/weekly_reflection_card.dart';
import '../data/notes_provider.dart';
import 'pulsing_dot_fab.dart';
import 'timeline_dot.dart';
import '../../dump/presentation/note_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesStreamProvider);

    // Logging for debugging
    notesAsync.when(
      data: (notes) => print("📊 HomeScreen: Received ${notes.length} notes via Stream"),
      loading: () => print("📊 HomeScreen: Loading notes via Stream..."),
      error: (err, stack) => print("📊 HomeScreen: Error loading notes via Stream: $err"),
    );

    // One-time fetch to verify connectivity
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       try {
         final repository = ref.read(notesRepositoryProvider);
         print("🧪 Debug: Attempting manual one-time fetch...");
         final notes = await repository.testFetch();
         print("🧪 Debug: Manual fetch found ${notes.length} notes total");
       } catch (e) {
         print("🧪 Debug: Manual fetch FAILED: $e");
       }
    });

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

              const SizedBox(height: 24),

              // The Universe Timeline (Real-time Feed)
              Expanded(
                child: notesAsync.when(
                  data: (notes) {
                    if (notes.isEmpty) {
                      return Center(
                        child: Text(
                          "Your timeline is empty.\nTap the dot to start.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.greyMedium),
                        ),
                      ).animate().fadeIn();
                    }
                    
                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        final content = note['content'] as String;
                        final summary = note['summary'] as String?;
                        final createdAt = DateTime.parse(note['created_at']);
                        final timeStr = DateFormat('h:mm a').format(createdAt.toLocal());
                        
                        return TimelineDot(
                          title: summary ?? content, // Prefer summary, fallback to content
                          subtitle: summary != null ? content : timeStr,
                          isLast: index == notes.length - 1,
                          openBuilder: NoteDetailScreen(note: note), 
                        );
                      },
                    ).animate().slideX(begin: 0.1, delay: 200.ms);
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (err, stack) => Center(
                    child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Key Action: The Pulsing Dot
              // Key Action: The Pulsing Dot & AI Star
              Column(
                children: [
                  const PulsingDotFAB(),
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => context.push('/deep-insight'),
                    icon: Icon(
                      LucideIcons.sparkles, 
                      color: AppColors.white,
                      size: 28,
                    ),
                    tooltip: "Deep Insight",
                  ).animate().fadeIn(delay: 600.ms).scale(delay: 600.ms),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

