import 'package:flutter/material.dart';
import 'services/firestore_service.dart';
import 'checkout_page.dart';

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  final _firestoreService = FirestoreService();
  final double _shipping  = 50.00;

  double _subtotal(List<Map<String, dynamic>> items) => items.fold(
      0.0,
      (sum, item) =>
          sum + ((item['price'] as num? ?? 0).toDouble() *
              (item['quantity'] as num? ?? 1).toInt()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getCartItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFAC8A2E)),
                  );
                }

                final cartItems = snapshot.data ?? [];

                if (cartItems.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 64, color: Color(0xFFD4B06A)),
                        SizedBox(height: 16),
                        Text(
                          'Your bag is empty',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            fontFamily: 'serif',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final subtotal = _subtotal(cartItems);
                final total    = subtotal + _shipping;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Title Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Bag',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'serif',
                            ),
                          ),
                          Text(
                            '${cartItems.length} Items',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Cart Items
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 20),
                        itemBuilder: (_, index) =>
                            _buildCartItem(cartItems[index]),
                      ),

                      const SizedBox(height: 30),
                      const Divider(color: Colors.grey, thickness: 0.5),
                      const SizedBox(height: 10),

                      // Summary
                      _buildSummaryRow(
                          'Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                          'Shipping', '\$${_shipping.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.grey, thickness: 0.5),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        'Total', '\$${total.toStringAsFixed(2)}',
                        isTotal: true,
                      ),

                      const SizedBox(height: 30),

                      // Promo Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFAC8A2E)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Apply Promo',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Checkout Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutPage(
                                  cartItems: cartItems,
                                  subtotal: subtotal,
                                  total: total,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFAC8A2E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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
                color: Colors.black, size: 22),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'LUXESSE',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 5,
                  fontFamily: 'serif',
                ),
              ),
            ),
          ),
          const Icon(Icons.shopping_cart_outlined,
              color: Colors.black, size: 24),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // CART ITEM  (Step 5: imageUrl support)
  // ──────────────────────────────────────────
  Widget _buildCartItem(Map<String, dynamic> item) {
    final docId      = (item['docId'] ?? '').toString();
    final imageUrl   = (item['imageUrl'] ?? '').toString();
    final localImage = (item['localImage'] ?? item['image'] ?? '').toString();
    final qty        = (item['quantity'] as num? ?? 1).toInt();
    final subtitle   = (item['subtitle'] ?? '').toString();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _cartItemImage(
              imageUrl: imageUrl, localImage: localImage),
        ),
        const SizedBox(width: 16),
        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name']?.toString() ?? '',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black54)),
              ],
              const SizedBox(height: 12),
              Text(
                '\$${(item['price'] as num? ?? 0).toInt()}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
        ),
        // Quantity Selector
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _quantityButton(Icons.remove, () {
                if (docId.isNotEmpty) {
                  _firestoreService.updateCartQuantity(docId, qty - 1);
                }
              }),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$qty',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _quantityButton(Icons.add, () {
                if (docId.isNotEmpty) {
                  _firestoreService.updateCartQuantity(docId, qty + 1);
                }
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cartItemImage(
      {required String imageUrl, required String localImage}) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 100,
        height: 130,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            _cartPlaceholder(),
      );
    }
    if (localImage.isNotEmpty) {
      return Image.asset(
        localImage,
        width: 100,
        height: 130,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _cartPlaceholder(),
      );
    }
    return _cartPlaceholder();
  }

  Widget _cartPlaceholder() {
    return Container(
      width: 100,
      height: 130,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight:
                isTotal ? FontWeight.bold : FontWeight.w500,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight:
                isTotal ? FontWeight.bold : FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
