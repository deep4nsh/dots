import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../application/dump_controller.dart';
import 'package:dots_mobile/core/constants/dump_prompts.dart';
import 'package:dots_mobile/core/presentation/widgets/aesthetic_dots_background.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class DumpScreen extends ConsumerStatefulWidget {
  const DumpScreen({super.key});

  @override
  ConsumerState<DumpScreen> createState() => _DumpScreenState();
}

class _DumpScreenState extends ConsumerState<DumpScreen> {
  final TextEditingController _controller = TextEditingController();
  late String _randomPrompt;
  
  // Multimedia State
  String? _imagePath;
  String? _voicePath;
  String? _linkUrl;
  bool _isScan = false;
  
  final AudioRecorder _recorder = AudioRecorder();
  final ImagePicker _picker = ImagePicker();

  // Recording Visuals State
  bool _isRecording = false;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  double _currentAmplitude = -160.0;
  final List<double> _amplitudes = List.filled(30, -160.0, growable: true);

  @override
  void initState() {
    super.initState();
    _randomPrompt = DumpPrompts.getRandom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _amplitudeSubscription?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _handleImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
        _isScan = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image attached')),
      );
    }
  }

  Future<void> _handleScan() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
        _isScan = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan attached')),
      );
    }
  }

  Future<void> _handleVoice() async {
    if (await _recorder.isRecording()) {
      final path = await _recorder.stop();
      _amplitudeSubscription?.cancel();
      setState(() {
        _voicePath = path;
        _isRecording = false;
        _currentAmplitude = -160.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice recording attached')),
      );
    } else {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _recorder.start(const RecordConfig(), path: path);
        
        setState(() => _isRecording = true);

        _amplitudeSubscription = _recorder
            .onAmplitudeChanged(const Duration(milliseconds: 50))
            .listen((amp) {
          setState(() {
            _currentAmplitude = amp.current;
            _amplitudes.removeAt(0);
            _amplitudes.add(amp.current);
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording started... Tap again to stop')),
        );
      }
    }
  }

  Future<void> _handleLink() async {
    final textController = TextEditingController();
    final link = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Link'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'https://...'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, textController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (link != null && link.isNotEmpty) {
      setState(() => _linkUrl = link);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(dumpControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white, // White Sweep
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final dumpState = ref.watch(dumpControllerProvider);
              final isLoading = dumpState.isLoading;

              return TextButton.icon(
                onPressed: isLoading ? null : () async {
                   await ref.read(dumpControllerProvider.notifier).saveDump(
                     _controller.text,
                     voicePath: _voicePath,
                     imagePath: _imagePath,
                     linkUrl: _linkUrl,
                     isScan: _isScan,
                   );
                   if (context.mounted) context.pop(); 
                },
                icon: isLoading 
                    ? const SizedBox(
                        width: 18, 
                        height: 18, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : const Icon(LucideIcons.arrowUp, size: 18),
                label: Text(isLoading ? "Thinking..." : "Dump"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  backgroundColor: isLoading ? Colors.grey : Colors.black,
                ),
              );
            }
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
                
                // Recording Visuals
                if (_isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                           .fadeIn(duration: 500.ms)
                           .fadeOut(delay: 500.ms, duration: 500.ms),
                          const SizedBox(width: 12),
                          const Text(
                            "Recording...",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _amplitudes.map((amp) {
                            // Map amplitude (-160 to 0) to height (2 to 40)
                            double height = ((amp + 160) / 160) * 38 + 2;
                            return Container(
                              width: 3,
                              height: height,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                
                // Attachment Preview
                if (_imagePath != null || _voicePath != null || _linkUrl != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_imagePath != null) ...[
                        const Icon(LucideIcons.image, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        const Text("Image", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                      ],
                      if (_voicePath != null) ...[
                        const Icon(LucideIcons.mic, size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        const Text("Voice", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                      ],
                      if (_linkUrl != null) ...[
                        const Icon(LucideIcons.link, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        const Text("Link", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() {
                          _imagePath = null;
                          _voicePath = null;
                          _linkUrl = null;
                          _isScan = false;
                        }),
                        child: const Icon(LucideIcons.x, size: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(),

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
                      _ToolbarItem(
                        icon: LucideIcons.mic, 
                        label: "Voice",
                        onPressed: () => _handleVoice(),
                      ),
                      _ToolbarItem(
                        icon: LucideIcons.image, 
                        label: "Image",
                        onPressed: () => _handleImage(),
                      ),
                      _ToolbarItem(
                        icon: LucideIcons.scanLine, 
                        label: "Scan",
                        onPressed: () => _handleScan(),
                      ),
                      _ToolbarItem(
                        icon: LucideIcons.link, 
                        label: "Link",
                        onPressed: () => _handleLink(),
                      ),
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
  final VoidCallback onPressed;

  const _ToolbarItem({
    required this.icon, 
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black54, size: 20),
            const SizedBox(height: 4),
            Text(
              label, 
              style: const TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.w600,
                color: Colors.black54
              ),
            ),
          ],
        ),
      ),
    );
  }
}
