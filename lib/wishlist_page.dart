import 'package:flutter/material.dart';
import 'services/firestore_service.dart';
import 'product_detail_page.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestoreService.getWishlistItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFAC8A2E)),
                  );
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border_rounded,
                            size: 64, color: Color(0xFFD4B06A)),
                        SizedBox(height: 16),
                        Text(
                          'No saved items yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            fontFamily: 'serif',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the bookmark icon on any product\nto save it here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${items.length} Saved Item${items.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) =>
                              _buildWishlistCard(
                                  context, items[index], firestoreService),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // APP BAR
  // ──────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: const Color(0xFFD4B06A),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 20,
        bottom: 14,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios,
                color: Colors.white, size: 20),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'LUXESSE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 5,
                  fontFamily: 'serif',
                ),
              ),
            ),
          ),
          // Spacer to balance back button and keep title centred
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // WISHLIST CARD
  // ──────────────────────────────────────────
  Widget _buildWishlistCard(
    BuildContext context,
    Map<String, dynamic> item,
    FirestoreService firestoreService,
  ) {
    final docId            = (item['docId']            ?? '').toString();
    final imageUrl         = (item['imageUrl']         ?? '').toString();
    final localImage       = (item['localImage']       ?? '').toString();
    final name             = (item['name']             ?? '').toString();
    final price            = (item['price']            ?? '').toString();
    final detailLocalImage =
        (item['detailLocalImage'] ?? localImage).toString();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              productName:      name,
              price:            price,
              mainImage:        localImage,
              imageUrl:         imageUrl,
              detailLocalImage: detailLocalImage,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            // ── Image with remove button overlay ──
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                    child: _itemImage(
                        imageUrl: imageUrl, localImage: localImage),
                  ),
                  // Remove from wishlist
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        if (docId.isNotEmpty) {
                          await firestoreService.removeFromWishlist(docId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Removed from wishlist'),
                                backgroundColor: Color(0xFFAC8A2E),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bookmark_rounded,
                          color: Color(0xFFAC8A2E),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Name & Price ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
  // IMAGE HELPER
  // ──────────────────────────────────────────
  Widget _itemImage(
      {required String imageUrl, required String localImage}) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    if (localImage.isNotEmpty) {
      return Image.asset(
        localImage,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.image_not_supported,
          color: Colors.grey.shade400, size: 40),
    );
  }
}
