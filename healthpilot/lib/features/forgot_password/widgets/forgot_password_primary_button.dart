import 'package:flutter/material.dart';

const _primaryBlue = Color.fromRGBO(110, 182, 255, 1);

/// Full-width primary CTA matching the forgot-password mocks.
class ForgotPasswordPrimaryButton extends StatelessWidget {
  const ForgotPasswordPrimaryButton({
    super.key,
    required this.screenWidth,
    required this.label,
    required this.onPressed,
  });

  final double screenWidth;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.16,
            ),
          ),
        ),
      ),
    );
  }
}
