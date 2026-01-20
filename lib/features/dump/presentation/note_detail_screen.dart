import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';

class NoteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });
    
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playVoice(String url) async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(url));
    }
  }

  Color _getMoodColor(String mood) {
    mood = mood.toLowerCase();
    if (mood.contains('anxious') || mood.contains('stressed')) return Colors.orangeAccent;
    if (mood.contains('happy') || mood.contains('joy')) return Colors.yellowAccent;
    if (mood.contains('sad') || mood.contains('down')) return Colors.blueAccent;
    if (mood.contains('angry')) return Colors.redAccent;
    if (mood.contains('calm') || mood.contains('peaceful')) return Colors.tealAccent;
    if (mood.contains('creative') || mood.contains('inspired')) return Colors.purpleAccent;
    return Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final content = note['content'] as String;
    final summary = note['summary'] as String?;
    final mood = note['mood'] as String? ?? 'Neutral';
    final keywords = (note['keywords'] as List?)?.cast<String>() ?? [];
    final actionItems = (note['action_items'] as List?)?.cast<String>() ?? [];
    
    final createdAtString = note['created_at'] as String?;
    final createdAt = createdAtString != null ? DateTime.parse(createdAtString) : DateTime.now();
    final dateStr = DateFormat('MMMM d, yyyy • h:mm a').format(createdAt.toLocal());
    
    // Granular Analysis
    final emotionalIntensity = note['emotional_intensity'] as int?;
    final drivers = note['subconscious_drivers'] as String?;
    final distortions = (note['cognitive_distortions'] as List?)?.cast<String>();
    final values = (note['core_values'] as List?)?.cast<String>();
    final reflection = note['reflection_question'] as String?;
    
    // Multimedia
    final imageUrl = note['image_url'] as String?;
    final voiceUrl = note['voice_url'] as String?;
    final linkUrl = note['link_url'] as String?;

    final moodColor = _getMoodColor(mood);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: moodColor.withOpacity(0.05),
              ),
            ).animate().fadeIn(duration: 1.seconds).scale(begin: const Offset(0.5, 0.5)),
          ),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppbar(context, dateStr),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mood Header
                      _buildHeader(mood, moodColor),
                      
                      const SizedBox(height: 32),
                      
                      // Content Card (Premium Glassmorphism)
                      _buildGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              content,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        glowColor: moodColor,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05),
                      
                      const SizedBox(height: 32),
                      
                      // Multimedia Section
                      if (imageUrl != null || voiceUrl != null || linkUrl != null)
                      _buildMultimediaSection(imageUrl, voiceUrl, linkUrl),
                      
                      const SizedBox(height: 32),
                      
                      // AI Summary
                      if (summary != null)
                      _buildSummarySection(summary),
                      
                      const SizedBox(height: 32),
                      
                      // Keywords
                      if (keywords.isNotEmpty)
                      _buildKeywords(keywords, moodColor),
                      
                      const SizedBox(height: 32),

                      // Action Items
                      if (actionItems.isNotEmpty)
                      _buildActionItems(actionItems, moodColor),

                      const SizedBox(height: 32),
                      
                      // Deep Psychological Analysis
                      _buildDetailedAnalysis(
                        intensity: emotionalIntensity,
                        drivers: drivers,
                        distortions: distortions,
                        values: values,
                        reflection: reflection,
                        moodColor: moodColor,
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String mood, Color moodColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "DUMP ANALYSIS",
              style: TextStyle(
                color: moodColor.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mood.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: moodColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: moodColor.withOpacity(0.2)),
          ),
          child: Icon(LucideIcons.brain, color: moodColor, size: 24),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
          duration: 2.seconds,
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildGlassCard({required Widget child, Color? glowColor}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          if (glowColor != null)
          BoxShadow(
            color: glowColor.withOpacity(0.02),
            blurRadius: 40,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context, String dateStr) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        dateStr.toUpperCase(),
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSummarySection(String summary) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.sparkles, color: Colors.blueAccent, size: 16),
              const SizedBox(width: 8),
              Text(
                "SYNTHESIS",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildKeywords(List<String> keywords, Color moodColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: keywords.map((k) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          "#$k",
          style: TextStyle(
            color: moodColor.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      )).toList(),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildActionItems(List<String> items, Color moodColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ACTIONABLE DOTS",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: moodColor.withOpacity(0.4)),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: moodColor.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildMultimediaSection(String? imageUrl, String? voiceUrl, String? linkUrl) {
    return Column(
      children: [
        if (imageUrl != null)
        GestureDetector(
          onTap: () => _showFullScreenImage(imageUrl),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, p) => p == null ? child : Container(height: 200, color: Colors.white12, child: const Center(child: CircularProgressIndicator())),
              ),
            ),
          ).animate().fadeIn().scale(),
        ),
        
        if (voiceUrl != null)
        _buildVoicePlayer(voiceUrl),

        if (linkUrl != null)
        _buildLinkPreview(linkUrl),
      ],
    );
  }

  Widget _buildVoicePlayer(String url) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _playVoice(url),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(_isPlaying ? LucideIcons.pause : LucideIcons.play, color: Colors.black, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: _position.inMilliseconds.toDouble(),
                    max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                    onChanged: (v) => _audioPlayer.seek(Duration(milliseconds: v.toInt())),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white12,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      Text(_formatDuration(_duration), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildLinkPreview(String url) {
    return AnyLinkPreview(
      link: url,
      cache: const Duration(days: 7),
      backgroundColor: Colors.white.withOpacity(0.05),
      borderRadius: 24,
      placeholderWidget: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(24)), child: Row(children: [const Icon(LucideIcons.link, color: Colors.blueAccent), const SizedBox(width: 12), Expanded(child: Text(url, style: const TextStyle(color: Colors.white70, fontSize: 12)))] ) ),
    ).animate().fadeIn();
  }

  Widget _buildDetailedAnalysis({
    int? intensity,
    String? drivers,
    List<String>? distortions,
    List<String>? values,
    String? reflection,
    required Color moodColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "PSYCHOLOGICAL INSIGHTS",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 24),
        
        if (intensity != null)
        _buildAnalysisCard("EMOTIONAL INTENSITY", "$intensity/10", moodColor, 
          progress: intensity / 10),
        
        if (drivers != null)
        _buildAnalysisCard("SUBCONSCIOUS DRIVER", drivers, moodColor),
        
        if (distortions != null && distortions.isNotEmpty)
        _buildAnalysisCard("COGNITIVE BIASES", distortions.join(" • "), moodColor),
        
        if (values != null && values.isNotEmpty)
        _buildAnalysisCard("CORE VALUES", values.join(" • "), moodColor),
        
        if (reflection != null)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [moodColor.withOpacity(0.1), Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: moodColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.helpCircle, color: moodColor, size: 16),
                  const SizedBox(width: 12),
                  Text(
                    "REFLECTION",
                    style: TextStyle(color: moodColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                reflection,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ).animate(delay: 600.ms).fadeIn(duration: 800.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildAnalysisCard(String label, String value, Color moodColor, {double? progress}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white12,
                color: moodColor,
                minHeight: 4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.05)),
        ],
      ),
    );
  }

  void _showFullScreenImage(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) => Stack(
        children: [
          Center(child: InteractiveViewer(child: Image.network(url))),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
