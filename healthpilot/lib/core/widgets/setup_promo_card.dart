import 'package:flutter/material.dart';

/// Copy reused for the food & nutrition [SetupPromoCard] on multiple flows.
abstract final class SetupPromoCardCopy {
  static const foodNutritionTitle = 'Set up food and nutrition tracking';
  static const foodNutritionDescription =
      'Choose how often you get reports, optional meal-time reminders on this device, and diets you follow. '
      'This screen does not require a subscription.';
}

/// Shared “Set up your …” promo card (profile onboarding + hub screens).
///
/// Matches the gradient and typography used on [PersonalInformationScreen].
/// Use [expandVertically] for embedded full-width rows where a fixed height
/// would clip longer copy.
class SetupPromoCard extends StatelessWidget {
  const SetupPromoCard({
    super.key,
    required this.screenWidth,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 167,
    this.expandVertically = true,
    this.margin = const EdgeInsets.only(top: 30, left: 7, right: 8),
    this.buttonBorderRadius = 5,
  });

  final double screenWidth;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;
  final IconData? icon;

  /// When null, uses [screenWidth] * 0.9 (onboarding default).
  final double? width;

  /// Fixed height when [expandVertically] is false.
  final double height;

  /// When true, omits fixed height and [Spacer] so the card grows with content.
  final bool expandVertically;

  final EdgeInsetsGeometry margin;
  final double buttonBorderRadius;

  static const _gradient = LinearGradient(
    colors: [
      Color.fromRGBO(110, 182, 255, 0.3),
      Color.fromRGBO(110, 182, 255, 0.26),
      Color.fromRGBO(110, 182, 255, 0.08),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = width ?? screenWidth * 0.9;

    final titleRow = Padding(
      padding: const EdgeInsets.only(top: 13, left: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: icon != null
                ? Icon(icon, color: cs.onSurface)
                : const SizedBox(width: 24),
          ),
        ],
      ),
    );

    final descriptionBlock = Padding(
      padding: const EdgeInsets.only(top: 13, left: 9, right: 9),
      child: Text(
        description,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: cs.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );

    final button = Container(
      width: screenWidth * 0.3,
      height: screenWidth * 0.08,
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: cs.onPrimary,
          ),
        ),
      ),
    );

    final columnChildren = <Widget>[
      titleRow,
      descriptionBlock,
      if (expandVertically)
        SizedBox(height: screenWidth * 0.04)
      else
        const Spacer(),
      button,
    ];

    return Padding(
      padding: margin,
      child: Container(
        width: w,
        height: expandVertically ? null : height,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          gradient: _gradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: expandVertically ? MainAxisSize.min : MainAxisSize.max,
          children: columnChildren,
        ),
      ),
    );
  }
}
