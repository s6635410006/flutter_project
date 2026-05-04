import 'package:flutter/material.dart';
import 'package:flutter_project/views/home_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserNotificationPage extends StatefulWidget {
  const UserNotificationPage({super.key});

  @override
  State<UserNotificationPage> createState() => _UserNotificationPageState();
}

class _UserNotificationPageState extends State<UserNotificationPage> {
  final supabase = Supabase.instance.client;
  
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await supabase.from('custom_requests').update({
        'status': newStatus,
      }).eq('id', id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newStatus == 'confirmed' ? 'ยืนยันออเดอร์แล้ว สินค้าถูกเพิ่มลงตะกร้า' : 'ยกเลิกออเดอร์แล้ว')),
      );

      if (newStatus == 'confirmed' && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const HomeUi(initialTabIndex: 2),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("การประเมินราคา Custom Cake", style: TextStyle(color: Colors.brown)),
        backgroundColor: Colors.pink.shade100,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: user == null
          ? const Center(child: Text("กรุณาเข้าสู่ระบบ"))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('custom_requests')
                  .stream(primaryKey: ['id'])
                  .eq('userid', user.id)
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final allRequests = snapshot.data!;
                final requests = allRequests.where((req) => req['status'] == 'price_quoted').toList();
                
                if (requests.isEmpty) {
                  return const Center(child: Text("ยังไม่มีข้อความแจ้งเตือนใหม่"));
                }

                return ListView.builder(
                  itemCount: requests.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    final id = req['id'];
                    final price = req['quoted_price'] ?? 0;

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.local_offer, color: Colors.pink),
                                SizedBox(width: 8),
                                Text("แอดมินประเมินราคาแล้ว!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const Divider(),
                            _detailRow("ขนาด", (req['size'] ?? '').toString()),
                            _detailRow("รสชาติ", (req['flavor'] ?? '').toString()),
                            _detailRow("สี", (req['colorname'] ?? '').toString()),
                            _detailRow("ท็อปปิ้ง", () {
                              final parts = <String>[];
                              if (req['isfruit'] == true) parts.add('Fruit (+฿20)');
                              if (req['ischocolate'] == true) parts.add('Chocolate (+฿30)');
                              return parts.isEmpty ? 'ไม่เพิ่มท็อปปิ้ง' : parts.join(', ');
                            }()),
                            _detailRow("ข้อความบนเค้ก", (req['personalmessage'] ?? '').toString()),
                            _detailRow("ดีไซน์/รายละเอียด", (req['customdescription'] ?? '').toString()),
                            
                            if (req['referenceimageurl'] != null &&
                                req['referenceimageurl'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(req['referenceimageurl'], height: 100, width: double.infinity, fit: BoxFit.cover),
                                ),
                              ),
                            
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "ราคาประเมิน: ฿$price",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: () => _updateStatus(id, 'cancelled'),
                                    child: const Text("ยกเลิก (Cancel)"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: () => _updateStatus(id, 'confirmed'),
                                    child: const Text("ยืนยันลงตะกร้า"),
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
            ),
    );
  }
}
