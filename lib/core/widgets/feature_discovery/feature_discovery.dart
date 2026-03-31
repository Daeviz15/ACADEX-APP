import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'spotlight_painter.dart';
import 'discovery_bubble.dart';

class FeatureDiscoveryStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final String? lottiePath;

  FeatureDiscoveryStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.lottiePath,
  });
}

class FeatureDiscoveryOverlay {
  static OverlayEntry? _overlayEntry;

  /// Starts a feature discovery sequence targeting specific keys.
  static void show(
    BuildContext context, {
    required List<FeatureDiscoveryStep> steps,
    required VoidCallback onComplete,
  }) {
    if (steps.isEmpty) return;
    
    // Always dismiss existing before creating new
    dismiss();

    int currentStepIndex = 0;
    
    // Create the persistent overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _FeatureDiscoveryOrchestrator(
          steps: steps,
          initialIndex: currentStepIndex,
          onComplete: () {
            dismiss();
            onComplete();
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _FeatureDiscoveryOrchestrator extends StatefulWidget {
  final List<FeatureDiscoveryStep> steps;
  final int initialIndex;
  final VoidCallback onComplete;

  const _FeatureDiscoveryOrchestrator({
    required this.steps,
    required this.initialIndex,
    required this.onComplete,
  });

  @override
  State<_FeatureDiscoveryOrchestrator> createState() =>
      _FeatureDiscoveryOrchestratorState();
}

class _FeatureDiscoveryOrchestratorState extends State<_FeatureDiscoveryOrchestrator>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    await _animController.reverse(); // fade out old step
    
    if (!mounted) return;

    if (_currentIndex < widget.steps.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _animController.forward(); // fade in new step
    } else {
      widget.onComplete();
    }
  }

  // Gets the exact bounding box of the target widget on screen
  Rect _getTargetRect(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Rect.zero;

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentIndex];
    final targetRect = _getTargetRect(step.targetKey);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. Background Blur & Overlay Hole Punching
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Subtle Backdrop blur
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 8.0 * _animation.value,
                      sigmaY: 8.0 * _animation.value,
                    ),
                    child: const SizedBox.expand(),
                  ),
                  
                  // The darkness + spotlight hole
                  CustomPaint(
                    size: Size.infinite,
                    painter: SpotlightPainter(
                      targetRect: targetRect,
                      progress: _animation,
                      padding: 12.0, // generous padding around widget
                      borderRadius: 20.0,
                    ),
                  ),
                ],
              );
            },
          ),
          
          // 2. The Floating Instruction Bubble
          // We calculate its position so it's vertically above or below the target
          Positioned(
            left: 20, // Default padding from screen edges
            right: 20, // (This stretches it, but DiscoveryBubble sets a width of 280, so we just use it to center)
            top: _calculateBubbleTop(context, targetRect),
            child: FadeTransition(
              opacity: _animation,
              child: Center(
                child: DiscoveryBubble(
                  title: step.title,
                  description: step.description,
                  lottiePath: step.lottiePath,
                  buttonText: _currentIndex == widget.steps.length - 1
                      ? 'Done'
                      : 'Next',
                  onNext: _nextStep,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateBubbleTop(BuildContext context, Rect targetRect) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    // If the target is in the top half of the screen, place bubble below it
    if (targetRect.center.dy < screenHeight / 2) {
      return targetRect.bottom + 24; 
    } else {
      // If target is in bottom half, place bubble above it
      return targetRect.top - 280; // approximate bubble height + padding
    }
  }
}
