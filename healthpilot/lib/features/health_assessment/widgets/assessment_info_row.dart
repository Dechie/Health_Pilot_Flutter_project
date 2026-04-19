import 'package:flutter/material.dart';

class AssessmentInfoRow extends StatelessWidget {
  const AssessmentInfoRow({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: t.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: c.onSurface,
                letterSpacing: -0.165,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: c.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: c.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

