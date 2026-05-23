import 'package:flutter/material.dart';
import 'services/firestore_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double total;

  const CheckoutPage({
    super.key,
    this.cartItems = const [],
    this.subtotal  = 2199.00,
    this.total     = 2249.00,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = 'Card';
  bool   _isPlacingOrder  = false;

  final _nameController    = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController    = TextEditingController();
  final _stateController   = TextEditingController();
  final _zipController     = TextEditingController();

  final _firestoreService = FirestoreService();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  // ─── PLACE ORDER ─────────────────────────────────────────────
  Future<void> _handlePlaceOrder() async {
    final name    = _nameController.text.trim();
    final address = _addressController.text.trim();
    final city    = _cityController.text.trim();
    final state   = _stateController.text.trim();
    final zip     = _zipController.text.trim();

    if (name.isEmpty || address.isEmpty || city.isEmpty ||
        state.isEmpty || zip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all shipping fields.'),
          backgroundColor: Color(0xFFAC8A2E),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    await _firestoreService.placeOrder(
      items: widget.cartItems,
      subtotal: widget.subtotal,
      shipping: widget.total - widget.subtotal,
      total: widget.total,
      paymentMethod: _selectedPayment,
      address: {
        'name':    name,
        'address': address,
        'city':    city,
        'state':   state,
        'zip':     zip,
      },
    );

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed successfully!'),
        backgroundColor: Color(0xFFAC8A2E),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate back to Home after order
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildStepper(),
            const SizedBox(height: 30),

            // ── Shipping Address ──
            const Text(
              'Shipping Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField('Full Name',    _nameController),
            const SizedBox(height: 12),
            _buildTextField('Address',      _addressController),
            const SizedBox(height: 12),
            _buildTextField('City',         _cityController),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('State', _stateController)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Zip',   _zipController)),
              ],
            ),

            const SizedBox(height: 30),

            // ── Payment Methods ──
            const Text(
              'Payment methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _paymentOption(
                        'Card', Icons.credit_card_rounded,
                        _selectedPayment == 'Card')),
                const SizedBox(width: 12),
                Expanded(
                    child: _paymentOption(
                        'Cash', Icons.payments_outlined,
                        _selectedPayment == 'Cash')),
              ],
            ),

            const SizedBox(height: 30),

            // ── Summary ──
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 12),
            _summaryRow('Subtotal',
                '\$${widget.subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFFD4B06A), thickness: 0.5),
            const SizedBox(height: 8),
            _summaryRow('Total',
                '\$${widget.total.toStringAsFixed(2)}',
                isTotal: true),

            const SizedBox(height: 30),

            // ── Place Order Button ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : _handlePlaceOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAC8A2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  elevation: 0,
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle(Icons.check, 'Shipping',
            isActive: true, isCompleted: true),
        _stepLine(),
        _stepCircle(null, 'Payment', isActive: true),
        _stepLine(),
        _stepCircle(null, 'Review'),
      ],
    );
  }

  Widget _stepCircle(IconData? icon, String label,
      {bool isActive = false, bool isCompleted = false}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.black : Colors.white,
            border:
                Border.all(color: const Color(0xFFD4B06A), width: 1),
          ),
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 20)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
        if (label == 'Payment') ...[
          const SizedBox(height: 4),
          Container(
              width: 25,
              height: 4,
              color: const Color(0xFFAC8A2E)),
        ]
      ],
    );
  }

  Widget _stepLine() {
    return Container(
      width: 60,
      height: 2,
      color: Colors.black,
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color(0xFFD4B06A), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color(0xFFAC8A2E), width: 1.5),
        ),
      ),
    );
  }

  Widget _paymentOption(
      String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = label),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFFD4B06A), width: 1),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.black, size: 24),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ],
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Container(
                width: 30,
                height: 3,
                color: const Color(0xFFAC8A2E)),
          ]
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight:
                isTotal ? FontWeight.bold : FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight:
                isTotal ? FontWeight.bold : FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
