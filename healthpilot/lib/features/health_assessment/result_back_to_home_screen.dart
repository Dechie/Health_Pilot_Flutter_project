import 'package:flutter/material.dart';
import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/asset_paths.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_flow_screen.dart';

class ResultBackToHomeScreen extends StatelessWidget {
  const ResultBackToHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Back To Home')),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SafeSvgAsset(
                    AssetPaths.backToHomeIllustration,
                    width: 320,
                    height: 220,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Wanna vent a little?', style: t.titleSmall),
              const SizedBox(height: 6),
              Text(
                'Speaking about what you are going through can help the most in a safe space.',
                style: t.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: const Text('Go to Community'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HealthAssessmentFlowScreen(),
                        ),
                      );
                    });
                  },
                  child: const Text('Check another symptom'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

