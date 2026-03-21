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
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
      ),
      home: const ProfilePage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedNavIndex = 4;

  static const Color _black = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFE8720C);
  static const Color _bgColor = Color(0xFFF2F2F2);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _navIconColor = Color(0xFF999999);
  static const Color _red = Color(0xFFD32F2F);

  void _onMenuTap(String label) {
    if (label == 'Logout') {
      _showLogoutDialog();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label tapped'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: _black,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Logout',
                style: TextStyle(
                    color: Color(0xFFD32F2F), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ───────────────────────────────────────────────────
            _AppBar(black: _black),

            // ── Scrollable Body ───────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 24),

                  // ── Avatar + Edit ──────────────────────────────────────
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8BAF8E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: const _AvatarIllustration(),
                        ),
                      ),
                      // Edit badge
                      Positioned(
                        bottom: -6,
                        left: 68,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _orange,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: _orange.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Name & Email ───────────────────────────────────────
                  const Text(
                    'Alex Harrison',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'alex.harrison@quickart.com',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: _black.withOpacity(0.45),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Premium Badge ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: _black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PREMIUM MEMBER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Account Overview Section ───────────────────────────
                  _SectionLabel(label: 'ACCOUNT OVERVIEW', black: _black),
                  const SizedBox(height: 10),

                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.shopping_bag_outlined,
                        label: 'My Orders',
                      ),
                      _MenuItem(
                        icon: Icons.local_shipping_outlined,
                        label: 'Shipping Address',
                      ),
                      _MenuItem(
                        icon: Icons.credit_card_outlined,
                        label: 'Payment Methods',
                      ),
                    ],
                    onTap: _onMenuTap,
                    black: _black,
                    cardColor: _cardColor,
                  ),

                  const SizedBox(height: 28),

                  // ── Preferences Section ────────────────────────────────
                  _SectionLabel(label: 'PREFERENCES', black: _black),
                  const SizedBox(height: 10),

                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                      ),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help',
                      ),
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        isDestructive: true,
                        destructiveColor: _red,
                      ),
                    ],
                    onTap: _onMenuTap,
                    black: _black,
                    cardColor: _cardColor,
                  ),

                  const SizedBox(height: 36),

                  // ── Version ────────────────────────────────────────────
                  Center(
                    child: Text(
                      'QUICKART V2.4.0 • 2024',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.8,
                        color: _black.withOpacity(0.28),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Bottom Nav Bar ────────────────────────────────────────────
            _BottomNavBar(
              selectedIndex: _selectedNavIndex,
              onTap: (i) => setState(() => _selectedNavIndex = i),
              navIconColor: _navIconColor,
              black: _black,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final Color black;
  const _AppBar({required this.black});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          Icon(Icons.menu_rounded, color: black, size: 22),
          const Expanded(
            child: Center(
              child: Text(
                'QuickArt',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFD4A574),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar Illustration ──────────────────────────────────────────────────────

class _AvatarIllustration extends StatelessWidget {
  const _AvatarIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(painter: _AvatarPainter()),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    final bgPaint = Paint()..color = const Color(0xFF8BAF8E);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Body / shirt
    final bodyPaint = Paint()..color = const Color(0xFFE8EEE8);
    final bodyPath = Path()
      ..moveTo(w * 0.15, h)
      ..lineTo(w * 0.15, h * 0.72)
      ..quadraticBezierTo(w * 0.5, h * 0.58, w * 0.85, h * 0.72)
      ..lineTo(w * 0.85, h)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Tie
    final tiePaint = Paint()..color = const Color(0xFF6B7B6E);
    final tiePath = Path()
      ..moveTo(w * 0.44, h * 0.62)
      ..lineTo(w * 0.56, h * 0.62)
      ..lineTo(w * 0.52, h * 0.82)
      ..lineTo(w * 0.48, h * 0.82)
      ..close();
    canvas.drawPath(tiePath, tiePaint);

    // Neck
    final neckPaint = Paint()..color = const Color(0xFFD4956A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.41, h * 0.5, w * 0.18, h * 0.16),
        const Radius.circular(4),
      ),
      neckPaint,
    );

    // Head
    final headPaint = Paint()..color = const Color(0xFFD4956A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.36),
        width: w * 0.44,
        height: h * 0.46,
      ),
      headPaint,
    );

    // Hair
    final hairPaint = Paint()..color = const Color(0xFF2C2C2C);
    final hairPath = Path()
      ..moveTo(w * 0.28, h * 0.28)
      ..quadraticBezierTo(w * 0.3, h * 0.1, w * 0.5, h * 0.1)
      ..quadraticBezierTo(w * 0.7, h * 0.1, w * 0.72, h * 0.28)
      ..quadraticBezierTo(w * 0.68, h * 0.14, w * 0.5, h * 0.14)
      ..quadraticBezierTo(w * 0.32, h * 0.14, w * 0.28, h * 0.28)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Glasses frame left
    final glassesPaint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.3, h * 0.33, w * 0.16, h * 0.1),
        const Radius.circular(3),
      ),
      glassesPaint,
    );
    // Glasses frame right
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.54, h * 0.33, w * 0.16, h * 0.1),
        const Radius.circular(3),
      ),
      glassesPaint,
    );
    // Bridge
    canvas.drawLine(
      Offset(w * 0.46, h * 0.375),
      Offset(w * 0.54, h * 0.375),
      glassesPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(w * 0.38, h * 0.38), w * 0.025, eyePaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.38), w * 0.025, eyePaint);

    // Nose
    final nosePaint = Paint()
      ..color = const Color(0xFFC07E50)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final nosePath = Path()
      ..moveTo(w * 0.5, h * 0.38)
      ..lineTo(w * 0.5, h * 0.44)
      ..quadraticBezierTo(w * 0.47, h * 0.46, w * 0.44, h * 0.45);
    canvas.drawPath(nosePath, nosePaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFFA0644A)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path()
      ..moveTo(w * 0.42, h * 0.49)
      ..quadraticBezierTo(w * 0.5, h * 0.535, w * 0.58, h * 0.49);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color black;
  const _SectionLabel({required this.label, required this.black});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        color: black.withOpacity(0.38),
      ),
    );
  }
}

// ─── Menu Item Model ──────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final Color? destructiveColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.destructiveColor,
  });
}

// ─── Menu Card ────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  final void Function(String) onTap;
  final Color black;
  final Color cardColor;

  const _MenuCard({
    required this.items,
    required this.onTap,
    required this.black,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == items.length - 1;

        return GestureDetector(
          onTap: () => onTap(item.label),
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon box
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.isDestructive
                        ? const Color(0xFFFFF0F0)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    size: 18,
                    color: item.isDestructive
                        ? item.destructiveColor
                        : black,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: item.isDestructive
                          ? item.destructiveColor
                          : black,
                    ),
                  ),
                ),
                if (!item.isDestructive)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: black.withOpacity(0.3),
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Bottom Nav Bar ───────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

const _navItems = [
  _NavItem(icon: Icons.home_outlined, label: 'HOME'),
  _NavItem(icon: Icons.grid_view_rounded, label: 'CATEGORIES'),
  _NavItem(icon: Icons.shopping_cart_outlined, label: 'CART'),
  _NavItem(icon: Icons.favorite_border_rounded, label: 'WISHLIST'),
  _NavItem(icon: Icons.person_rounded, label: 'PROFILE'),
];

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color navIconColor;
  final Color black;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.navIconColor,
    required this.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.08), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isActive = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 58,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: isActive ? black : navIconColor,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          isActive ? FontWeight.w800 : FontWeight.w500,
                      letterSpacing: 0.5,
                      color: isActive ? black : navIconColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
