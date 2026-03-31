import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLottieLoading extends StatefulWidget {
  final double height;
  
  const CustomLottieLoading({super.key, this.height = 80});

  @override
  State<CustomLottieLoading> createState() => _CustomLottieLoadingState();
}

class _CustomLottieLoadingState extends State<CustomLottieLoading> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    // Explicitly disposes the animation to free memory as requested!
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/lottie/loading.json',
        controller: _controller,
        height: widget.height,
        onLoaded: (composition) {
          _controller
            ..duration = composition.duration
            ..repeat();
        },
      ),
    );
  }
}
