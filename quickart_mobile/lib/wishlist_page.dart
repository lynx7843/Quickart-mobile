import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import 'home_page.dart';
import 'categories_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'session.dart';
import 'config.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class _WishlistItem {
  final String productId;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  bool isWishlisted;

  _WishlistItem({
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    this.isWishlisted = true,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  int _selectedNavIndex = 3;
  late List<_WishlistItem> _items;
  bool _isLoading = false;

  static const Color _black = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFE8720C);
  static const Color _bgColor = Color(0xFFF5F5F5);
  static const Color _navIconColor = Color(0xFF999999);

  @override
  void initState() {
    super.initState();
    _items = [];
    _fetchWishlistData();
  }

  void _fetchWishlistData() async {
    setState(() => _isLoading = true);
    try {
      final db = await mongo.Db.create(Config.mongoUrl);
      await db.open();

      final prefCollection = db.collection('preferences');
      final productCollection = db.collection('products');

      // Fetching preferences for the currently logged-in user
      final pref = await prefCollection.findOne(mongo.where.eq('userId', Session.userId));

      if (pref != null && pref['wishlist'] != null) {
        List<dynamic> wishlistIds = pref['wishlist'];
        List<_WishlistItem> fetchedItems = [];

        for (var prodId in wishlistIds) {
          if (prodId is String && prodId.isNotEmpty) {
            final prod = await productCollection.findOne(mongo.where.eq('_id', prodId));
            if (prod != null) {
              fetchedItems.add(_WishlistItem(
                productId: prodId,
                name: prod['name']?.toString() ?? 'Unknown',
                category: prod['category']?.toString() ?? 'GENERAL',
                price: (prod['price'] as num?)?.toDouble() ?? 0.0,
                imageUrl: prod['imageUrl']?.toString() ?? '',
                isWishlisted: true,
              ));
            }
          }
        }

        if (mounted) {
          setState(() => _items = fetchedItems);
        }
      }
      await db.close();
    } catch (e) {
      debugPrint('Error fetching wishlist: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double get _totalValue =>
      _items.fold(0, (sum, item) => sum + item.price);

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  void _removeItem(int index) async {
    setState(() => _items.removeAt(index));

    try {
      final db = await mongo.Db.create(Config.mongoUrl);
      await db.open();

      final prefCollection = db.collection('preferences');
      final updatedWishlist = _items.map((e) => e.productId).toList();

      await prefCollection.updateOne(
        mongo.where.eq('userId', Session.userId),
        mongo.modify.set('wishlist', updatedWishlist),
      );

      await db.close();
    } catch (e) {
      debugPrint('Error syncing wishlist: $e');
    }
  }

  void _moveAllToCart() async {
    if (_items.isEmpty) return;

    final itemsToMove = List.from(_items);
    setState(() => _items.clear());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${itemsToMove.length} items moved to cart'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: _black,
      ),
    );

    _syncToCartAndWishlist(itemsToMove);
  }

  void _addToCart(_WishlistItem item) async {
    setState(() => _items.remove(item));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} moved to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: _black,
      ),
    );

    _syncToCartAndWishlist([item]);
  }

  Future<void> _syncToCartAndWishlist(List<dynamic> itemsToAdd) async {
    try {
      final db = await mongo.Db.create(Config.mongoUrl);
      await db.open();

      final prefCollection = db.collection('preferences');
      final pref = await prefCollection.findOne(mongo.where.eq('userId', Session.userId));

      if (pref != null) {
        List<dynamic> currentCart = pref['cart'] ?? [];

        for (var item in itemsToAdd) {
          bool found = false;
          for (var cartItem in currentCart) {
            if (cartItem['productId'] == item.productId) {
              cartItem['quantity'] = (cartItem['quantity'] as num).toInt() + 1;
              found = true;
              break;
            }
          }
          if (!found) {
            currentCart.add({'productId': item.productId, 'quantity': 1});
          }
        }

        final updatedWishlist = _items.map((e) => e.productId).toList();

        await prefCollection.updateOne(
          mongo.where.eq('userId', Session.userId),
          mongo.modify.set('cart', currentCart).set('wishlist', updatedWishlist),
        );
      }

      await db.close();
    } catch (e) {
      debugPrint('Error moving items to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ───────────────────────────────────────────────────
            _AppBar(black: _black, orange: _orange),

            // ── Scrollable content ────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 20),

                  // ── Page Heading ──────────────────────────────────────
                  const Text(
                    'CURATED COLLECTION',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wishlist',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: _black,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 3,
                            decoration: BoxDecoration(
                              color: _orange,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Stats Row ─────────────────────────────────────────
                  Row(
                    children: [
                      // Saved items card
                      Expanded(
                        child: _StatCard(
                          label: 'SAVED ITEMS',
                          value: _items.length.toString().padLeft(2, '0'),
                          black: _black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Total value card
                      Expanded(
                        flex: 2,
                        child: _StatCard(
                          label: 'TOTAL VALUE',
                          value: 'LKR ${_formatPrice(_totalValue)}',
                          valueFontSize: 22,
                          black: _black,
                          hasAccentBorder: true,
                          orange: _orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Move All to Cart ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _moveAllToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'MOVE ALL TO CART',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Wishlist Items ────────────────────────────────────
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(color: _orange),
                      ),
                    )
                  else if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.favorite_border_rounded, size: 52, color: _black.withOpacity(0.15)),
                            const SizedBox(height: 12),
                            Text(
                              'Your wishlist is empty',
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
                      final index = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _WishlistCard(
                          item: item,
                          onRemove: () => _removeItem(index),
                          onAddToCart: () => _addToCart(item),
                          orange: _orange,
                          black: _black,
                          formatPrice: _formatPrice,
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 8),
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
                  case 2: page = const CartPage(); break;
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
              orange: _orange,
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
  final Color orange;

  const _AppBar({required this.black, required this.orange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          // Logo
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Q',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: orange,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'uickArt',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: black,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const ProfilePage(),
                    transitionDuration: Duration.zero),
              );
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_outline_rounded, size: 18, color: black),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final double valueFontSize;
  final Color black;
  final bool hasAccentBorder;
  final Color? orange;

  const _StatCard({
    required this.label,
    required this.value,
    this.valueFontSize = 28,
    required this.black,
    this.hasAccentBorder = false,
    this.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: hasAccentBorder
            ? Border(
                left: BorderSide(color: orange!, width: 4),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: black.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w800,
              color: black,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wishlist Card ────────────────────────────────────────────────────────────

class _WishlistCard extends StatelessWidget {
  final _WishlistItem item;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;
  final Color orange;
  final Color black;
  final String Function(double) formatPrice;

  const _WishlistCard({
    required this.item,
    required this.onRemove,
    required this.onAddToCart,
    required this.orange,
    required this.black,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ───────────────────────────────────────────────────
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                              Icons.image_not_supported_outlined,
                              size: 52,
                              color: black.withOpacity(0.2)),
                        )
                      : Icon(Icons.image_not_supported_outlined,
                          size: 52, color: black.withOpacity(0.2)),
                ),
              ),
              // Wishlist heart
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Info Row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: black,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.category,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: black.withOpacity(0.38),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'LKR ${formatPrice(item.price)}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: black,
                  ),
                ),
              ],
            ),
          ),

          // ── Add to Cart Button ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: onAddToCart,
                icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                label: const Text(
                  'ADD TO CART',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: black,
                  side: BorderSide(color: black.withOpacity(0.25), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
  final Color orange;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.navIconColor,
    required this.black,
    required this.orange,
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