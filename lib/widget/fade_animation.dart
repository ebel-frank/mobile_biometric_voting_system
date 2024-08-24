import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class FadeAnimation extends StatelessWidget {
  const FadeAnimation({super.key, required this.child, required this.delay});

  final Widget child;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween(
        'opacity',
        Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 100),
      )..tween('y', Tween(begin: -30.0, end: 0.0),
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);

    return PlayAnimationBuilder(
      tween: tween,
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value.get('opacity'),
        child: Transform.translate(
          offset: Offset(0, value.get('y')),
          child: child,
        ),
      ),
    );
  }
}
