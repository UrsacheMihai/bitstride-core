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
}