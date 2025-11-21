import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final VoidCallback onTap;
  final Color? foreground;
  final bool outlined;

  const GradientButton({
    super.key,
    required this.text,
    required this.gradient,
    required this.onTap,
    this.foreground,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Text(
        text,
        style: TextStyle(
          color: outlined ? (foreground ?? Colors.green.shade900) : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: foreground ?? Colors.green.shade900,
            shadowColor: Colors.transparent,
            side: BorderSide(color: (foreground ?? Colors.green.shade700)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onTap,
          child: child,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.green.shade200.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}