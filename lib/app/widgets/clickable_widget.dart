import 'package:flutter/material.dart';

class ClickableWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const ClickableWidget({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: child, // Render any widget passed as child
    );
  }
}
