import 'package:flutter/material.dart';
import 'package:flutter_project/views/admin_chat_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminInboxPage extends StatelessWidget {
  const AdminInboxPage({super.key});

  // 1. ฟังก์ชันดึงข้อมูลโปรไฟล์ (ชื่อและรูป)
  Future<Map<String, dynamic>> _getCustomerInfo(String userId) async {
    final supabase = Supabase.instance.client;
    try {
      final data = await supabase
          .from('profiles')
          .select('username, avatar_url')
          .eq('id', userId)
          .maybeSingle();
      return data ?? {'username': 'ลูกค้าทั่วไป', 'avatar_url': null};
    } catch (e) {
      return {'username': 'โหลดชื่อไม่สำเร็จ', 'avatar_url': null};
    }
  }

  // 2. ฟังก์ชันดึงรหัสออเดอร์ที่ลูกค้าคนนี้เคยสั่ง
  Future<String> _getCustomerOrders(String userId) async {
    final supabase = Supabase.instance.client;
    try {
      final List<dynamic> data = await supabase
          .from('orders')
          .select('id')
          .eq('user_id', userId);
      
      if (data.isEmpty) return "ไม่มีประวัติการสั่งซื้อ";
      
      // แปลง ID เป็นรูปแบบ A001, A002 แล้วต่อกันเป็นข้อความ
      final orderIds = data.map((o) => "A${o['id'].toString().padLeft(3, '0')}").join(", ");
      return "ออเดอร์: $orderIds";
    } catch (e) {
      return "ไม่สามารถโหลดข้อมูลออเดอร์ได้";
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("รายการแชทลูกค้า", 
          style: TextStyle(color: Color(0xFF6D4C41), fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 230, 176, 214),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('messages')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final messages = snapshot.data!;
          final myId = supabase.auth.currentUser?.id ?? '';
          final Map<String, Map<String, dynamic>> customers = {};
          final Map<String, int> unreadByCustomer = {};

          for (var m in messages) {
            bool isFromAdmin = m['is_from_admin'] ?? false;
            String cId = isFromAdmin ? (m['receiver_id'] ?? '') : (m['sender_id'] ?? '');
            if (cId.isNotEmpty && !customers.containsKey(cId)) {
              customers[cId] = m;
            }

            // count unread incoming messages (customer -> admin)
            if (myId.isNotEmpty &&
                (m['receiver_id']?.toString() ?? '') == myId &&
                (m['is_from_admin'] ?? false) == false &&
                (m['is_read'] == true ? false : true)) {
              final cid = m['sender_id']?.toString() ?? '';
              if (cid.isNotEmpty) {
                unreadByCustomer[cid] = (unreadByCustomer[cid] ?? 0) + 1;
              }
            }
          }

          final list = customers.values.toList();
          if (list.isEmpty) return const Center(child: Text("ยังไม่มีข้อความเข้า"));

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              bool isFromAdmin = item['is_from_admin'] ?? false;
              final String cId = isFromAdmin ? (item['receiver_id'] ?? '') : (item['sender_id'] ?? '');

              // ใช้ Future.wait เพื่อดึงข้อมูลทั้ง 2 อย่างพร้อมกัน
              return FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  _getCustomerInfo(cId),
                  _getCustomerOrders(cId),
                ]),
                builder: (context, infoSnapshot) {
                  final profile = infoSnapshot.data?[0] ?? {'username': 'กำลังโหลด...', 'avatar_url': null};
                  final orderRef = infoSnapshot.data?[1] ?? 'กำลังโหลดออเดอร์...';
                  final unread = unreadByCustomer[cId] ?? 0;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color.fromARGB(255, 245, 225, 240),
                        // 🚩 แสดงรูปโปรไฟล์จริง ถ้าไม่มีให้โชว์ไอคอนคน
                        backgroundImage: profile['avatar_url'] != null 
                            ? NetworkImage(profile['avatar_url']) 
                            : null,
                        child: profile['avatar_url'] == null 
                            ? const Icon(Icons.person, color: Color(0xFF6D4C41)) 
                            : null,
                      ),
                      title: Text(
                        profile['username'], // 🚩 แสดงชื่อจริงจากตาราง profiles
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(item['content'] ?? "ส่งรูปภาพ", maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          // 🚩 แสดงรหัสออเดอร์ (อ้างอิง)
                          Text(
                            orderRef, 
                            style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (unread > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                unread > 99 ? '99+' : '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminChatPage(
                            customerId: cId,
                            customerName: profile['username'],
                            customerAvatarUrl: profile['avatar_url']?.toString(),
                          ),
                        ),
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
}