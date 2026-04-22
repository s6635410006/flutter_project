import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _provinceController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _provinceController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "ที่อยู่จัดส่ง",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "กรอกที่อยู่สำหรับจัดส่งสินค้า",
              style: TextStyle(
                fontSize: 16,
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: "ชื่อ-นามสกุล",
              hint: "กรอกชื่อ-นามสกุลผู้รับ",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _phoneController,
              label: "เบอร์โทรศัพท์",
              hint: "กรอกเบอร์โทรศัพท์",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _addressController,
              label: "รายละเอียดที่อยู่",
              hint: "บ้านเลขที่, หมู่, ซอย, ถนน, แขวง/ตำบล, เขต/อำเภอ",
              icon: Icons.home_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _provinceController,
                    label: "จังหวัด",
                    hint: "กรอกจังหวัด",
                    icon: Icons.map_outlined,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTextField(
                    controller: _zipController,
                    label: "รหัสไปรษณีย์",
                    hint: "กรอกรหัส",
                    icon: Icons.local_post_office_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  final name = _nameController.text.trim();
                  final phone = _phoneController.text.trim();
                  final address = _addressController.text.trim();
                  final province = _provinceController.text.trim();
                  final zip = _zipController.text.trim();

                  if (name.isEmpty || phone.isEmpty || address.isEmpty || province.isEmpty || zip.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
                    );
                    return;
                  }

                  setState(() => _isLoading = true);
                  try {
                    final userId = Supabase.instance.client.auth.currentUser?.id;
                    if (userId == null) throw Exception('ไม่พบข้อมูลผู้ใช้ กรุณาล็อกอินใหม่');

                    await Supabase.instance.client.from('address').insert({
                      'user_id': userId,
                      'name': name,
                      'phone': phone,
                      'address': address,
                      'province': province,
                      'postalcode': zip,
                      'isdefault': true,
                    });

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('บันทึกที่อยู่เรียบร้อยแล้ว')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')),
                    );
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD8A7B1), Color(0xFFC48A97)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20, width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
                          "บันทึกที่อยู่",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: Colors.grey.shade500)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Icon(icon, color: Colors.grey.shade500),
                  ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }
}
