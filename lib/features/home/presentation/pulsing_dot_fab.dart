import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../dump/presentation/dump_screen.dart';

class PulsingDotFAB extends StatelessWidget {
  const PulsingDotFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade, // Expands from the dot
      transitionDuration: const Duration(milliseconds: 800),
      openBuilder: (context, _) => const DumpScreen(),
      closedElevation: 0,
      closedShape: const CircleBorder(),
      closedColor: AppColors.black, // Background behind the dot
      middleColor: Colors.white,
      openColor: Colors.white,
      closedBuilder: (context, openContainer) {
        return InkWell(
          onTap: openContainer,
          customBorder: const CircleBorder(),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.white.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black,
                ),
              ),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(begin: 1.0, end: 1.1, duration: 1200.ms, curve: Curves.easeInOut)
          .then()
          .boxShadow(
             begin: BoxShadow(color: AppColors.white.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
             end: BoxShadow(color: AppColors.white.withOpacity(0.6), blurRadius: 30, spreadRadius: 8),
             duration: 1200.ms,
          ),
        );
      },
    );
  }
}
