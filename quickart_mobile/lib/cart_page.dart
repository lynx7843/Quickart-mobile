import 'package:flutter/material.dart';

import 'home_page.dart';
import 'categories_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class _CartItem {
  final String name;
  final String subtitle;
  final double unitPrice;
  final Color imageBg;
  final IconData imageIcon;
  int quantity;

  _CartItem({
    required this.name,
    required this.subtitle,
    required this.unitPrice,
    required this.imageBg,
    required this.imageIcon,
    this.quantity = 1,
  });

  double get total => unitPrice * quantity;
}

// ─── Sample Data ──────────────────────────────────────────────────────────────

final List<_CartItem> _initialItems = [
  _CartItem(
    name: 'Neon Ethereal',
    subtitle: 'Original Canvas • 24×36',
    unitPrice: 45000,
    imageBg: const Color(0xFF7A9E7E),
    imageIcon: Icons.image_outlined,
  ),
  _CartItem(
    name: 'Monolith Study',
    subtitle: 'Limited Print • 12×12',
    unitPrice: 12500,
    quantity: 2,
    imageBg: const Color(0xFF8FAE8F),
    imageIcon: Icons.photo_outlined,
  ),
  _CartItem(
    name: 'Void Fragment',
    subtitle: 'Sculpture • Bronze',
    unitPrice: 89000,
    imageBg: const Color(0xFF6B8F6B),
    imageIcon: Icons.view_in_ar_outlined,
  ),
];

const double _shippingCost = 1200;
const double _taxRate = 0.03;

// ─── Page ─────────────────────────────────────────────────────────────────────

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _selectedNavIndex = 2;
  late List<_CartItem> _items;

  static const Color _black = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFC8803A);
  static const Color _bgColor = Color(0xFFF2F2F0);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _navIconColor = Color(0xFF999999);

  @override
  void initState() {
    super.initState();
    _items = _initialItems.map((e) => _CartItem(
          name: e.name,
          subtitle: e.subtitle,
          unitPrice: e.unitPrice,
          imageBg: e.imageBg,
          imageIcon: e.imageIcon,
          quantity: e.quantity,
        )).toList();
  }

  double get _subtotal => _items.fold(0, (s, i) => s + i.total);
  double get _tax => _subtotal * _taxRate;
  double get _grandTotal => _subtotal + _shippingCost + _tax;

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  void _increment(int index) => setState(() => _items[index].quantity++);

  void _decrement(int index) {
    setState(() {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      }
    });
  }

  void _remove(int index) {
    final name = _items[index].name;
    setState(() => _items.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name removed from cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: _black,
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
                  const SizedBox(height: 28),

                  // ── Page Heading ──────────────────────────────────────
                  Text(
                    'YOUR SELECTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                      color: _orange,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Cart.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _black,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Review your curated art pieces\nbefore final checkout.',
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.55,
                      color: _black.withOpacity(0.45),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Cart Items ────────────────────────────────────────
                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: 52,
                                color: _black.withOpacity(0.15)),
                            const SizedBox(height: 12),
                            Text(
                              'Your cart is empty',
                              style: TextStyle(
                                fontSize: 15,
                                color: _black.withOpacity(0.35),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CartCard(
                          item: item,
                          onIncrement: () => _increment(i),
                          onDecrement: () => _decrement(i),
                          onRemove: () => _remove(i),
                          black: _black,
                          cardColor: _cardColor,
                          formatPrice: _fmt,
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 12),

                  // ── Divider ───────────────────────────────────────────
                  Divider(color: _black.withOpacity(0.1), thickness: 1),

                  const SizedBox(height: 18),

                  // ── Price Breakdown ───────────────────────────────────
                  _PriceRow(
                    label: 'Subtotal',
                    value: 'LKR ${_fmt(_subtotal)}',
                    black: _black,
                  ),
                  const SizedBox(height: 10),
                  _PriceRow(
                    label: 'Shipping',
                    value: 'LKR ${_fmt(_shippingCost)}',
                    black: _black,
                  ),
                  const SizedBox(height: 10),
                  _PriceRow(
                    label: 'Tax (Estimated)',
                    value: 'LKR ${_fmt(_tax)}',
                    black: _black,
                  ),

                  const SizedBox(height: 18),

                  // ── Total ─────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _black,
                        ),
                      ),
                      Text(
                        'LKR ${_fmt(_grandTotal)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _orange,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Checkout Button ───────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _items.isEmpty
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Proceeding to checkout...'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  backgroundColor: _black,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _black,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 8),
                          Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Security note ─────────────────────────────────────
                  Center(
                    child: Text(
                      'SECURE ENCRYPTED CHECKOUT POWERED BY QUICKART PAY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
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
              onTap: (i) {
                if (i == _selectedNavIndex) return;
                Widget page;
                switch (i) {
                  case 0: page = const HomePage(); break;
                  case 1: page = const CategoriesPage(); break;
                  case 3: page = const WishlistPage(); break;
                  case 4: page = const ProfilePage(); break;
                  default: return;
                }
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(pageBuilder: (_, __, ___) => page, transitionDuration: Duration.zero),
                );
              },
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
          const SizedBox(width: 10),
          Text(
            'QuickArt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: black,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFD4A574),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: CustomPaint(painter: _MiniAvatarPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini Avatar ─────────────────────────────────────────────────────────────

class _MiniAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFD4A574));

    final bodyPaint = Paint()..color = const Color(0xFF8B6914);
    final bodyPath = Path()
      ..moveTo(w * 0.1, h)
      ..lineTo(w * 0.1, h * 0.75)
      ..quadraticBezierTo(w * 0.5, h * 0.6, w * 0.9, h * 0.75)
      ..lineTo(w * 0.9, h)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    final headPaint = Paint()..color = const Color(0xFFE8B887);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.38), width: w * 0.5, height: h * 0.5),
        headPaint);

    final hairPaint = Paint()..color = const Color(0xFF5C3D1E);
    final hairPath = Path()
      ..moveTo(w * 0.25, h * 0.25)
      ..quadraticBezierTo(w * 0.5, h * 0.08, w * 0.75, h * 0.25)
      ..quadraticBezierTo(w * 0.72, h * 0.15, w * 0.5, h * 0.15)
      ..quadraticBezierTo(w * 0.28, h * 0.15, w * 0.25, h * 0.25)
      ..close();
    canvas.drawPath(hairPath, hairPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Cart Card ────────────────────────────────────────────────────────────────

class _CartCard extends StatelessWidget {
  final _CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final Color black;
  final Color cardColor;
  final String Function(double) formatPrice;

  const _CartCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.black,
    required this.cardColor,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 90,
              height: 90,
              color: item.imageBg,
              child: Center(
                child: Icon(item.imageIcon,
                    size: 36, color: Colors.white.withOpacity(0.4)),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: black,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: Icon(Icons.close_rounded,
                          size: 18, color: black.withOpacity(0.35)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: black.withOpacity(0.4),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),

                // Quantity + Price
                Row(
                  children: [
                    // Qty controls
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: black.withOpacity(0.15), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QtyButton(
                            icon: Icons.remove_rounded,
                            onTap: onDecrement,
                            black: black,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              item.quantity.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: black,
                              ),
                            ),
                          ),
                          _QtyButton(
                            icon: Icons.add_rounded,
                            onTap: onIncrement,
                            black: black,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'LKR ${formatPrice(item.total)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: black,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Qty Button ───────────────────────────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color black;

  const _QtyButton(
      {required this.icon, required this.onTap, required this.black});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 30,
        height: 32,
        child: Icon(icon, size: 15, color: black),
      ),
    );
  }
}

// ─── Price Row ────────────────────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color black;

  const _PriceRow(
      {required this.label, required this.value, required this.black});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: black.withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
  _NavItem(icon: Icons.person_outline_rounded, label: 'PROFILE'),
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
                  Icon(item.icon,
                      size: 22,
                      color: isActive ? black : navIconColor),
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