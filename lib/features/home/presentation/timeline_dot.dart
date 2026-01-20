import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TimelineDot extends StatelessWidget {
  final Widget openBuilder;
  final String title;
  final String subtitle;
  final bool isLast;
  final bool hasImage;
  final bool hasVoice;
  final bool hasLink;
  final bool isScan;

  const TimelineDot({
    super.key,
    required this.openBuilder,
    required this.title,
    required this.subtitle,
    this.isLast = false,
    this.hasImage = false,
    this.hasVoice = false,
    this.hasLink = false,
    this.isScan = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The Timeline Line & Dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(vertical: 4), // Eye-balled alignment
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.greyDark,
                    ),
                  ),
              ],
            ),
          ),
          
          // The Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: OpenContainer(
                closedColor: Colors.transparent,
                openColor: AppColors.black,
                closedElevation: 0,
                transitionType: ContainerTransitionType.fadeThrough,
                openBuilder: (context, _) => openBuilder,
                closedBuilder: (context, openContainer) {
                  return InkWell(
                    onTap: openContainer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.greyLight,
                          ),
                        ),
                        if (hasImage || hasVoice || hasLink) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (hasVoice)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.mic, size: 12, color: Colors.redAccent),
                                ),
                              if (hasImage)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    isScan ? Icons.document_scanner : Icons.image, 
                                    size: 12, 
                                    color: Colors.blueAccent
                                  ),
                                ),
                              if (hasLink)
                                const Icon(Icons.link, size: 12, color: Colors.greenAccent),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
