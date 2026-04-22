import 'package:flutter/material.dart';
import 'package:flutter_project/views/home_ui.dart';
import 'package:flutter_promptpay/flutter_promptpay.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_project/views/cart_page.dart';

class QrPaymentPage extends StatefulWidget {
  final int totalAmount;
  final List<CartItemData> cartItems;
  final Map<String, dynamic> address;

  const QrPaymentPage({
    super.key, 
    required this.totalAmount,
    required this.cartItems,
    required this.address,
  });

  @override
  State<QrPaymentPage> createState() => _QrPaymentPageState();
}

class _QrPaymentPageState extends State<QrPaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1EC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "ชำระเงิน (QR PromptPay)",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "สแกนเพื่อชำระเงิน",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "ยอดชำระ: ฿${widget.totalAmount}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC48A97),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Dynamic PromptPay QR Code
                      Container(
                        width: 220,
                        height: 220,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.brown.withOpacity(0.3), width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: PromptPayQrImageView.mobileNumber(
                          accountNumber: "0812345678", // TODO: เปลี่ยนเป็นเบอร์พร้อมเพย์ของร้าน
                          amount: widget.totalAmount.toDouble(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "ชื่อบัญชี: นาย ภูริทัต พิมพิศัย",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "บัญชี: xxx-x-x5055-x",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Confirm button
                GestureDetector(
                  onTap: () async {
                    await _saveOrderToSupabase();
                  },
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD8A7B1), Color(0xFFC48A97)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD8A7B1).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "ฉันได้ชำระเงินเรียบร้อยแล้ว",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isSaving = false;

  Future<void> _saveOrderToSupabase() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final addr = widget.address;
      final addressText = "${addr['name']} โทร: ${addr['phone']}\n${addr['address']} จ.${addr['province']} ${addr['postalcode']}";
      
      final itemsText = widget.cartItems
          .map((item) => "${item.name} x${item.quantity}")
          .join(", ");

      await Supabase.instance.client.from('carts').insert({
        'userid': userId,
        'address': addressText,
        'item': itemsText,
        'totalprice': widget.totalAmount,
      });

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text(
          "ชำระเงินสำเร็จ!\nขอบคุณสำหรับการสั่งซื้อค่ะ",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD8A7B1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeUi()),
                (route) => false,
              );
            },
            child: const Text("กลับสู่หน้าหลัก", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
