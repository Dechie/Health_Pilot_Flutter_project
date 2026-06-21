import 'package:flutter/material.dart';

/// Drives the two-step forgot-password flow (email → check inbox), calling the
/// backend's password-reset request endpoint via [onRequestReset].
class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController({required this.onRequestReset})
      : emailController = TextEditingController();

  /// Sends the reset email; throws on failure.
  final Future<void> Function(String email) onRequestReset;

  final TextEditingController emailController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// 0 = enter email, 1 = check email confirmation.
  int step = 0;
  bool isSubmitting = false;
  String? errorMessage;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String? validateEmailField(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your email';
    if (!_emailPattern.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  Future<void> submitEmail() async {
    if (isSubmitting) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    formKey.currentState!.save();
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      await onRequestReset(emailController.text.trim());
      step = 1;
    } catch (_) {
      errorMessage = 'Could not send the reset email. Please try again.';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void backFromConfirmation() {
    if (step > 0) {
      step = 0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
