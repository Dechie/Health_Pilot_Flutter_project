import 'package:flutter/material.dart';
import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/asset_paths.dart';
import 'package:healthpilot/features/chat/general_chat_screen.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_flow_screen.dart';

class ResultBackToHomeScreen extends StatelessWidget {
  const ResultBackToHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

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
                    final nav = Navigator.of(context, rootNavigator: true);
                    nav.popUntil((route) => route.isFirst);
                    nav.push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const GeneralChatScreen(showBackButton: true),
                      ),
                    );
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
                    final nav = Navigator.of(context, rootNavigator: true);
                    // New session: remove result + underlying flow (summary used
                    // pushReplacement so the flow route stayed under this screen).
                    final sessionKey = Object();
                    nav.pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => HealthAssessmentFlowScreen(
                          key: ValueKey(sessionKey),
                        ),
                      ),
                      (route) => route.isFirst,
                    );
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

