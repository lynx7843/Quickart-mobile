import 'package:flutter/material.dart';

void main() {
  runApp(const QuickArtApp());
}

class QuickArtApp extends StatelessWidget {
  const QuickArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickArt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFF0EDE6),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
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
                const SizedBox(height: 52),

                // ── Logo ──────────────────────────────────────────────────
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

                const SizedBox(height: 40),

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
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Center(
                        child: Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: _black,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Please enter your details to sign in.',
                          style: TextStyle(
                            fontSize: 14,
                            color: _black.withOpacity(0.45),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Email label
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _black,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Email field
                      _InputField(
                        controller: _emailController,
                        hint: 'name@quickcart.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        inputBg: _inputBg,
                        borderColor: _borderColor,
                        hintColor: _hintColor,
                        iconColor: _hintColor,
                      ),

                      const SizedBox(height: 20),

                      // Password label
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _black,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Password field
                      _InputField(
                        controller: _passwordController,
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        inputBg: _inputBg,
                        borderColor: _borderColor,
                        hintColor: _hintColor,
                        iconColor: _hintColor,
                        suffix: GestureDetector(
                          onTap: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _hintColor,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 14,
                              color: _orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Sign In button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignIn,
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
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: _borderColor,
                              thickness: 1.2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                fontSize: 13,
                                color: _black.withOpacity(0.4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: _borderColor,
                              thickness: 1.2,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Social buttons
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              label: 'Google',
                              icon: _GoogleIcon(),
                              onTap: () {},
                              borderColor: _borderColor,
                              black: _black,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _SocialButton(
                              label: 'Github',
                              icon: const Icon(
                                Icons.code_rounded,
                                size: 22,
                                color: Color(0xFF1A1A1A),
                              ),
                              onTap: () {},
                              borderColor: _borderColor,
                              black: _black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Register link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: _black.withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                            ),
                            children: const [
                              TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'Create an Account',
                                style: TextStyle(
                                  color: _orange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

// ─── QuickArt Logo Widget ────────────────────────────────────────────────────

class _QuickArtLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // "Quick" in bold black
        const Text(
          'Quick',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A1A),
            letterSpacing: -1,
          ),
        ),
        // Lightning bolt in orange
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Icon(
            Icons.bolt_rounded,
            color: const Color(0xFFE8720C),
            size: 32,
          ),
        ),
        // "Art" in bold orange
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

// ─── Reusable Input Field ────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
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

  const _InputField({
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
        hintText: hint,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 10),
          child: Icon(prefixIcon, color: iconColor, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 16),
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

// ─── Social Button ───────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  final Color borderColor;
  final Color black;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.borderColor,
    required this.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 9),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Google "G" Icon ─────────────────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Blue arc (top-right)
    _drawArc(canvas, cx, cy, r, -10, -80, const Color(0xFF4285F4));
    // Red arc (top-left)
    _drawArc(canvas, cx, cy, r, -90, -90, const Color(0xFFEA4335));
    // Yellow arc (bottom-left)
    _drawArc(canvas, cx, cy, r, -180, -90, const Color(0xFFFBBC05));
    // Green arc (bottom-right)
    _drawArc(canvas, cx, cy, r, -270, -80, const Color(0xFF34A853));

    // White center cutout
    final Paint white = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.62, white);

    // Blue bar (right)
    final Paint blue = Paint()..color = const Color(0xFF4285F4);
    final Rect bar = Rect.fromLTWH(cx, cy - r * 0.22, r * 1.05, r * 0.44);
    canvas.drawRect(bar, blue);

    // White over-cover to clean up bar
    final Paint white2 = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.6, white2);

    // Re-draw blue bar inside
    final Rect bar2 = Rect.fromLTWH(cx, cy - r * 0.19, r, r * 0.38);
    canvas.drawRect(bar2, blue);
  }

  void _drawArc(Canvas canvas, double cx, double cy, double r,
      double startDeg, double sweepDeg, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = r * 0.38
      ..style = PaintingStyle.stroke;
    final double start = startDeg * (3.14159265 / 180);
    final double sweep = sweepDeg * (3.14159265 / 180);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.8),
      start,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
