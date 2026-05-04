import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    super.key,
    required this.onOrderCake,
    required this.onOpenCart,
  });

  final void Function({
    required String name,
    required int price,
    required String imageUrl,
  }) onOrderCake;
  final VoidCallback onOpenCart;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "รายการโปรด",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink.shade100,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.brown),
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text("กรุณาเข้าสู่ระบบ"))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('favorites')
                  .stream(primaryKey: ['id'])
                  .eq('userid', user.id)
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                final rows = snapshot.data ?? const <Map<String, dynamic>>[];
                final productIds = rows
                    .map((e) => e['productid'])
                    .where((id) => id != null)
                    .toList();

                if (snapshot.connectionState == ConnectionState.waiting &&
                    rows.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productIds.isEmpty) {
                  return const Center(child: Text("ยังไม่มีรายการโปรด"));
                }

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: supabase
                      .from('products')
                      .select()
                      .inFilter('id', productIds),
                  builder: (context, productsSnap) {
                    if (!productsSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products = productsSnap.data!;

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final p = products[index];
                        final name = p['name']?.toString() ?? '';
                        final price = (p['price'] as num?)?.toInt() ?? 0;
                        final imageUrl = p['imageurl']?.toString() ??
                            p['image_url']?.toString() ??
                            '';

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  imageUrl,
                                  width: 74,
                                  height: 74,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 74,
                                    height: 74,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '฿$price',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  onOrderCake(
                                    name: name,
                                    price: price,
                                    imageUrl: imageUrl,
                                  );
                                  onOpenCart();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF7A4D60),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "ORDER",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
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

