import 'package:flutter/material.dart';
import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/navigation/app_navigation.dart';
import 'package:healthpilot/core/network/api_error.dart';
import 'package:provider/provider.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _tokenController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _error = 'Enter the activation token from your email.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthState>().activate(token);
      if (!mounted) return;
      AppNavigation.replaceWithHome(context);
    } on ServerError catch (e) {
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } on NetworkError {
      setState(() {
        _loading = false;
        _error = 'No internet connection. Please try again.';
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Activation failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: w * 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: h * 0.06),
                Row(
                  children: [
                    Container(
                      width: w * 0.1,
                      height: w * 0.1,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(w * 0.05),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back),
                        color: cs.primary,
                        iconSize: w * 0.05,
                      ),
                    ),
                    SizedBox(width: w * 0.04),
                    Text(
                      'Activate Account',
                      style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.06),
                Text(
                  'Check your email',
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: h * 0.015),
                Text(
                  'We sent an activation token to your email address. Paste it below to complete your registration.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: h * 0.05),
                TextField(
                  controller: _tokenController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _activate(),
                  decoration: InputDecoration(
                    hintText: 'Activation token',
                    errorText: _error,
                    prefixIcon: Icon(Icons.key_outlined, color: cs.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: cs.primary, width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.04),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _activate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _loading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onPrimary,
                            ),
                          )
                        : const Text(
                            'Activate',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: h * 0.03),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(
                    'Return to login',
                    style: TextStyle(color: cs.primary),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
