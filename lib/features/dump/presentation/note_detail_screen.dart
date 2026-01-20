import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:any_link_preview/any_link_preview.dart';
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

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final content = note['content'] as String;
    final summary = note['summary'] as String?;
    final mood = note['mood'] as String?;
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppbar(context, dateStr),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mood Badge
                  if (mood != null)
                  _buildMoodBadge(mood),
                  
                  const SizedBox(height: 16),
                  
                  // Main Content
                  Text(
                    content,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                  
                  const SizedBox(height: 32),
                  
                  // Multimedia Section
                  if (imageUrl != null || voiceUrl != null || linkUrl != null)
                  _buildMultimediaSection(imageUrl, voiceUrl, linkUrl),
                  
                  const SizedBox(height: 32),
                  
                  // Psychological Analysis
                  _buildAnalysisSection(
                    summary: summary,
                    intensity: emotionalIntensity,
                    drivers: drivers,
                    distortions: distortions,
                    values: values,
                    reflection: reflection,
                  ),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppbar(BuildContext context, String dateStr) {
    return SliverAppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        dateStr,
        style: TextStyle(
          color: AppColors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMoodBadge(String mood) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.smile, size: 14, color: AppColors.greyLight),
          const SizedBox(width: 8),
          Text(
            mood.toUpperCase(),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildMultimediaSection(String? imageUrl, String? voiceUrl, String? linkUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.white12,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ).animate().fadeIn().scale(),

        if (voiceUrl != null)
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying ? LucideIcons.pause : LucideIcons.play, 
                      color: AppColors.white,
                    ),
                    onPressed: () => _playVoice(voiceUrl),
                  ),
                  Expanded(
                    child: Slider(
                      value: _position.inMilliseconds.toDouble(),
                      max: _duration.inMilliseconds.toDouble() > 0 
                          ? _duration.inMilliseconds.toDouble() 
                          : 1.0,
                      onChanged: (v) => _audioPlayer.seek(Duration(milliseconds: v.toInt())),
                      activeColor: AppColors.white,
                      inactiveColor: Colors.white24,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
        ).animate().fadeIn().slideX(),

        if (linkUrl != null)
        AnyLinkPreview(
          link: linkUrl,
          cache: const Duration(days: 7),
          backgroundColor: Colors.white.withOpacity(0.05),
          placeholderWidget: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white12,
            child: Row(
              children: [
                const Icon(LucideIcons.link, color: Colors.blue),
                const SizedBox(width: 12),
                Text(linkUrl, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          errorWidget: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white12,
            child: Row(
              children: [
                const Icon(LucideIcons.link, color: Colors.red),
                const SizedBox(width: 12),
                Text(linkUrl, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ).animate().fadeIn(),
      ],
    );
  }

  Widget _buildAnalysisSection({
    String? summary,
    int? intensity,
    String? drivers,
    List<String>? distortions,
    List<String>? values,
    String? reflection,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.brainCircuit, color: AppColors.greyMedium, size: 20),
            const SizedBox(width: 12),
            const Text(
              "ANALYTICS",
              style: TextStyle(
                color: AppColors.greyMedium,
                letterSpacing: 2,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        if (summary != null)
        _buildInfoCard("Summary", summary),
        
        if (intensity != null)
        _buildIntensityBar(intensity),
        
        if (drivers != null)
        _buildInfoCard("Subconscious Driver", drivers),
        
        if (distortions != null && distortions.isNotEmpty)
        _buildInfoCard("Cognitive Biases", distortions.join(", ")),
        
        if (values != null && values.isNotEmpty)
        _buildInfoCard("Core Values Involved", values.join(", ")),
        
        if (reflection != null)
        Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.withOpacity(0.2), Colors.purple.withOpacity(0.2)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "DEEP REFLECTION",
                style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Text(
                reflection,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.greyLight, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: AppColors.white, fontSize: 16, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildIntensityBar(int intensity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Intensity", style: TextStyle(color: AppColors.greyLight, fontSize: 12, fontWeight: FontWeight.w600)),
              Text("$intensity / 10", style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: intensity / 10,
              backgroundColor: Colors.white12,
              color: Colors.white,
              minHeight: 8,
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
