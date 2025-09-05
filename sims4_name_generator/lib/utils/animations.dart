import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Utility class for custom animations and transitions
class AppAnimations {
  /// Slide in from bottom animation
  static Widget slideInFromBottom({
    required Widget child,
    required AnimationController controller,
    Duration delay = Duration.zero,
  }) {
    final animation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              delay.inMilliseconds / controller.duration!.inMilliseconds,
              1.0,
              curve: Curves.easeOutCubic,
            ),
          ),
        );

    return SlideTransition(position: animation, child: child);
  }

  /// Slide in from right animation
  static Widget slideInFromRight({
    required Widget child,
    required AnimationController controller,
    Duration delay = Duration.zero,
  }) {
    final animation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              delay.inMilliseconds / controller.duration!.inMilliseconds,
              1.0,
              curve: Curves.easeOutCubic,
            ),
          ),
        );

    return SlideTransition(position: animation, child: child);
  }

  /// Fade in animation
  static Widget fadeIn({
    required Widget child,
    required AnimationController controller,
    Duration delay = Duration.zero,
  }) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay.inMilliseconds / controller.duration!.inMilliseconds,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    return FadeTransition(opacity: animation, child: child);
  }

  /// Scale in animation
  static Widget scaleIn({
    required Widget child,
    required AnimationController controller,
    Duration delay = Duration.zero,
  }) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay.inMilliseconds / controller.duration!.inMilliseconds,
          1.0,
          curve: Curves.elasticOut,
        ),
      ),
    );

    return ScaleTransition(scale: animation, child: child);
  }

  /// Bounce in animation
  static Widget bounceIn({
    required Widget child,
    required AnimationController controller,
    Duration delay = Duration.zero,
  }) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay.inMilliseconds / controller.duration!.inMilliseconds,
          1.0,
          curve: Curves.bounceOut,
        ),
      ),
    );

    return ScaleTransition(scale: animation, child: child);
  }

  /// Staggered list animation
  static Widget staggeredList({
    required List<Widget> children,
    required AnimationController controller,
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final delay = Duration(
          milliseconds: index * staggerDelay.inMilliseconds,
        );

        return slideInFromBottom(
          child: child,
          controller: controller,
          delay: delay,
        );
      }).toList(),
    );
  }

  /// Shimmer loading animation
  static Widget shimmerLoading({
    required Widget child,
    required bool isLoading,
    Color? baseColor,
    Color? highlightColor,
  }) {
    if (!isLoading) return child;

    return AnimatedContainer(
      duration: AppTheme.longAnimation,
      child: ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: [
              baseColor ?? Colors.grey.shade300,
              highlightColor ?? Colors.grey.shade100,
              baseColor ?? Colors.grey.shade300,
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: const Alignment(-1.0, -0.3),
            end: const Alignment(1.0, 0.3),
            tileMode: TileMode.clamp,
          ).createShader(bounds);
        },
        child: child,
      ),
    );
  }

  /// Pulse animation for buttons
  static Widget pulseButton({
    required Widget child,
    required bool shouldPulse,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    if (!shouldPulse) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.1),
      duration: duration,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }

  /// Rotation animation
  static Widget rotateIn({
    required Widget child,
    required AnimationController controller,
    Duration delay = Duration.zero,
  }) {
    final animation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay.inMilliseconds / controller.duration!.inMilliseconds,
          1.0,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    return RotationTransition(turns: animation, child: child);
  }

  /// Flip animation
  static Widget flipIn({
    required Widget child,
    required AnimationController controller,
    Duration delay = Duration.zero,
  }) {
    final animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay.inMilliseconds / controller.duration!.inMilliseconds,
          1.0,
          curve: Curves.easeInOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(animation.value * 3.14159),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Page transition animation
  static PageRouteBuilder createPageRoute({
    required Widget page,
    RouteSettings? settings,
    PageTransitionType type = PageTransitionType.slideFromRight,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case PageTransitionType.slideFromRight:
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          case PageTransitionType.slideFromBottom:
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          case PageTransitionType.fade:
            return FadeTransition(opacity: animation, child: child);
          case PageTransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
        }
      },
      transitionDuration: AppTheme.mediumAnimation,
    );
  }

  /// Hero animation wrapper
  static Widget heroWrapper({required String tag, required Widget child}) {
    return Hero(
      tag: tag,
      child: Material(color: Colors.transparent, child: child),
    );
  }

  /// Animated list item
  static Widget animatedListItem({
    required Widget child,
    required Animation<double> animation,
    int index = 0,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  /// Loading dots animation
  static Widget loadingDots({Color? color, double size = 8.0}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 200)),
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: (color ?? Colors.grey).withValues(alpha: value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

/// Enum for page transition types
enum PageTransitionType { slideFromRight, slideFromBottom, fade, scale }

/// Custom animated widget for smooth state transitions
class AnimatedStateWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedStateWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedStateWidget> createState() => _AnimatedStateWidgetState();
}

class _AnimatedStateWidgetState extends State<AnimatedStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_animation),
        child: widget.child,
      ),
    );
  }
}
