import 'package:flutter/material.dart';

import '../auth_email_utils.dart';
import '../data/auth_api.dart';

/// Full-screen forgot password — matches Login gradient + card style.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFFA855F7), Color(0xFFEC4899)],
  );

  late final TextEditingController _emailCtrl;
  bool _loading = false;
  String? _inlineMessage;
  bool _isError = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || _completed) return;

    final email = AuthEmailUtils.normalize(_emailCtrl.text);
    if (!AuthEmailUtils.isValidYeditepeEmail(email)) {
      setState(() {
        _inlineMessage = 'Use your full @std.yeditepe.edu.tr address.';
        _isError = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _inlineMessage = null;
      _isError = false;
    });

    final result = await AuthApi().requestPasswordReset(email: email);
    if (!mounted) return;

    final isSuccess = result.status == PasswordResetStatus.submitted;
    setState(() {
      _loading = false;
      _inlineMessage = result.message;
      _isError = !isSuccess;
      _completed = isSuccess;
    });
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = _inputBorder();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _loading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.lock_reset_rounded, size: 44, color: Color(0xFF7C3AED)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reset password',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'We will email reset instructions to your university inbox',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.35, color: Colors.white.withValues(alpha: 0.92)),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Forgot your password?',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _completed
                            ? 'If this email is registered, you will receive a link shortly.'
                            : 'Enter the same address you use to sign in. Reset mail works when the backend enables it.',
                        style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'University Email',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailCtrl,
                        enabled: !_loading && !_completed,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          hintText: 'name@std.yeditepe.edu.tr',
                          prefixIcon: Icon(Icons.mail_outline_rounded, color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.white,
                          border: inputBorder,
                          enabledBorder: inputBorder,
                          focusedBorder: inputBorder.copyWith(
                            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        ),
                      ),
                      if (_inlineMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isError ? const Color(0xFFFECACA) : const Color(0xFF86EFAC),
                            ),
                          ),
                          child: Text(
                            _inlineMessage!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                              color: _isError ? const Color(0xFFDC2626) : const Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF9333EA)]),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: _loading
                                  ? null
                                  : _completed
                                      ? () => Navigator.of(context).pop()
                                      : _submit,
                              child: Center(
                                child: _loading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                      )
                                    : Text(
                                        _completed ? 'Back to login' : 'Send reset link',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
