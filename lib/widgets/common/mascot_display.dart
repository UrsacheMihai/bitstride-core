import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../providers/app/app_state.dart';

// Play the mascot video for success or failure feedback.
class MascotDisplay extends StatefulWidget {
  final String gifAsset;
  final double size;

  const MascotDisplay({
    super.key,
    required this.gifAsset,
    this.size = 120,
  });

  @override
  State<MascotDisplay> createState() => _MascotDisplayState();
}

// Manage state and provide providers for Mascot Display State.
class _MascotDisplayState extends State<MascotDisplay> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(MascotDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gifAsset != widget.gifAsset) {
      _controller?.dispose();
      _initialized = false;
      _hasError = false;
      _initVideo();
    }
  }

  void _initVideo() {
    final assetPath = _resolveAssetPath(widget.gifAsset);
    try {
      _controller = VideoPlayerController.asset(assetPath)
        ..setLooping(true)
        ..setVolume(0)
        ..initialize().then((_) {
          if (mounted) {
            setState(() => _initialized = true);
            _controller!.play();
          }
        }).catchError((_) {
          if (mounted) setState(() => _hasError = true);
        });
    } catch (_) {
      _hasError = true;
    }
  }

  String _resolveAssetPath(String asset) {
    if (asset.startsWith('assets/')) return asset;
    if (asset.endsWith('.webm')) return 'assets/mascot/$asset';
    if (asset.contains('lifting'))
      return 'assets/mascot/thumbs-up-4b8ec7e7-360.webm';
    if (asset.contains('sad'))
      return 'assets/mascot/thinking-hard-e507f346-360.webm';
    if (asset.contains('takingnotes'))
      return 'assets/mascot/reading-a-book-f50abbdd-360.webm';
    return 'assets/mascot/$asset';
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motionDisabled = context.watch<AppState>().motionDisabled;
    if (motionDisabled || _hasError) {
      return _buildStaticFallback();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _initialized && _controller != null
          ? SizedBox(
              key: ValueKey(widget.gifAsset),
              width: widget.size,
              height: widget.size,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.size / 4),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            )
          : SizedBox(
              key: ValueKey('loading_${widget.gifAsset}'),
              width: widget.size,
              height: widget.size,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStaticFallback() {
    IconData icon;
    Color color;
    if (widget.gifAsset.contains('thumbs') ||
        widget.gifAsset.contains('lifting') ||
        widget.gifAsset.contains('happy')) {
      icon = Icons.emoji_events;
      color = const Color(0xFFFFD740);
    } else if (widget.gifAsset.contains('thinking') ||
        widget.gifAsset.contains('sad')) {
      icon = Icons.sentiment_dissatisfied;
      color = const Color(0xFFFF5252);
    } else {
      icon = Icons.auto_stories;
      color = const Color(0xFF7C4DFF);
    }
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(widget.size / 4),
      ),
      child: Icon(icon, size: widget.size * 0.5, color: color),
    );
  }
}
