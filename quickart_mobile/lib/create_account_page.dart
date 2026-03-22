import 'package:flutter/material.dart';

import 'home_page.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  static const Color _orange = Color(0xFFE8720C);
  static const Color _black = Color(0xFF1A1A1A);
  static const Color _bgColor = Color(0xFFF0EDE6);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _inputBg = Color(0xFFF5F4F2);
  static const Color _hintColor = Color(0xFFB0AAA0);
  static const Color _borderColor = Color(0xFFE5E2DC);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleCreateAccount() async {
    final fields = [
      _nameController,
      _emailController,
      _phoneController,
      _passwordController,
      _confirmPasswordController,
    ];
    if (fields.any((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 44),

                // ── Logo (same as login page) ─────────────────────────────
                _QuickArtLogo(),

                const SizedBox(height: 8),

                // ── Tagline ───────────────────────────────────────────────
                Text(
                  'SMART. FAST. RELIABLE.',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.8,
                    color: _black.withOpacity(0.55),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Page heading ──────────────────────────────────────────
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: _black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create your QuickCart account',
                  style: TextStyle(
                    fontSize: 14,
                    color: _black.withOpacity(0.45),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Card ──────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      _LabeledInputField(
                        label: 'Full Name',
                        controller: _nameController,
                        hint: 'Enter your name',
                        prefixIcon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                        inputBg: _inputBg,
                        borderColor: _borderColor,
                        hintColor: _hintColor,
                        iconColor: _hintColor,
                      ),

                      const SizedBox(height: 16),

                      // Email
                      _LabeledInputField(
                        label: 'Email',
                        controller: _emailController,
                        hint: 'Enter email',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        inputBg: _inputBg,
                        borderColor: _borderColor,
                        hintColor: _hintColor,
                        iconColor: _hintColor,
                      ),

                      const SizedBox(height: 16),

                      // Phone Number
                      _LabeledInputField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        hint: 'Enter phone number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputBg: _inputBg,
                        borderColor: _borderColor,
                        hintColor: _hintColor,
                        iconColor: _hintColor,
                      ),

                      const SizedBox(height: 16),

                      // Password
                      _LabeledInputField(
                        label: 'Password',
                        controller: _passwordController,
                        hint: 'Enter password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        inputBg: _inputBg,
                        borderColor: _borderColor,
                        hintColor: _hintColor,
                        iconColor: _hintColor,
                        suffix: GestureDetector(
                          onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _hintColor,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password
                      _LabeledInputField(
                        label: 'Confirm Password',
                        controller: _confirmPasswordController,
                        hint: 'Confirm password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscureConfirmPassword,
                        inputBg: _inputBg,
                        borderColor: _borderColor,
                        hintColor: _hintColor,
                        iconColor: _hintColor,
                        suffix: GestureDetector(
                          onTap: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                          child: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _hintColor,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Create Account button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleCreateAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _black,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _black.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Login link ────────────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: _black.withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                      ),
                      children: const [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            color: _orange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── QuickArt Logo (same as Login page) ──────────────────────────────────────

class _QuickArtLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Quick',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A1A),
            letterSpacing: -1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Icon(
            Icons.bolt_rounded,
            color: const Color(0xFFE8720C),
            size: 32,
          ),
        ),
        const Text(
          'Art',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Color(0xFFE8720C),
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

// ─── Labeled Input Field ──────────────────────────────────────────────────────

class _LabeledInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final Color inputBg;
  final Color borderColor;
  final Color hintColor;
  final Color iconColor;

  const _LabeledInputField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffix,
    required this.inputBg,
    required this.borderColor,
    required this.hintColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF1A1A1A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: const Color(0xFF1A1A1A).withOpacity(0.6),
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hint,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(prefixIcon, color: iconColor, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 14),
                child: suffix,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: inputBg,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE8720C), width: 1.8),
        ),
      ),
    );
  }
}
