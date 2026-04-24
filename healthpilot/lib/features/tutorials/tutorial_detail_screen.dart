import 'package:flutter/material.dart';

/// Detail view for a single tutorial (placeholder content until CMS/Figma copy exists).
class TutorialDetailScreen extends StatelessWidget {
  const TutorialDetailScreen({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ),
      ),
    );
  }
}
