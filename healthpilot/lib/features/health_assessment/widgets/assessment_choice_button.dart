import 'package:flutter/material.dart';

class AssessmentChoiceButton extends StatelessWidget {
  const AssessmentChoiceButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return SizedBox(
      height: 40,
      width: 180,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: c.primary, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          foregroundColor: c.onSurface,
          textStyle: t.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: c.onSurface,
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

