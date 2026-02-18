import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class BigRedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool autofocus;
  const BigRedButton({
    Key? key,
    required this.onPressed,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<BigRedButton> createState() => _BigRedButtonState();
}

class _BigRedButtonState extends State<BigRedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: ScaleTransition(
        scale: Tween(begin: 0.9, end: 1.1).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        )),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ]
                : null,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(48),
              backgroundColor: Colors.redAccent,
              elevation: _isFocused ? 20 : 8,
            ),
            onPressed: () {
              HapticFeedback.heavyImpact();
              widget.onPressed();
            },
            child: const Icon(Icons.warning, size: 48, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
