import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/data/constants.dart';

const _primaryBlue = Color.fromRGBO(110, 182, 255, 1);
const _backTint = Color.fromRGBO(219, 237, 255, 1);

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
              color: _backTint,
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
            ),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              color: _primaryBlue,
              iconSize: iconSize,
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w700,
                fontFamily: 'PlusJakartaSans',
                color: const Color.fromRGBO(42, 42, 42, 1),
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
                    icon: SvgPicture.asset(
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
