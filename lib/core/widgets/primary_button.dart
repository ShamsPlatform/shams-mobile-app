import 'package:flutter/material.dart';

class CustomSolidButton extends StatefulWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomSolidButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<CustomSolidButton> createState() => _CustomSolidButtonState();
}

class _CustomSolidButtonState extends State<CustomSolidButton> {
  bool _isPressed = false;

  bool get _isInteractive => widget.onPressed != null && !widget.isLoading;

  @override
  void didUpdateWidget(covariant CustomSolidButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isInteractive && _isPressed) {
      _isPressed = false;
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_isInteractive && mounted) {
      setState(() => _isPressed = true);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (mounted && _isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (mounted && _isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: ElevatedButton(
          onPressed: _isInteractive ? widget.onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            disabledBackgroundColor: widget.isLoading
                ? colorScheme.secondary.withValues(alpha: 0.75)
                : null,
            disabledForegroundColor:
                widget.isLoading ? colorScheme.onSecondary : null,
            minimumSize: const Size(double.infinity, 52),
          ),
          child: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onSecondary,
                  ),
                )
              : Text(widget.title),
        ),
      ),
    );
  }
}
