import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../application/dump_controller.dart';
import 'package:dots_mobile/core/constants/dump_prompts.dart';
import 'package:dots_mobile/core/presentation/widgets/aesthetic_dots_background.dart';

class DumpScreen extends ConsumerStatefulWidget {
  const DumpScreen({super.key});

  @override
  ConsumerState<DumpScreen> createState() => _DumpScreenState();
}

class _DumpScreenState extends ConsumerState<DumpScreen> {
  final TextEditingController _controller = TextEditingController();
  late String _randomPrompt;

  @override
  void initState() {
    super.initState();
    _randomPrompt = DumpPrompts.getRandom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White Sweep
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
               await ref.read(dumpControllerProvider.notifier).saveDump(_controller.text);
               if (mounted) context.pop(); 
            },
            icon: const Icon(LucideIcons.arrowUp, size: 18),
            label: const Text("Dump"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              backgroundColor: Colors.black,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // Aesthetic Background Dots
          const Positioned.fill(
            child: AestheticDotsBackground(dotCount: 20),
          ),
          
          // Main Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Date / Context
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.greyDark.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 14, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text(
                            "Today, ${DateTime.now().hour}:${DateTime.now().minute}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideX(),
                
                const SizedBox(height: 24),
                
                // Input Area
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: _randomPrompt,
                      hintStyle: const TextStyle(color: Colors.black26),
                      border: InputBorder.none,
                    ),
                    cursorColor: Colors.black,
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                ),
                
                // Toolbar
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const _ToolbarItem(icon: LucideIcons.mic, label: "Voice"),
                      const _ToolbarItem(icon: LucideIcons.image, label: "Image"),
                      const _ToolbarItem(icon: LucideIcons.scanLine, label: "Scan"),
                      const _ToolbarItem(icon: LucideIcons.link, label: "Link"),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 1, end: 0, curve: Curves.easeOutQuad),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ToolbarItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(height: 4),
          Text(
            label, 
            style: const TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.w600,
              color: Colors.black54
            ),
          ).animate(onPlay: (controller) => controller.repeat()).fadeIn(duration: 600.ms), // Fixed usage of animate
        ],
      ),
    );
  }
}
