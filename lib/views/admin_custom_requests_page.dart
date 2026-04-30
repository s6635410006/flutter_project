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
                      Text("ขนาด: ${req['size']}"),
                      Text("รสชาติ: ${req['flavor']}"),
                      Text("สี: ${req['colorname']}"),
                      if (req['personalmessage'] != null && req['personalmessage'].toString().isNotEmpty)
                        Text("ข้อความ: ${req['personalmessage']}"),
                      if (req['customdescription'] != null && req['customdescription'].toString().isNotEmpty)
                        Text("รายละเอียด: ${req['customdescription']}", style: const TextStyle(color: Colors.brown)),
                      
                      if (req['referenceimageurl'] != null)
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
