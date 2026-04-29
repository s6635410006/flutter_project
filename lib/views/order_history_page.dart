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

  // 🚩 ฟังก์ชันช่วยสร้าง Badge แสดงสถานะออเดอร์
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
      padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      backgroundColor:  Color(0xFFF5F1EF),
      appBar: AppBar(
        backgroundColor:  Color(0xFFF5F1EF),
        elevation: 0,
        centerTitle: true,
        title:  Text(
          "ประวัติการสั่งซื้อ",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // 🚩 เปลี่ยนมาใช้ StreamBuilder เพื่อให้ข้อมูลเด้งตามมือแอดมิน
      body: userId == null
          ? Center(child: Text("กรุณาเข้าสู่ระบบ"))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('orders') // ✅ ใช้ตาราง orders ตามที่คุณเพิ่งตั้งค่า
                  .stream(primaryKey: ['id'])
                  .eq('user_id', userId) // กรองเฉพาะของลูกค้าคนนี้
                  .order('id', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(color: Colors.pink));
                }

                final orders = snapshot.data!;

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("ยังไม่มีประวัติการสั่งซื้อ",
                            style: TextStyle(
                                color: Colors.brown,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin:  EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      elevation: 2,
                      color: Colors.white,
                      child: Padding(
                        padding:  EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 🚩 แสดงสถานะออเดอร์ (จะเปลี่ยนทันทีเมื่อแอดมินกด)
                                _buildStatusBadge(
                                    order['status'] ?? 'รอดำเนินการ'),
                                Container(
                                  padding:  EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.pink.shade50,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text("#${order['id'] ?? '-'}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink.shade300)),
                                ),
                              ],
                            ),
                             Divider(
                                height: 30,
                                color: Color(0xFFF5F1EF),
                                thickness: 1.5),
                            _buildInfoRow(Icons.cake, "รายการสินค้า",
                                order['items'] ?? '-'),
                             SizedBox(height: 12),
                            _buildInfoRow(Icons.location_on, "ที่อยู่จัดส่ง",
                                order['address'] ?? '-'),
                             Divider(
                                height: 30,
                                color: Color(0xFFF5F1EF),
                                thickness: 1.5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Text("ยอดรวมทั้งหมด",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.brown)),
                                Text("฿${order['total_price'] ?? 0}",
                                    style:  TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Color(0xFFC48A97))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // Widget ช่วยจัดระเบียบแถวข้อมูล
  Widget _buildInfoRow(IconData icon, String title, String detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.brown, size: 20),
         SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:  TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.brown)),
               SizedBox(height: 4),
              Text(detail,
                  style:  TextStyle(color: Colors.black87, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
