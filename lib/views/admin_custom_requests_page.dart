import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCustomRequestsPage extends StatefulWidget {
  const AdminCustomRequestsPage({super.key});

  @override
  State<AdminCustomRequestsPage> createState() => _AdminCustomRequestsPageState();
}

class _AdminCustomRequestsPageState extends State<AdminCustomRequestsPage> {
  final supabase = Supabase.instance.client;
  // Map to store controllers for each request
  final Map<String, TextEditingController> _priceControllers = {};
  
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

  Future<void> _submitPrice(String id, String priceText) async {
    final price = int.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกราคาให้ถูกต้อง')),
      );
      return;
    }

    try {
      await supabase.from('custom_requests').update({
        'quoted_price': price,
        'status': 'price_quoted',
      }).eq('id', id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งราคาประเมินให้ลูกค้าแล้ว')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("ประเมินราคา Custom Cake", style: TextStyle(color: Colors.brown)),
        backgroundColor: Colors.pink.shade100,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('custom_requests')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allRequests = snapshot.data!;
          final requests = allRequests.where((req) => req['status'] == 'pending_approval').toList();
          if (requests.isEmpty) {
            return const Center(child: Text("ไม่มีรายการรอประเมินราคา"));
          }

          return ListView.builder(
            itemCount: requests.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final req = requests[index];
              final id = req['id'];
              
              if (!_priceControllers.containsKey(id)) {
                _priceControllers[id] = TextEditingController();
              }

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Request #${req['id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                          padding: const EdgeInsets.only(top: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(req['referenceimageurl'], height: 150, width: double.infinity, fit: BoxFit.cover),
                          ),
                        ),
                        
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _priceControllers[id],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "ใส่ราคาประเมิน (บาท)",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade300,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            ),
                            onPressed: () => _submitPrice(id, _priceControllers[id]!.text),
                            child: const Text("ส่งราคา"),
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
