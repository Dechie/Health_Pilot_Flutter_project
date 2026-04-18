import 'package:flutter/material.dart';

/// Drives the two-step forgot-password flow (email → check inbox).
class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController() : emailController = TextEditingController();

  final TextEditingController emailController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// 0 = enter email, 1 = check email confirmation.
  int step = 0;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String? validateEmailField(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your email';
    if (!_emailPattern.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  void submitEmail() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    formKey.currentState!.save();
    step = 1;
    notifyListeners();
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
