import 'package:flutter/material.dart';
import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/data/constants.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.title,
    required this.onBack,
    this.onTranslate,
  });

  final double screenWidth;
  final double screenHeight;
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onTranslate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final iconSize = screenWidth * 0.046;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.04,
        screenHeight * 0.012,
        screenWidth * 0.04,
        screenHeight * 0.016,
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
            ),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              color: cs.primary,
              iconSize: iconSize,
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: tt.titleLarge?.copyWith(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w700,
                  ) ??
                  TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            child: onTranslate == null
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: onTranslate,
                    icon: SafeSvgAsset(
                      translateIcon,
                      width: screenWidth * 0.06,
                      height: screenWidth * 0.06,
                    ),
                    padding: EdgeInsets.zero,
                  ),
          ),
        ],
      ),
    );
  }
}
