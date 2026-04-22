// ignore_for_file: sort_child_properties_last

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_project/views/address_page.dart';
import 'package:flutter_project/views/login_ui.dart';
import 'package:flutter_project/views/payment_method_page.dart';
import 'package:flutter_project/views/order_history_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// 📊 Info Box
Widget infoBox(String title, String value) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.brown,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
      ],
    ),
  );
}

// ⚙️ Setting Item (รายการเมนูตั้งค่า)
Widget settingItem(IconData icon, String title, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
          ),
        ],
      ),
    ),
  );
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _profileImageBytes;
  String _displayName = 'Sweet User';
  String _displayEmail = 'sweet.user@patisserie.com';
  bool _isProfileLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileFromSupabase();
  }

  Future<void> _loadProfileFromSupabase() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _isProfileLoading = false;
      });
      return;
    }

    try {
      final profile = await client
          .from('profiles')
          .select('username, email')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        _displayName = (profile?['username'] as String?)?.trim().isNotEmpty ==
                true
            ? profile!['username'] as String
            : (user.userMetadata?['username'] as String?) ?? 'Sweet User';
        _displayEmail =
            (profile?['email'] as String?) ?? user.email ?? 'no-email';
        _isProfileLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _displayName =
            (user.userMetadata?['username'] as String?) ?? _displayName;
        _displayEmail = user.email ?? _displayEmail;
        _isProfileLoading = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final XFile? selectedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (selectedImage == null) return;
    final imageBytes = await selectedImage.readAsBytes();

    setState(() {
      _profileImageBytes = imageBytes;
    });
  }

  Future<void> _handleLogout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginUi()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F1EF),
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F1EF),
        elevation: 0,
        title: Text(
          'Sweet Cake',
          style: TextStyle(
            color: Colors.brown,
          ),
        ),
        centerTitle: true,
        leading: Icon(Icons.menu, color: Colors.brown),
        actions: [
          Icon(Icons.shopping_bag, color: Colors.brown),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 Avatar + Member
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: _profileImageBytes != null
                              ? Image.memory(
                                  _profileImageBytes!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: GestureDetector(
                          onTap: _pickProfileImage,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade200,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.pink.shade200,
                    ),
                    child: Text(
                      'Gold member',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (_isProfileLoading) ...[
                    const SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    Text(
                      _displayName,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(_displayEmail),
                  ],
                  SizedBox(
                    height: 20,
                  ),
                  // 📊 Points + Coupons

                  SizedBox(
                    height: 20,
                  ),
                  // ⚙️ Settings
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Account Settings',
                      style: TextStyle(
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  settingItem(Icons.history, "ประวัติการสั่งซื้อ", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderHistoryPage(),
                      ),
                    );
                  }),
                  settingItem(Icons.person, "แก้ไขข้อมูลส่วนตัว", () {}),
                  settingItem(Icons.location_on, "ที่อยู่จัดส่ง", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressPage(),
                      ),
                    );
                  }),
                  settingItem(Icons.credit_card, "วิธีชำระเงิน", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentMethodPage(),
                      ),
                    );
                  }),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade200,
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Sweet Cake App Version 2.4.0",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
