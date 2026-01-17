import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/dump_controller.dart';

class DumpScreen extends ConsumerStatefulWidget {
  const DumpScreen({super.key});

  @override
  ConsumerState<DumpScreen> createState() => _DumpScreenState();
}

class _DumpScreenState extends ConsumerState<DumpScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              foregroundColor: AppColors.accentBlueForeground,
              shape: const StadiumBorder(),
              backgroundColor: AppColors.accentBlue,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        "Today, ${DateTime.now().hour}:${DateTime.now().minute}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
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
                ),
                decoration: const InputDecoration(
                  hintText: "What's on your mind? \nDon't worry about structure.",
                  hintStyle: TextStyle(color: Colors.black26),
                  border: InputBorder.none,
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),
            
            // Toolbar
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ToolbarItem(icon: LucideIcons.mic, label: "Voice"),
                  _ToolbarItem(icon: LucideIcons.image, label: "Image"),
                  _ToolbarItem(icon: LucideIcons.scanLine, label: "Scan"),
                  _ToolbarItem(icon: LucideIcons.link, label: "Link"),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 1, end: 0),
          ],
        ),
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
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(
            label, 
            style: const TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary
            )
          ),
        ],
      ),
    );
  }
}
