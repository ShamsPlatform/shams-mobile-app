import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatefulWidget {
  final String title;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? foregroundColor;
  final Color? borderColor;

  const CustomOutlinedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon,
    this.foregroundColor,
    this.borderColor,
  });

  @override
  State<CustomOutlinedButton> createState() => _CustomOutlinedButtonState();
}

class _CustomOutlinedButtonState extends State<CustomOutlinedButton> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    if (widget.onPressed != null && mounted) {
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
    final effectiveFg = widget.foregroundColor ?? colorScheme.primary;
    final effectiveBorder = widget.borderColor ?? colorScheme.primary;

    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: effectiveFg,
      side: BorderSide(color: effectiveBorder, width: 1.5),
    );

    final Widget buttonChild;
    if (widget.icon != null) {
      buttonChild = OutlinedButton.icon(
        onPressed: widget.onPressed,
        icon: widget.icon!,
        label: Text(widget.title),
        style: buttonStyle,
      );
    } else {
      buttonChild = OutlinedButton(
        onPressed: widget.onPressed,
        style: buttonStyle,
        child: Text(widget.title),
      );
    }

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: buttonChild,
      ),
    );
  }
}
