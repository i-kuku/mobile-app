import 'package:flutter/material.dart';

enum LoadingButtonType { elevated, outlined, text }

class LoadingButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final LoadingButtonType type;
  final bool autofocus;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.type = LoadingButtonType.elevated,
    this.autofocus = false,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _loading = false;

  Future<void> _handlePressed() async {
    if (_loading || widget.onPressed == null) return;
    setState(() => _loading = true);
    try {
      await widget.onPressed?.call();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          )
        : widget.child;

    switch (widget.type) {
      case LoadingButtonType.outlined:
        return OutlinedButton(
          onPressed: widget.onPressed == null ? null : _handlePressed,
          style: widget.style,
          autofocus: widget.autofocus,
          child: child,
        );
      case LoadingButtonType.text:
        return TextButton(
          onPressed: widget.onPressed == null ? null : _handlePressed,
          style: widget.style,
          autofocus: widget.autofocus,
          child: child,
        );
      case LoadingButtonType.elevated:
      default:
        return ElevatedButton(
          onPressed: widget.onPressed == null ? null : _handlePressed,
          style: widget.style,
          autofocus: widget.autofocus,
          child: child,
        );
    }
  }
}
