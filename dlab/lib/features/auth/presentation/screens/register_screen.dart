import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../provider/auth_providers.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  static const routePath = '/register';

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(authStateProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (prev, next) {
      next.whenOrNull(
        error: (err, _) {
          final msg = err is Exception ? err.toString() : 'Registration failed';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        },
      );
    });

    final isLoading = state.isLoading;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    'Create an account',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Let’s create your account.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      height: 1.4,
                      color: Color(0xFF808080),
                    ),
                  ),

                  const SizedBox(height: 30),

                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    obscure: false,
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) return 'Name is required';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email address',
                    obscure: false,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      final value = (v ?? '').trim();

                      if (value.isEmpty) {
                        return 'Email is required';
                      }

                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );

                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter valid email address';
                      }

                      return null;
                    },

                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    obscure: true,
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      if ((v ?? '').isEmpty) return 'Password is required';
                      if ((v ?? '').length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'By signing up you agree to our Terms, Privacy Policy, and Cookie Use',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4965),
                        disabledBackgroundColor: const Color(0xFFCCCCCC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Create an Account',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: const [
                      Expanded(child: Divider(color: Color(0xFFE6E6E6))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Or',
                          style: TextStyle(fontSize: 14, color: Color(0xFF808080)),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFFE6E6E6))),
                    ],
                  ),

                  const SizedBox(height: 25),

                  SocialButton(
                    text: 'Continue with Google',
                    isFacebook: false,
                    onPressed: () {
                      // TODO: integrate Google sign-in
                    },
                  ),

                  const SizedBox(height: 15),

                  SocialButton(
                    text: 'Continue with Facebook',
                    isFacebook: true,
                    onPressed: () {
                      // TODO: integrate Facebook sign-in
                    },
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: GestureDetector(
                      onTap: () => context.go(LoginScreen.routePath),
                      child: const Text(
                        'Already have an account? Log In',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF808080),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.obscure,
    required this.controller,
    this.textInputAction,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isHidden = true;
  String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Label
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
            ),

            const SizedBox(height: 4),

            /// Input Field
            TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: widget.obscure ? isHidden : false,
              onFieldSubmitted: widget.onFieldSubmitted,
              autovalidateMode: AutovalidateMode.onUserInteraction,

              onChanged: (value) {
                final result = widget.validator?.call(value);
                if (result != errorText) {
                  setState(() {
                    errorText = result;
                  });
                }
              },

              // 🔥 IMPORTANT: Always return null so default error doesn't show
              validator: (value) {
                return null;
              },

              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                height: 1.4,
                color: Color(0xFF1A1A1A),
              ),

              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),

                // 🔥 Hide default error completely
                errorStyle: const TextStyle(
                  height: 0,
                  fontSize: 0,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: errorText != null
                        ? const Color(0xFFED1010)
                        : const Color(0xFFE6E6E6),
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: errorText != null
                        ? const Color(0xFFED1010)
                        : const Color(0xFFE6E6E6),
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: errorText != null
                        ? const Color(0xFFED1010)
                        : const Color(0xFF1B4965),
                    width: 1.2,
                  ),
                ),

                suffixIcon: errorText != null
                    ? const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.error_outline,
                          color: Color(0xFFED1010),
                          size: 22,
                        ),
                      )
                    : widget.obscure
                        ? IconButton(
                            icon: Icon(
                              isHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                isHidden = !isHidden;
                              });
                            },
                          )
                        : null,
              ),
            ),



            /// Custom Error Text (Figma style)
            if (hasError) ...[
              const SizedBox(height: 4),
              Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: Color(0xFFED1010),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}


class SocialButton extends StatelessWidget {
  final String text;
  final bool isFacebook;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.text,
    required this.isFacebook,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFacebook ? const Color(0xFF1877F2) : Colors.white,
          foregroundColor:
              isFacebook ? Colors.white : Colors.black,
          side: isFacebook
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFCCCCCC)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isFacebook)
              const Icon(Icons.facebook, size: 22)
            else
              SvgPicture.asset(
                'assets/icons/google_logo.svg',
                height: 24,
                width: 24,
              ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
