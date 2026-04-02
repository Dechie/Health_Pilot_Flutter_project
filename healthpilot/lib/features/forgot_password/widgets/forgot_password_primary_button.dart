import 'package:flutter/material.dart';

/// Full-width primary CTA; colors come from [ThemeData.filledButtonTheme].
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }
}
