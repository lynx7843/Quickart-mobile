import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import 'categories_page.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart';
import 'item_detail_page.dart';
import 'session.dart';
import 'config.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class _Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String? model3dUrl;
  final String category;
  bool isWishlisted;

  _Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.model3dUrl,
    required this.category,
    this.isWishlisted = false,
  });
}

// ─── HomePage ─────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;
  int _cartCount = 1;

  List<_Product> _products = [];
  bool _isLoading = false;

  static const Color _black = Color(0xFF1A1A1A);
  static const Color _orange = Color(0xFFE8720C);
  static const Color _navIconColor = Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _products = [];
    });

    try {
      final db = await mongo.Db.create(Config.mongoUrl);
      await db.open();
      final collection = db.collection('products');

      final items = await collection.find().toList();

      await db.close();

      if (!mounted) return;

      setState(() {
        _products = items.map((json) => _Product(
          id: json['_id'].toString(),
          name: json['name']?.toString() ?? 'Unknown Product',
          description: json['description']?.toString() ?? '',
          price: (json['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: json['imageUrl']?.toString() ?? '',
          model3dUrl: json['model3dUrl']?.toString(),
          category: json['category']?.toString() ?? '',
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _toggleWishlist(int index) async {
    final product = _products[index];
    setState(() {
      product.isWishlisted = !product.isWishlisted;
    });

    try {
      final db = await mongo.Db.create(Config.mongoUrl);
      await db.open();

      final prefCollection = db.collection('preferences');
      final pref = await prefCollection.findOne(mongo.where.eq('userId', Session.userId));
      if (pref != null) {
        List<dynamic> wishlist = pref['wishlist'] ?? [];
        if (product.isWishlisted) {
          if (!wishlist.contains(product.id)) wishlist.add(product.id);
        } else {
          wishlist.remove(product.id);
        }
        await prefCollection.updateOne(
          mongo.where.eq('userId', Session.userId),
          mongo.modify.set('wishlist', wishlist),
        );
      }
      await db.close();
    } catch (e) {
      debugPrint('Error updating wishlist: $e');
    }
  }

  void _addToCart(int index) async {
    final product = _products[index];
    setState(() => _cartCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    try {
      final db = await mongo.Db.create(Config.mongoUrl);
      await db.open();

      final prefCollection = db.collection('preferences');
      final pref = await prefCollection.findOne(mongo.where.eq('userId', Session.userId));
      if (pref != null) {
        List<dynamic> cart = pref['cart'] ?? [];
        bool found = false;
        for (var item in cart) {
          if (item['productId'] == product.id) {
            item['quantity'] = (item['quantity'] as num).toInt() + 1;
            found = true;
            break;
          }
        }
        if (!found) {
          cart.add({'productId': product.id, 'quantity': 1});
        }
        await prefCollection.updateOne(
          mongo.where.eq('userId', Session.userId),
          mongo.modify.set('cart', cart),
        );
      }
      await db.close();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.search_rounded,
                              color: _black.withOpacity(0.4), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              style:
                                  const TextStyle(fontSize: 14, color: _black),
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: _black.withOpacity(0.38),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const CartPage(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Icon(Icons.shopping_cart_outlined,
                              color: _black, size: 22),
                        ),
                        if (_cartCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: _black,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  '$_cartCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
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

            // ── Scrollable content ────────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Featured Products header
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Featured Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _black,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // Product Grid
                  if (_isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(color: _orange),
                        ),
                      ),
                    )
                  else if (_products.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No products found',
                            style: TextStyle(
                              color: _black.withOpacity(0.5),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _ProductCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailPage(productId: _products[index].id),
                                ),
                              );
                            },
                            product: _products[index],
                            onWishlistTap: () => _toggleWishlist(index),
                            onAddToCart: () => _addToCart(index),
                            orange: _orange,
                            black: _black,
                          ),
                          childCount: _products.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.65,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
                  case 1: page = const CategoriesPage(); break;
                  case 2: page = const CartPage(); break;
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

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final _Product product;
  final VoidCallback onWishlistTap;
  final VoidCallback onAddToCart;
  final VoidCallback? onTap;
  final Color orange;
  final Color black;

  const _ProductCard({
    required this.product,
    required this.onWishlistTap,
    required this.onAddToCart,
    this.onTap,
    required this.orange,
    required this.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
          width: 1,
        ),
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
          // Image area
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                  child: Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF2F2F2),
                      child: Center(
                        child: Icon(Icons.image_not_supported_outlined, color: black.withOpacity(0.2)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onWishlistTap,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        product.isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: product.isWishlisted ? Colors.red : black,
                      ),
                    ),
                  ),
                ),
                if (product.model3dUrl != null && product.model3dUrl!.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            '3D',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Info area
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: black,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Description
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: black.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),

                  // Price + Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'LKR ${_formatPrice(product.price)}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price
          .toStringAsFixed(0)
          .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    }
    return price.toStringAsFixed(0);
  }
}

// ─── Bottom Nav Bar ───────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

const _navItems = [
  _NavItem(icon: Icons.home_outlined, label: 'Home'),
  _NavItem(icon: Icons.grid_view_rounded, label: 'Categories'),
  _NavItem(icon: Icons.shopping_cart_outlined, label: 'Cart'),
  _NavItem(icon: Icons.favorite_border_rounded, label: 'Wishlist'),
  _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
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
      height: 64,
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
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 24,
                    color: isActive ? black : navIconColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w400,
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