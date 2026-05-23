import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ─── PRODUCTS ────────────────────────────────────────────────

  // All products — real-time stream
  Stream<List<Map<String, dynamic>>> getProducts() {
    return _db.collection('products').snapshots().map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  // Products filtered by category — real-time stream.
  // Pass 'All' to stream every product.
  Stream<List<Map<String, dynamic>>> getProductsByCategory(String category) {
    if (category == 'All') return getProducts();
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  // ─── CART ─────────────────────────────────────────────────────

  // Cart items for current user — real-time stream
  Stream<List<Map<String, dynamic>>> getCartItems() {
    if (_uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['docId'] = doc.id;
            return data;
          }).toList(),
        );
  }

  // Add item to cart (increments qty if name already exists)
  Future<void> addToCart(Map<String, dynamic> item) async {
    if (_uid.isEmpty) return;
    final existing = await _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .where('name', isEqualTo: item['name'])
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final currentQty = (existing.docs.first.data()['quantity'] ?? 1) as int;
      await existing.docs.first.reference.update({'quantity': currentQty + 1});
    } else {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('cart')
          .add({...item, 'quantity': 1});
    }
  }

  // Update quantity of a cart item (removes if qty reaches 0)
  Future<void> updateCartQuantity(String docId, int quantity) async {
    if (_uid.isEmpty) return;
    final ref = _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(docId);
    if (quantity <= 0) {
      await ref.delete();
    } else {
      await ref.update({'quantity': quantity});
    }
  }

  // Remove a single cart item
  Future<void> removeFromCart(String docId) async {
    if (_uid.isEmpty) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(docId)
        .delete();
  }

  // Delete every item in the cart (used after placing order)
  Future<void> clearCart() async {
    if (_uid.isEmpty) return;
    final batch = _db.batch();
    final docs = await _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .get();
    for (final doc in docs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ─── ORDERS ───────────────────────────────────────────────────

  // Place an order and clear the cart
  Future<void> placeOrder({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double shipping,
    required double total,
    required String paymentMethod,
    required Map<String, String> address,
  }) async {
    if (_uid.isEmpty) return;
    await _db.collection('orders').add({
      'userId': _uid,
      'items': items,
      'subtotal': subtotal,
      'shipping': shipping,
      'total': total,
      'paymentMethod': paymentMethod,
      'address': address,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await clearCart();
  }

  // All orders for current user — real-time stream
  Stream<List<Map<String, dynamic>>> getUserOrders() {
    if (_uid.isEmpty) return const Stream.empty();
    return _db
        .collection('orders')
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['orderId'] = doc.id;
            return data;
          }).toList(),
        );
  }

  // ─── WISHLIST ─────────────────────────────────────────────────

  /// Converts a product name into a safe Firestore document ID.
  String _wishlistDocId(String productName) =>
      productName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();

  /// Stream all wishlisted items for the current user.
  Stream<List<Map<String, dynamic>>> getWishlistItems() {
    if (_uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('wishlist')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['docId'] = doc.id;
            return data;
          }).toList(),
        );
  }

  /// Add a product to the wishlist.
  Future<void> addToWishlist(Map<String, dynamic> item) async {
    if (_uid.isEmpty) return;
    final docId = _wishlistDocId(item['name']?.toString() ?? '');
    await _db
        .collection('users')
        .doc(_uid)
        .collection('wishlist')
        .doc(docId)
        .set({
      ...item,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a product from the wishlist by its Firestore doc ID.
  Future<void> removeFromWishlist(String docId) async {
    if (_uid.isEmpty) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('wishlist')
        .doc(docId)
        .delete();
  }

  /// Returns true if the product is already in the wishlist.
  Future<bool> isInWishlist(String productName) async {
    if (_uid.isEmpty) return false;
    final doc = await _db
        .collection('users')
        .doc(_uid)
        .collection('wishlist')
        .doc(_wishlistDocId(productName))
        .get();
    return doc.exists;
  }

  // ─── PROFILE ──────────────────────────────────────────────────

  // Save or update user profile document
  Future<void> saveProfile({
    required String name,
    required String email,
    String phone = '',
  }) async {
    if (_uid.isEmpty) return;
    await _db.collection('users').doc(_uid).set({
      'name': name,
      'email': email,
      if (phone.isNotEmpty) 'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Fetch user profile once
  Future<Map<String, dynamic>?> getProfile() async {
    if (_uid.isEmpty) return null;
    final doc = await _db.collection('users').doc(_uid).get();
    return doc.data();
  }
}
