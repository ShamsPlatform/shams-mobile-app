import 'package:flutter/material.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';

/// Provides a sweeping shimmer animation that adapts cleanly to light and dark themes.
class ShamsShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShamsShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<ShamsShimmer> createState() => _ShamsShimmerState();
}

class _ShamsShimmerState extends State<ShamsShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = ext.chipBackground;
    final highlightColor = isDark
        ? ext.borderLight
        : Color.lerp(ext.chipBackground, ext.cardSurface, 0.72)!;
    final textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final slide = (_controller.value * 2.0) - 0.5;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: AlignmentDirectional(-1.0 + slide, -0.2),
              end: AlignmentDirectional(0.4 + slide, 0.2),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.1, 0.5, 0.9],
              tileMode: TileMode.clamp,
            ).createShader(bounds, textDirection: textDirection);
          },
          child: child,
        );
      },
    );
  }
}

/// Neutral skeleton bone container used inside shimmer loading placeholders.
class ShamsSkeletonBone extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final BoxShape shape;

  const ShamsSkeletonBone({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ext.chipBackground,
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : borderRadius,
      ),
    );
  }
}

