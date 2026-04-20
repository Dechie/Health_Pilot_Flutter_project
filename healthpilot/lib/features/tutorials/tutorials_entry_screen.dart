import 'package:flutter/material.dart';

/// Entry shell for the tutorials feature.
///
/// Branch A adds this module boundary; Branch G (`feat/tutorials`) will replace
/// the body with real tutorial list/cards and wire navigation from Home.
class TutorialsEntryScreen extends StatelessWidget {
  const TutorialsEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorials'),
      ),
      body: Center(
        child: Text(
          'Coming soon',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
