// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final supabase = Supabase.instance.client;

  Future<Map<String, Map<String, dynamic>>> _fetchProductsByNames(
    List<String> names,
  ) async {
    final unique = names
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    if (unique.isEmpty) return {};

    final rows = await supabase
        .from('products')
        .select('id, name, price, imageurl, image_url')
        .inFilter('name', unique);

    final map = <String, Map<String, dynamic>>{};
    for (final r in rows as List) {
      final row = (r as Map).cast<String, dynamic>();
      final name = row['name']?.toString();
      if (name != null && name.isNotEmpty) {
        map[name] = row;
      }
    }
    return map;
  }

  List<String> _extractProductNamesFromOrderItems(dynamic itemsRaw) {
    final items = itemsRaw?.toString() ?? '';
    if (items.trim().isEmpty) return const [];

    return items
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .where((e) => !e.toLowerCase().startsWith('custom cake'))
        .toList();
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'รอดำเนินการ':
        color = Colors.orange;
        text = 'รอรับออเดอร์';
        break;
      case 'กำลังเตรียม':
        color = Colors.blue;
        text = 'กำลังจัดเตรียม';
        break;
      case 'จัดส่งแล้ว':
        color = Colors.purple;
        text = 'กำลังจัดส่ง';
        break;
      case 'สำเร็จ':
        color = Colors.green;
        text = 'สำเร็จแล้ว';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "ประวัติการสั่งซื้อ",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: userId == null
          ? const Center(child: Text("กรุณาเข้าสู่ระบบ"))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('orders')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', userId)
                  .order('id', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.pink),
                  );
                }

                final orders = snapshot.data!;
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.history, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "ยังไม่มีประวัติการสั่งซื้อ",
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final productNames = <String>{};
                for (final order in orders) {
                  final names =
                      _extractProductNamesFromOrderItems(order['items']);
                  productNames.addAll(names);
                }

                return FutureBuilder<Map<String, Map<String, dynamic>>>(
                  future: _fetchProductsByNames(productNames.toList()),
                  builder: (context, productsSnapshot) {
                    final productsByName = productsSnapshot.data ?? {};

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final names =
                            _extractProductNamesFromOrderItems(order['items']);
                        final itemsRaw = order['items']?.toString() ?? '';
                        final hasCustom =
                            itemsRaw.toLowerCase().contains('custom cake');

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStatusBadge(
                                      order['status']?.toString() ??
                                          'รอดำเนินการ',
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.pink.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        "#${order['id'] ?? '-'}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink.shade300,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 30,
                                  color: Color(0xFFF5F1EF),
                                  thickness: 1.5,
                                ),
                                const Text(
                                  "รายการที่สั่ง",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (names.isEmpty && !hasCustom)
                                  const Text(
                                    "-",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      height: 1.3,
                                    ),
                                  )
                                else ...[
                                  ...names.map((name) {
                                    final p = productsByName[name];
                                    final imageUrl =
                                        p?['imageurl']?.toString() ??
                                            p?['image_url']?.toString() ??
                                            '';
                                    final price =
                                        (p?['price'] as num?)?.toInt();

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              width: 52,
                                              height: 52,
                                              color: Colors.grey.shade100,
                                              child: imageUrl.isEmpty
                                                  ? Icon(
                                                      Icons.cake,
                                                      color: Colors
                                                          .brown.shade300,
                                                    )
                                                  : Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Icon(
                                                        Icons.broken_image,
                                                        color: Colors
                                                            .grey.shade500,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  price == null
                                                      ? "ไม่พบสินค้าในตาราง products"
                                                      : "฿$price",
                                                  style: TextStyle(
                                                    color:
                                                        Colors.grey.shade700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  if (hasCustom)
                                    Text(
                                      "มีรายการเค้กสั่งทำ (Custom Cake) ในออเดอร์นี้",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.location_on,
                                  "ที่อยู่จัดส่ง",
                                  order['address']?.toString() ?? '-',
                                ),
                                const Divider(
                                  height: 30,
                                  color: Color(0xFFF5F1EF),
                                  thickness: 1.5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "ยอดรวมทั้งหมด",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.brown,
                                      ),
                                    ),
                                    Text(
                                      "฿${order['total_price'] ?? 0}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Color(0xFFC48A97),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.brown, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
