import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/forgot_password/forgot_password_controller.dart';
import 'package:healthpilot/features/forgot_password/widgets/forgot_password_header.dart';
import 'package:healthpilot/features/forgot_password/widgets/forgot_password_primary_button.dart';
import 'package:healthpilot/features/onboarding/language_translation.dart';
import 'package:provider/provider.dart';

const _muted = Color.fromRGBO(42, 42, 42, 0.5);

/// Entry point for the forgot-password flow. Pushes a single route; step 2 stays
/// under the same [ChangeNotifierProvider] scope.
class ForgotPasswordScreen extends StatelessWidget {
  static const routeName = '/Forgot Password';

  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordController(),
      child: const _ForgotPasswordScaffold(),
    );
  }
}

class _ForgotPasswordScaffold extends StatelessWidget {
  const _ForgotPasswordScaffold();

  void _openLanguage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const LanguageTranslation(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgotPasswordController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: controller.step == 0
                      ? _EmailStep(
                          key: const ValueKey('email'),
                          screenWidth: w,
                          screenHeight: h,
                          onTranslate: () => _openLanguage(context),
                        )
                      : _CheckEmailStep(
                          key: const ValueKey('check'),
                          screenWidth: w,
                          screenHeight: h,
                          onTranslate: () => _openLanguage(context),
                        ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _EmailStep extends StatelessWidget {
  const _EmailStep({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTranslate,
  });

  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTranslate;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ForgotPasswordController>();
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ForgotPasswordHeader(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              title: 'Forgot Password',
              onBack: () => Navigator.of(context).maybePop(),
              onTranslate: onTranslate,
            ),
            SizedBox(
              height: screenHeight * 0.36,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: SvgPicture.asset(
                  forgotPasswordIllustration,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: const Text(
                "We'll send you an email with instructions on how to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                  letterSpacing: -0.17,
                  color: _muted,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.028),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: controller.validateEmailField,
                onFieldSubmitted: (_) => controller.submitEmail(),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: const TextStyle(
                    color: _muted,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.165,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.02),
                    child: const Icon(Icons.email_outlined, color: _muted),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(110, 182, 255, 1),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.06),
            ForgotPasswordPrimaryButton(
              screenWidth: screenWidth,
              label: 'Next',
              onPressed: () => context.read<ForgotPasswordController>().submitEmail(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckEmailStep extends StatelessWidget {
  const _CheckEmailStep({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTranslate,
  });

  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTranslate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ForgotPasswordHeader(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            title: 'Forgot Password',
            onBack: () =>
                context.read<ForgotPasswordController>().backFromConfirmation(),
            onTranslate: onTranslate,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.02,
            ),
            child: SizedBox(
              height: screenHeight * 0.32,
              child: SvgPicture.asset(
                forgotPasswordCheckEmailIllustration,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.165,
              color: Color.fromRGBO(42, 42, 42, 1),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              screenWidth * 0.1,
              screenHeight * 0.02,
              screenWidth * 0.1,
              screenHeight * 0.02,
            ),
            child: const Text(
              "We've emailed you instructions on how to change your password. Please check your inbox.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.25,
                letterSpacing: -0.165,
                color: _muted,
              ),
            ),
          ),
          const Text(
            "Didn't receive an email?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.165,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
          ForgotPasswordPrimaryButton(
            screenWidth: screenWidth,
            label: 'Return to login',
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(height: screenHeight * 0.04),
        ],
      ),
    );
  }
}
