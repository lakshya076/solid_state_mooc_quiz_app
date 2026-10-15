import 'package:flutter/material.dart';

class ZoomableImage extends StatefulWidget {
  final String imageAsset;
  final String heroTag;

  const ZoomableImage({
    super.key,
    required this.imageAsset,
    this.heroTag = 'question_image',
  });

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  late TransformationController _transformController;
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _transformController.addListener(_onTransformChanged);
  }

  @override
  void didUpdateWidget(covariant ZoomableImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageAsset != widget.imageAsset) {
      _resetZoom();
    }
  }

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.05) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  void _zoomIn() {
    final currentMatrix = _transformController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    if (currentScale < 4.5) {
      final newScale = currentScale * 1.35;
      final scaleChange = newScale / currentScale;
      _transformController.value = Matrix4.copy(currentMatrix)
        ..scaleByDouble(scaleChange, scaleChange, 1.0, 1.0);
    }
  }

  void _zoomOut() {
    final currentMatrix = _transformController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    if (currentScale > 1.05) {
      final newScale = (currentScale * 0.74).clamp(1.0, 4.5);
      final scaleChange = newScale / currentScale;
      _transformController.value = Matrix4.copy(currentMatrix)
        ..scaleByDouble(scaleChange, scaleChange, 1.0, 1.0);
    } else {
      _resetZoom();
    }
  }

  void _resetZoom() {
    setState(() {
      _transformController.value = Matrix4.identity();
      _currentScale = 1.0;
    });
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text('Question Detail', style: TextStyle(fontSize: 16)),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 6.0,
              child: Image.asset(
                widget.imageAsset,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Pinch Zoom Area with double-tap zoom
          Positioned.fill(
            child: GestureDetector(
              onDoubleTap: () {
                if (_currentScale > 1.2) {
                  _resetZoom();
                } else {
                  _zoomIn();
                }
              },
              child: InteractiveViewer(
                transformationController: _transformController,
                maxScale: 5.0,
                minScale: 1.0,
                boundaryMargin: const EdgeInsets.all(20),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      widget.imageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text('Failed to load image'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Zoom control buttons (+ / - / Reset / Fullscreen)
          Positioned(
            right: 8,
            bottom: 8,
            child: GestureDetector(
              // Prevent taps on the buttons from flipping the parent flashcard
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom Out Button
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                      tooltip: 'Zoom Out',
                      visualDensity: VisualDensity.compact,
                      onPressed: _currentScale > 1.05 ? _zoomOut : null,
                    ),

                    // Scale indicator / Reset button
                    if (_currentScale > 1.05) ...[
                      InkWell(
                        onTap: _resetZoom,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '${(_currentScale * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.refresh, color: Colors.white70, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Zoom In Button
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      tooltip: 'Zoom In',
                      visualDensity: VisualDensity.compact,
                      onPressed: _currentScale < 4.5 ? _zoomIn : null,
                    ),

                    // Fullscreen Button
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white, size: 18),
                      tooltip: 'Fullscreen View',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _openFullscreen(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
