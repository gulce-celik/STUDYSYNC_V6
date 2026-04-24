import 'dart:async' show unawaited;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_scope.dart';
import '../../../core/platform/keyboard_host.dart';
import '../data/auth_api.dart';
import 'register_screen.dart';

/// Matches Figma/React prototype: gradient hero, rounded card, Yeditepe email rule.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _loading = false;
  String? _emailError;

  static final _yeditepeEmail = RegExp(r'^[a-zA-Z0-9._%+-]+@std\.yeditepe\.edu\.tr$');

  /// Common typo: trailing dot after domain (e.g. `...edu.`).
  String _normalizeEmail(String raw) {
    var s = raw.trim();
    while (s.endsWith('.')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  void _toast(String message) { // snackbar is used to show a message to the user.
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _welcomeWithName(Map<String, dynamic>? user) {
    if (user == null) return 'Welcome!';
    final name = user['name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return 'Welcome, $name!';
    }
    final nick = user['nickname']?.toString().trim();
    if (nick != null && nick.isNotEmpty) {
      return 'Welcome, $nick!';
    }
    return 'Welcome!';
  }

  Future<void> _tryShowSoftKeyboard(Duration delay) async {
    await Future<void>.delayed(delay);
    if (!mounted || !_emailFocus.hasFocus) return;
    await KeyboardHost.showSoftIfAndroid();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _normalizeEmail(_emailCtrl.text);
    final password = _passwordCtrl.text;

    setState(() => _emailError = null);

    if (!_yeditepeEmail.hasMatch(email)) {
      setState(() {
        _emailError = 'Use full address: ...@std.yeditepe.edu.tr (no trailing dot)';
      });
      _toast('Yeditepe email required: @std.yeditepe.edu.tr');
      return;
    }
    if (password.isEmpty) {
      _toast('Please enter your password.');
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await AuthApi().login(email: email, password: password); //API call to logiN
      if (!mounted) return;
      AuthScope.of(context).establishSession(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        user: result.user,
      );
      _toast(_welcomeWithName(result.user));
    } on DioException catch (e) {
      if (!mounted) return; //mounted is used to check if the widget is still in the tree.
      _toast(_loginErrorMessage(e));
    } catch (e) {
      if (!mounted) return;
      _toast('Login failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _loginErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return 'Cannot reach server. Run Spring Boot on port 8080 '
            '(emulator target: 10.0.2.2:8080).';
      default:
        break;
    }
    final status = e.response?.statusCode;
    final rawMessage = e.response?.data?.toString().toLowerCase() ?? '';
    if (rawMessage.contains('invalid email or password')) {
      return 'Invalid email or password. If you are new, please create an account first.';
    }
    if (status != null) {
      if (status == 500) {
        return 'Invalid email or password. If you are new, please create an account first.';
      }
      return 'Server responded with ($status). Please check your credentials.';
    }
    return e.message ?? 'Network error';
  }

  @override
  Widget build(BuildContext context) { // build is used to build the widget.
    const gradient = LinearGradient( // gradient is used to add a gradient to the background.
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF3B82F6), // blue 
        Color(0xFFA855F7), // purple 
        Color(0xFFEC4899), // pink 
      ],
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.smartphone_rounded, size: 48, color: Color(0xFF2563EB)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'StudySync',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your University Study Hub',
                  style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.92)),
                ),
                const SizedBox(height: 28),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Login with your university email',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 22),
                      Text('University Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
                      const SizedBox(height: 8),
                      // `emailAddress` IME + AutofillGroup bazen emülatörde (özellikle PC klavyesi açıkken)
                      // yumuşak klavye ve tuş yönlendirmesini bozar; düz metin + sınırsız satır yok.
                      TextField(
                        focusNode: _emailFocus,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.none,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                        onTap: () {
                          unawaited(_tryShowSoftKeyboard(const Duration(milliseconds: 40)));
                        },
                        onChanged: (_) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_passwordFocus);
                        },
                        decoration: InputDecoration(
                          hintText: 'name@std.yeditepe.edu.tr',
                          errorText: _emailError,
                          prefixIcon: Icon(Icons.mail_outline_rounded, color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.white,
                          border: inputBorder,
                          enabledBorder: inputBorder,
                          focusedBorder: inputBorder.copyWith(
                            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                          ),
                          errorBorder: inputBorder.copyWith(
                            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
                          ),
                          focusedErrorBorder: inputBorder.copyWith(
                            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
                      const SizedBox(height: 8),
                      TextField(
                        focusNode: _passwordFocus,
                        controller: _passwordCtrl,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400),
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
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
                            ),
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
                              onTap: _loading ? null : _submit,
                              // Full-width hit target (was only ~center row before).
                              child: SizedBox.expand(
                                child: Center(
                                  child: _loading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                        )
                                      : const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.login_rounded, color: Colors.white, size: 22),
                                            SizedBox(width: 8),
                                            Text(
                                              'Login',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            _toast('Password reset flow — coming soon');
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Not registered yet? ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF9333EA)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    '🎓 University students only • Verified .edu emails',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, height: 1.35, color: Colors.white.withValues(alpha: 0.95)),
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
