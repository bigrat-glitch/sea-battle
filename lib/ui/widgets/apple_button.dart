import 'package:flutter/material.dart';
import '../../core/constants.dart';

class AppleButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const AppleButton({super.key, required this.text, required this.onPressed, this.isPrimary = true});

  @override
  State<AppleButton> createState() => _AppleButtonState();
}

class _AppleButtonState extends State<AppleButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? (isHovered ? AppColors.accent.withOpacity(0.8) : AppColors.accent)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: widget.isPrimary ? Colors.transparent : Colors.white24),
            boxShadow: isHovered && widget.isPrimary ? [
              BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)
            ] : [],
          ),
          child: Text(
            widget.text.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textMain,
              letterSpacing: 3,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}