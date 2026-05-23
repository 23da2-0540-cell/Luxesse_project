import 'package:flutter/material.dart';
import 'data/app_data.dart';
import 'services/firestore_service.dart';
import 'product_listing_page.dart';
import 'product_detail_page.dart';
import 'bag_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentBannerIndex = 0;
  int _currentNavIndex    = 0;

  final _firestoreService = FirestoreService();

  // Banners and categories come from AppData (static, no Firestore needed)
  final List<Map<String, String>> _banners    = AppData.banners;
  final List<Map<String, String>> _categories = AppData.categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildBannerCarousel(),
                  const SizedBox(height: 12),
                  _buildDotIndicators(),
                  const SizedBox(height: 20),
                  _buildCategoryRow(),
                  const SizedBox(height: 24),
                  _buildFeaturedSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ──────────────────────────────────────────
  // APP BAR
  // ──────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: const Color(0xFFD4B06A),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 20,
        bottom: 12,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'LUXESSE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 5,
                  fontFamily: 'serif',
                ),
              ),
            ),
          ),
          Row(
            children: [
              _appBarIcon(Icons.search, () {}),
              const SizedBox(width: 12),
              _appBarIcon(Icons.shopping_bag_outlined, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BagPage()));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appBarIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  // ──────────────────────────────────────────
  // BANNER CAROUSEL
  // ──────────────────────────────────────────
  Widget _buildBannerCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: _banners.length,
            onPageChanged: (index) =>
                setState(() => _currentBannerIndex = index),
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    banner['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Container(color: const Color(0xFFD4B06A)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () {
                            final category = banner['category'] ?? 'Dresses';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductListingPage(category: category),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Shop Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // DOT INDICATORS
  // ──────────────────────────────────────────
  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_banners.length, (index) {
        final isActive = index == _currentBannerIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFAC8A2E)
                : const Color(0xFFD4B06A).withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ──────────────────────────────────────────
  // CATEGORY ROW
  // ──────────────────────────────────────────
  Widget _buildCategoryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _categories.map((cat) {
          return _buildCategoryItem(
            label: cat['label']!,
            imagePath: cat['image']!,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(
      {required String label, required String imagePath}) {
    return GestureDetector(
      onTap: () {
        // All categories navigate to ProductListingPage with their own label
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListingPage(category: label),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFFD4B06A).withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFE8DCC8),
                  child: Icon(Icons.image_not_supported,
                      color: Colors.grey.shade400),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // FEATURED SECTION — Firestore StreamBuilder
  // ──────────────────────────────────────────
  Widget _buildFeaturedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestoreService.getProducts(),
            builder: (context, snapshot) {
              // While loading from Firestore, show AppData as fallback
              final products = snapshot.hasData && snapshot.data!.isNotEmpty
                  ? snapshot.data!
                  : AppData.featuredProducts
                      .map((p) => Map<String, dynamic>.from(p))
                      .toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.75,
                ),
                itemCount: products.length > 4 ? 4 : products.length,
                itemBuilder: (context, index) =>
                    _buildProductCard(products[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // PRODUCT CARD  (Step 5: imageUrl support)
  // ──────────────────────────────────────────
  Widget _buildProductCard(Map<String, dynamic> product) {
    final imageUrl   = (product['imageUrl'] ?? '').toString();
    final localImage = (product['localImage'] ?? product['image'] ?? '').toString();
    final name  = (product['name'] ?? '').toString();
    final price = (product['price'] ?? '').toString();
    final detailLocalImage =
        (product['detailLocalImage'] ?? product['detailImage'] ?? localImage)
            .toString();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              productName: name.replaceAll('\n', ' '),
              price: price,
              mainImage: localImage,
              imageUrl: imageUrl,
              detailLocalImage: detailLocalImage,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: _productImage(
                  imageUrl: imageUrl,
                  localImage: localImage,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFAC8A2E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // IMAGE HELPER (Step 5)
  // ──────────────────────────────────────────
  Widget _productImage({
    required String imageUrl,
    required String localImage,
    required double width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(width, height),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder(width, height),
      );
    }
    if (localImage.isNotEmpty) {
      return Image.asset(
        localImage,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(width, height),
      );
    }
    return _placeholder(width, height);
  }

  Widget _placeholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Icon(Icons.image_not_supported,
          color: Colors.grey.shade400, size: 40),
    );
  }

  // ──────────────────────────────────────────
  // BOTTOM NAV BAR
  // ──────────────────────────────────────────
  Widget _buildBottomNavBar() {
    final items = [
      {'icon': Icons.home_rounded,           'label': 'Home'},
      {'icon': Icons.grid_view_rounded,      'label': 'Products'},
      {'icon': Icons.bookmark_border_rounded,'label': 'Wishlist'},
      {'icon': Icons.person_outline,         'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isActive = index == _currentNavIndex;
              final icon  = items[index]['icon'] as IconData;
              final label = items[index]['label'] as String;
              return GestureDetector(
                onTap: () {
                  setState(() => _currentNavIndex = index);
                  if (index == 1) {
                    // Products — all products listing
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const ProductListingPage(category: 'All')),
                    ).then((_) {
                      if (mounted) setState(() => _currentNavIndex = 0);
                    });
                  } else if (index == 2) {
                    // Wishlist
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const WishlistPage()),
                    ).then((_) {
                      if (mounted) setState(() => _currentNavIndex = 0);
                    });
                  } else if (index == 3) {
                    // Profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfilePage()),
                    ).then((_) {
                      if (mounted) setState(() => _currentNavIndex = 0);
                    });
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isActive
                          ? const Color(0xFFAC8A2E)
                          : Colors.grey.shade400,
                      size: 26,
                    ),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isActive ? 20 : 0,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFAC8A2E),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
