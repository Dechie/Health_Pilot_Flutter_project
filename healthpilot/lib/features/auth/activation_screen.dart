import 'package:flutter/material.dart';
import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/network/api_error.dart';
import 'package:healthpilot/core/navigation/app_navigation.dart';
import 'package:healthpilot/features/personal_info/initial_info_1.dart';
import 'package:provider/provider.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key, this.initialToken, this.registeredEmail});

  /// Token from an email deep link, if the app was opened via activation URL.
  final String? initialToken;

  /// If set, this screen was reached right after registration so we show a
  /// success confirmation.
  final String? registeredEmail;

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen>
    with WidgetsBindingObserver {
  final _tokenController = TextEditingController();
  bool _loading = false;
  bool _resending = false;
  bool _showManualToken = false;
  bool _returnedFromEmail = false;
  String? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final token = widget.initialToken?.trim();
    if (token != null && token.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _activate(token));
    }
    if (widget.registeredEmail != null) {
      _info = 'Account created! Check your inbox to activate it.';
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_loading) {
      setState(() {
        _returnedFromEmail = true;
        if (_error == null && _info == null) {
          _info = 'Did you activate your account? Tap "Already activated? Log in" to sign in.';
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tokenController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    final email = context.read<AuthState>().pendingActivationEmail;
    AppNavigation.replaceWithLoginAfterRegistration(
      context,
      email: email.isNotEmpty ? email : null,
    );
  }

  Future<void> _activate([String? tokenOverride]) async {
    final token = (tokenOverride ?? _tokenController.text).trim();
    if (token.isEmpty) {
      setState(() => _error = 'Enter the activation token from your email.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });
    try {
      await context.read<AuthState>().activate(token);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const InitialInfoFirst()),
        (route) => false,
      );
    } on ApiException catch (e) {
      setState(() {
        _loading = false;
        _error = e.userMessage;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Activation failed. Please try again.';
      });
    }
  }

  Future<void> _resendEmail() async {
    setState(() {
      _resending = true;
      _error = null;
      _info = null;
    });
    try {
      await context.read<AuthState>().resendActivationEmail();
      if (!mounted) return;
      setState(() {
        _resending = false;
        _info = 'Activation email sent. Open the link in your inbox.';
      });
    } on AuthException catch (e) {
      setState(() {
        _resending = false;
        _error = e.message;
      });
    } on ApiException catch (e) {
      setState(() {
        _resending = false;
        _error = e.userMessage;
      });
    } catch (_) {
      setState(() {
        _resending = false;
        _error = 'Could not resend email. Try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pendingEmail = context.watch<AuthState>().pendingActivationEmail;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToLogin();
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            return ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(w * 0.1, 0, w * 0.1, 24),
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: h * 0.06),
                      Text(
                        'Activate Account',
                        style: tt.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: h * 0.06),
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 56,
                        color: cs.primary,
                      ),
                      SizedBox(height: h * 0.03),
                      Text(
                        'Check your email',
                        style: tt.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: h * 0.015),
                          Text(
                            pendingEmail.isNotEmpty
                                ? 'We sent an activation link to $pendingEmail.\n\n'
                                    'Tap the link in that email to activate your account. '
                                    'After activating, come back here and tap '
                                    '"Already activated? Log in" to sign in.'
                                : 'We sent an activation link to your email.\n\n'
                                    'Tap the link to activate your account, then come '
                                    'back and tap "Already activated? Log in" to sign in.',
                            style:
                                tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                      if (_loading) ...[
                        SizedBox(height: h * 0.05),
                        const Center(child: CircularProgressIndicator()),
                        SizedBox(height: h * 0.02),
                        Text(
                          'Activating your account…',
                          textAlign: TextAlign.center,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                      if (_info != null) ...[
                        SizedBox(height: h * 0.03),
                        Text(
                          _info!,
                          textAlign: TextAlign.center,
                          style: tt.bodyMedium?.copyWith(color: cs.primary),
                        ),
                      ],
                      if (_error != null) ...[
                        SizedBox(height: h * 0.03),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: tt.bodyMedium?.copyWith(color: cs.error),
                        ),
                      ],
                      SizedBox(height: h * 0.04),
                      OutlinedButton.icon(
                        onPressed: _resending || _loading ? null : _resendEmail,
                        icon: _resending
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.primary,
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: const Text('Resend activation email'),
                      ),
                      SizedBox(height: h * 0.02),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _goToLogin,
                          icon: const Icon(Icons.login),
                          label: const Text(
                            'Already activated? Log in',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _returnedFromEmail
                                ? cs.primary
                                : cs.primaryContainer,
                            foregroundColor: _returnedFromEmail
                                ? cs.onPrimary
                                : cs.onPrimaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.02),
                      TextButton(
                        onPressed: () => setState(
                            () => _showManualToken = !_showManualToken),
                        child: Text(
                          _showManualToken
                              ? 'Hide manual token entry'
                              : 'Having trouble? Enter token manually',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (_showManualToken) ...[
                        SizedBox(height: h * 0.02),
                        TextField(
                          controller: _tokenController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _activate(),
                          decoration: InputDecoration(
                            hintText: 'Activation token',
                            prefixIcon: Icon(Icons.key_outlined,
                                color: cs.onSurfaceVariant),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: h * 0.03),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : () => _activate(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Activate with token',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ]),
              ],
            );
          }),
        ),
      ),
    );
  }
}
