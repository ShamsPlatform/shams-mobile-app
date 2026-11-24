import 'package:flutter/material.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';

const AnimationStyle _defaultSheetAnimationStyle = AnimationStyle(
  duration: Duration(milliseconds: 280),
  reverseDuration: Duration(milliseconds: 220),
  curve: Curves.easeOutCubic,
  reverseCurve: Curves.easeInCubic,
);

/// Displays a modal bottom sheet with consistent slide and fade transitions.
Future<T?> showShamsModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  String? barrierLabel,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle,
  bool useSafeArea = false,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  AnimationStyle? sheetAnimationStyle,
  bool? requestFocus,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: (sheetContext) => _ShamsModalFadeWrapper(
      child: Builder(builder: builder),
    ),
    backgroundColor: backgroundColor,
    barrierLabel: barrierLabel,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    barrierColor: barrierColor,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    sheetAnimationStyle: sheetAnimationStyle ?? _defaultSheetAnimationStyle,
    requestFocus: requestFocus,
  );
}

/// Displays a dialog with smooth fade, slide, and scale entry/exit transitions.
Future<T?> showShamsDialog<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  bool? requestFocus,
  Duration transitionDuration = const Duration(milliseconds: 240),
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themes = InheritedTheme.capture(
    from: context,
    to: navigator.context,
  );
  final textDirection = Directionality.of(context);
  final effectiveBarrierLabel =
      barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel;
  final effectiveBarrierColor = barrierColor ??
      Theme.of(context).dialogTheme.barrierColor ??
      Colors.black54;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: effectiveBarrierLabel,
    barrierColor: effectiveBarrierColor,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    requestFocus: requestFocus,
    transitionDuration: transitionDuration,
    pageBuilder: (routeContext, animation, secondaryAnimation) {
      Widget dialog = Builder(builder: builder);
      dialog = themes.wrap(dialog);
      dialog = Directionality(
        textDirection: textDirection,
        child: dialog,
      );
      if (useSafeArea) {
        dialog = SafeArea(child: dialog);
      }
      return Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: dialog,
      );
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(ctx)) {
        return child;
      }
      return _ShamsDialogTransition(
        animation: animation,
        child: child,
      );
    },
  );
}

class _ShamsModalFadeWrapper extends StatefulWidget {
  const _ShamsModalFadeWrapper({required this.child});

  final Widget child;

  @override
  State<_ShamsModalFadeWrapper> createState() => _ShamsModalFadeWrapperState();
}

class _ShamsModalFadeWrapperState extends State<_ShamsModalFadeWrapper> {
  Animation<double>? _parentAnimation;
  CurvedAnimation? _curvedAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final routeAnimation = ModalRoute.of(context)?.animation;

    if (disableAnimations || routeAnimation == null) {
      _curvedAnimation?.dispose();
      _curvedAnimation = null;
      _parentAnimation = null;
      return;
    }

    if (_parentAnimation != routeAnimation) {
      _curvedAnimation?.dispose();
      _parentAnimation = routeAnimation;
      _curvedAnimation = CurvedAnimation(
        parent: routeAnimation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
    }
  }

  @override
  void dispose() {
    _curvedAnimation?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = _curvedAnimation;
    if (animation == null) {
      return widget.child;
    }
    return FadeTransition(
      opacity: animation,
      child: widget.child,
    );
  }
}

class _ShamsDialogTransition extends StatefulWidget {
  const _ShamsDialogTransition({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  State<_ShamsDialogTransition> createState() => _ShamsDialogTransitionState();
}

class _ShamsDialogTransitionState extends State<_ShamsDialogTransition> {
  late CurvedAnimation _curvedAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  void _bindAnimation() {
    _curvedAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(_curvedAnimation);
    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(_curvedAnimation);
  }

  @override
  void initState() {
    super.initState();
    _bindAnimation();
  }

  @override
  void didUpdateWidget(covariant _ShamsDialogTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _curvedAnimation.dispose();
      _bindAnimation();
    }
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curvedAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Standard pill drag handle used at the top of Shams modal bottom sheets.
class ShamsSheetHandle extends StatelessWidget {
  const ShamsSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: ext.handleBar,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

/// Interactive card tile for technical support contact channels in bottom sheets.
class ShamsSupportOptionTile extends StatelessWidget {
  const ShamsSupportOptionTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.subtitleTextDirection,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final TextDirection? subtitleTextDirection;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: ext.inputFill,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ext.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      textDirection: subtitleTextDirection,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: ext.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
