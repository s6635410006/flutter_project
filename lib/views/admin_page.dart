// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _linemanController = TextEditingController();
  final Map<String, String> _nameCache = {};
  

  Future<String> _getCustomerNameCached(String userId) async {
    if (userId.isEmpty) return 'ไม่ทราบชื่อ';

    if (_nameCache.containsKey(userId)) {
      return _nameCache[userId]!;
    }

    try {
      final response = await supabase
          .from('profiles')
          .select('username')
          .eq('id', userId)
          .maybeSingle();

      final name = response?['username'] ?? 'ไม่มีชื่อ';
      _nameCache[userId] = name;

      return name;
    } catch (e) {
      return 'โหลดไม่สำเร็จ';
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await supabase
          .from('orders')
          .update({'status': newStatus}).eq('id', orderId);

      debugPrint("อัปเดต $orderId -> $newStatus");
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    try {
      await supabase.from('orders').delete().eq('id', orderId);
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  void _showDeleteDialog(String oId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ยืนยันการลบ"),
        content: Text("ลบบิลนี้ถาวรใช่หรือไม่"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              _deleteOrder(oId);
              Navigator.pop(context);
            },
            child: Text(
              "ลบบิล",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("รายการออเดอร์"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('orders')
            .stream(primaryKey: ['id']).order('updated_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;

          if (orders.isEmpty) {
            return Center(child: Text("ไม่มีออเดอร์"));
          }

          return ListView.builder(
            itemCount: orders.length,
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final order = orders[index];

              final String oId = order['id'].toString();
              final String status = order['status'] ?? 'กำลังเตรียม';

              return Container(
                key: ValueKey(oId),
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.black12,
                    )
                  ],
                ),

                //-----จัดการปุ่มออเดอร์------
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #$oId",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: _getCustomerNameCached(
                        order['user_id'] ?? '',
                      ),
                      builder: (context, snapshot) {
                        return Text(
                          "ลูกค้า: ${snapshot.data ?? 'กำลังโหลด...'}",
                        );
                      },
                    ),
                    SizedBox(height: 6),
                    Text("ที่อยู่: ${order['address'] ?? '-'}"),
                    Text("รายการ: ${order['items'] ?? '-'}"),
                    Text("รวม: ฿${order['total_price'] ?? 0}"),
                    Column(
                      children: [
                        TextField(
                          controller: _linemanController,
                          decoration: InputDecoration(
                            hintText:
                                "กรอกลิงก์ติดตามการเดินทาง/ติดต่อลูกค้า ...",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send, color: Colors.green),
                              onPressed: () {
                                // ส่งลิงก์ไปที่แชทของลูกค้าคนนี้ทันที
                                _sendLinemanLink(
                                  order['user_id'],
                                  oId,
                                  _linemanController.text,
                                );
                                _linemanController.clear();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _btn("กำลังเตรียม", Colors.orange, oId, status),
                        SizedBox(width: 5),
                        _btn("กำลังจัดส่ง", Colors.blue, oId, status),
                        SizedBox(width: 5),
                        _btn("เสร็จแล้ว", Colors.green, oId, status),
                        SizedBox(width: 5),
                        _btn("ลบบิล", Colors.red, oId, status),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _sendLinemanLink(
    String? customerId,
    String orderId,
    String link,
  ) async {
    if (link.trim().isEmpty) return;
    if (customerId == null || customerId.isEmpty) return;

    try {
      final myId = supabase.auth.currentUser!.id;

      await supabase.from('messages').insert({
        'sender_id': myId,
        'receiver_id': customerId,
        'content':
            " ออเดอร์ A${orderId.padLeft(3, '0')}: $link",
        'is_read': false,
        'is_from_admin': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ส่งสำเร็จ")),
      );
    } catch (e) {
      debugPrint("Send Error: $e");
    }
  }

  Widget _btn(
    String label,
    Color color,
    String oId,
    String current,
  ) {
    final bool selected = current == label;
    final bool isDelete = label == "ลบบิล";

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isDelete) {
            _showDeleteDialog(oId);
          } else {
            _updateStatus(oId, label);
          }
        },
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color : color.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
