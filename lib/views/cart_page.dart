// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  const CartPage({
    super.key,
    required this.cartItems,
    this.customOrders = const [],
    this.onRemoveCustomOrder,
  });

  final List<CartItemData> cartItems;
  final List<Map<String, dynamic>> customOrders;
  final Function(int)? onRemoveCustomOrder;

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

//-----สร้าง/เพิ่ม order----------
  Future<void> _createOrder() async {
    final user = Supabase.instance.client.auth.currentUser;

    // ตรวจสอบเงื่อนไขก่อนสั่งซื้อ
    if (user == null || _address == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("กรุณาเลือกที่อยู่จัดส่ง")),
        );
      }
      return;
    }

    String productNames = "";
    try {
      // แก้ไขตาม Error: ใช้ .name เพราะเป็น CartItemData ไม่ใช่ Map
      productNames = widget.cartItems.map((item) => item.name).join(', ');
    } catch (e) {
      return;
    }

    try {

      // 🚩 ตาราง 'orders' ใช้ 'user_id' (มีขีดล่าง)
      await Supabase.instance.client.from('orders').insert({
        'user_id': user.id,
        'status': 'กำลังเตรียม',
        'address':
            '${_address!['address']} ${_address!['province']}\nชื่อผู้รับ: ${_address!['name']} โทร: ${_address!['phone']}',
        'items': productNames,
        'total_price': _total,
        'updated_at': DateTime.now().toIso8601String(),
      });



      // 🚩 ตาราง 'carts' ใช้ 'userid' (ไม่มีขีดล่าง) ตามที่ Supabase แนะนำ
      await Supabase.instance.client
          .from('carts')
          .update({'status': 'ordered'}).eq('userid', user.id);


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("สั่งซื้อสำเร็จแล้ว!")),
        );

        // 🚩 ตรงนี้คุณประชาอาจจะใส่ Navigator.pop(context) หรือไปหน้าประวัติสั่งซื้อได้เลย
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
        );
      }
    }
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

// ----------ส่ง order-------

  int get _subtotal {
    int regularTotal = widget.cartItems
        .fold(0, (sum, item) => sum + (item.price * item.quantity));
    int customTotal = widget.customOrders
        .fold(0, (sum, item) => sum + ((item['price'] as int?) ?? 0));
    return regularTotal + customTotal;
  }

  int get _shipping => (widget.cartItems.isEmpty && widget.customOrders.isEmpty)
      ? 0
      : _shippingFee;

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
          "CAKE EASE",
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
                    "${widget.cartItems.length + widget.customOrders.length} Items",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (widget.cartItems.isEmpty && widget.customOrders.isEmpty)
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
              else ...[
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
                if (widget.customOrders.isNotEmpty) ...[
                  if (widget.cartItems.isNotEmpty) const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Custom Cakes",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...widget.customOrders.map((order) {
                    return _customCakeItem(order);
                  }),
                ],
              ],

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
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5)),
                    ],
                  ),

                  //----------ที่อยู่สำหรับจัดส่ง----------
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
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.brown),
                              ),
                            ],
                          ),

                          //----------ปุ่มเปลี่ยนที่อยู่----------
                          GestureDetector(
                            onTap: () async {
                              final selectedAddr = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AddressListPage()),
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

                      Divider(height: 25),
                      //----------ข้อมูลที่อยู่จัดส่ง----------
                      Text(
                        "${_address!['name']} | โทร: ${_address!['phone']}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "${_address!['address']} จ.${_address!['province']} ${_address!['postalcode']}",
                        style:
                            TextStyle(color: Colors.grey.shade600, height: 1.5),
                      ),
                    ],
                  ),
                )
              else

                //----------ถ้ายังไม่มีที่อยู่จัดส่ง----------
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border:
                        Border.all(color: const Color(0xFFD8A7B1), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("ยังไม่มีที่อยู่จัดส่ง",
                          style: TextStyle(color: Colors.brown)),
                      TextButton(
                        onPressed: () async {
                          final selectedAddr = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddressListPage()),
                          );
                          if (selectedAddr != null) {
                            setState(() {
                              _address = selectedAddr;
                            });
                          } else {
                            setState(() => _isLoadingAddress = true);
                            _fetchAddress();
                          }
                        },
                        child: const Text("เพิ่มที่อยู่",
                            style: TextStyle(
                                color: Color(0xFFD8A7B1),
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),

              //----------รายการสินค้าในตะกร้า----------
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

                    //-----------ปุ่มสั่งซื้อ---------
                    GestureDetector(
                      onTap: () async {
                        // 1. เช็กสินค้าในตะกร้า
                        if (widget.cartItems.isEmpty &&
                            widget.customOrders.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('ไม่มีสินค้าในตะกร้า')),
                          );
                          return;
                        }

                        // 2. เช็กที่อยู่
                        if (_address == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('กรุณาเพิ่มที่อยู่สำหรับจัดส่ง')),
                          );
                          return;
                        }

                        await _createOrder();

                        // 3. บันทึกสำเร็จแล้วพาไปหน้าชำระเงิน
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QrPaymentPage(
                                totalAmount: _total,
                                cartItems: widget.cartItems,
                                customOrders: widget.customOrders,
                                address: _address!,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFD8A7B1),
                              Color.fromARGB(255, 172, 83, 160)
                            ],
                          ),
                        ),
                        child: Center(
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

              SizedBox(height: 10),

              Text(
                "🎟 Have a promo code?",
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }

//------สั่งเค้กเอง---------
  Widget _customCakeItem(Map<String, dynamic> order) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Custom Design Cake",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  Text(
                    _formatCurrency(order['price'] ?? 0),
                    style: TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (widget.onRemoveCustomOrder != null) {
                        widget.onRemoveCustomOrder!(order['id']);
                      }
                    },
                    child:
                        Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ],
          ),
          Divider(),
          _customCakeDetailRow("Size", order['size']),
          _customCakeDetailRow("Flavor", order['flavor']),
          _customCakeDetailRow("Color", order['color_name'] ?? 'ไม่มี'),
          _customCakeDetailRow("Message",
              order['message']?.isEmpty ?? true ? "-" : order['message']),
          if (order['is_fruit'] == true)
            _customCakeDetailRow("Topping", "Fruit (+฿20)"),
          if (order['is_chocolate'] == true)
            _customCakeDetailRow("Topping", "Chocolate (+฿30)"),
        ],
      ),
    );
  }

//-------ดีเทลสั่งเค้กเอง-------
  Widget _customCakeDetailRow(String title, dynamic value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text("$title: ", style: TextStyle(color: Colors.grey)),
          Text(value.toString(), style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  /// -------ตะกร้า-------
  Widget _cartItem({
    required String name,
    required int price,
    required String imageUrl,
    required int qty,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
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

          SizedBox(width: 12),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 6),
                Text("ราคา/ชิ้น ${_formatCurrency(price)}",
                    style: TextStyle(
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
