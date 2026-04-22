import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_project/views/address_page.dart';
import 'package:flutter_project/views/address_list_page.dart';
import 'package:flutter_project/views/qr_payment_page.dart';

class CartItemData {
  CartItemData({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  final String name;
  final int price;
  final String imageUrl;
  int quantity;
}

class CartPage extends StatefulWidget {
  const CartPage({super.key, required this.cartItems});

  final List<CartItemData> cartItems;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const int _shippingFee = 45;
  Map<String, dynamic>? _address;
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _isLoadingAddress = false);
      return;
    }
    try {
      final response = await Supabase.instance.client
          .from('address')
          .select()
          .eq('user_id', userId)
          .eq('isdefault', true)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _address = response;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  int get _subtotal => widget.cartItems
      .fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get _shipping => widget.cartItems.isEmpty ? 0 : _shippingFee;

  int get _total => _subtotal + _shipping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1EC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Sweet Cake",
          style: TextStyle(color: Colors.brown),
        ),
        leading: const Icon(Icons.menu, color: Colors.brown),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag, color: Colors.brown),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cart Items',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  Text(
                    "${widget.cartItems.length} Items",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (widget.cartItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 42, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 40, color: Colors.brown),
                      SizedBox(height: 10),
                      Text(
                        'ยังไม่มีสินค้าในตะกร้า',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...widget.cartItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _cartItem(
                    name: item.name,
                    price: item.price,
                    imageUrl: item.imageUrl,
                    qty: item.quantity,
                    onAdd: () {
                      setState(() {
                        item.quantity++;
                      });
                    },
                    onRemove: () {
                      setState(() {
                        if (item.quantity > 1) {
                          item.quantity--;
                        } else {
                          widget.cartItems.removeAt(index);
                        }
                      });
                    },
                  );
                }),

              const SizedBox(height: 28),

              /// Address Card
              if (_isLoadingAddress)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_address != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.brown),
                              SizedBox(width: 10),
                              Text(
                                "ที่อยู่สำหรับจัดส่ง",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () async {
                              final selectedAddr = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddressListPage()),
                              );
                              if (selectedAddr != null) {
                                setState(() {
                                  _address = selectedAddr;
                                });
                              }
                            },
                            child: const Text(
                              "เปลี่ยน",
                              style: TextStyle(
                                color: Color(0xFFD8A7B1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      const Divider(height: 25),
                      Text(
                        "${_address!['name']} | โทร: ${_address!['phone']}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${_address!['address']} จ.${_address!['province']} ${_address!['postalcode']}",
                        style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFFD8A7B1), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("ยังไม่มีที่อยู่จัดส่ง", style: TextStyle(color: Colors.brown)),
                      TextButton(
                        onPressed: () async {
                          final selectedAddr = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddressListPage()),
                          );
                          if (selectedAddr != null) {
                            setState(() {
                              _address = selectedAddr;
                            });
                          } else {
                            // If they just added an address but didn't select, fetch default
                            setState(() => _isLoadingAddress = true);
                            _fetchAddress();
                          }
                        },
                        child: const Text("เพิ่มที่อยู่", style: TextStyle(color: Color(0xFFD8A7B1), fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),

              /// Summary Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    _row("Subtotal", _formatCurrency(_subtotal)),
                    _row("Shipping fee", _formatCurrency(_shipping)),
                    const Divider(height: 25),
                    _row("Total", _formatCurrency(_total), bold: true),

                    const SizedBox(height: 20),

                    /// Button
                    GestureDetector(
                      onTap: () {
                        if (widget.cartItems.isEmpty) return;
                        if (_address == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('กรุณาเพิ่มที่อยู่สำหรับจัดส่ง')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QrPaymentPage(
                              totalAmount: _total,
                              cartItems: widget.cartItems,
                              address: _address!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD8A7B1), Color(0xFFC48A97)],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "ดำเนินการสั่งซื้อ →",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "🎟 Have a promo code?",
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// =========================
  /// 🧁 Cart Item Widget
  /// =========================
  Widget _cartItem({
    required String name,
    required int price,
    required String imageUrl,
    required int qty,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          /// Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text("ราคา/ชิ้น ${_formatCurrency(price)}",
                    style: const TextStyle(
                        color: Colors.brown, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          /// Qty
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.remove, size: 18),
                ),
                const SizedBox(width: 10),
                Text(qty.toString()),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onAdd,
                  child: const Icon(Icons.add, size: 18),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Row Summary
  Widget _row(String title, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: bold ? Colors.brown : Colors.black,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    return '฿${amount.toString()}';
  }
}
