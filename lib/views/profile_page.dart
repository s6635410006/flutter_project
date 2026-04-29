//---------หน้าโปรไฟล์---------

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_project/views/address_page.dart';
import 'package:flutter_project/views/login_ui.dart';
import 'package:flutter_project/views/payment_method_page.dart';
import 'package:flutter_project/views/order_history_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "package:flutter_project/views/admin_page.dart";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _profileImageBytes;
  String? _avatarUrl;
  String _email = '';
  String _displayName = 'กำลังโหลด...';
  bool _isProfileLoading = true;
  bool _isAdmin = false; // ✨ เพิ่มตัวแปรเช็คสิทธิ์แอดมิน

  @override
  void initState() {
    super.initState();
    _loadProfileFromSupabase();
  }

  Future<void> _loadProfileFromSupabase() async {
    final client = Supabase.instance.client;
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (mounted) setState(() => _isProfileLoading = false);
      return;
    }

    try {
      final profile = await client
          .from('profiles')
          .select('username, email, avatar_url, role')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        _displayName = profile?['username'] ?? 'Guest User';
        _email = profile?['email'] ?? user.email ?? '';
        _avatarUrl = profile?['avatar_url'];
        _isAdmin = profile?['role'] == 'admin';

        _isProfileLoading = false;
      });
    } catch (e) {
      debugPrint(
          'Error loading profile: $e'); // ✅ ใช้ debugPrint แทน print จะหายเหลือง
      if (mounted) setState(() => _isProfileLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    final XFile? selectedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (selectedImage == null) return;

    try {
      final imageBytes = await selectedImage.readAsBytes();
      final fileNameRaw = selectedImage.name;
      final fileExt = fileNameRaw.split('.').last.toLowerCase();
      final actualContentType = 'image/$fileExt';
      final storagePath = '${user.id}.$fileExt';

      await client.storage.from('avatars').uploadBinary(
            storagePath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: actualContentType,
            ),
          );

      final String rawImageUrl =
          client.storage.from('avatars').getPublicUrl(storagePath);

      final String imageUrlWithCacheBuster =
          '$rawImageUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      await client.from('profiles').update({
        'avatar_url': imageUrlWithCacheBuster,
      }).eq('id', user.id);

      setState(() {
        _profileImageBytes = imageBytes;
        _avatarUrl = imageUrlWithCacheBuster;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปเดตรูปโปรไฟล์สำเร็จ!')),
        );
      }
    } catch (e) {
      debugPrint('Upload Error Detailed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('อัปโหลดล้มเหลว: $e')),
        );
      }
    }
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

  Widget settingItem(IconData icon, String title, VoidCallback onTap,
      {Color iconColor = Colors.brown, Color textColor = Colors.black}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/bg_pattern.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.85),
            BlendMode.lighten,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Cake Ease', style: TextStyle(color: Colors.brown)),
        centerTitle: true,
        leading: const Icon(Icons.menu, color: Colors.brown),
        actions: const [
          Icon(Icons.shopping_bag, color: Colors.brown),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 Avatar Section
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
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: _profileImageBytes != null
                              ? Image.memory(_profileImageBytes!,
                                  fit: BoxFit.cover)
                              : (_avatarUrl != null
                                  ? Image.network(
                                      _avatarUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.person,
                                                  size: 50,
                                                  color: Colors.white),
                                    )
                                  : const Icon(Icons.person,
                                      size: 50, color: Colors.white)),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade200,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.add,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.pink.shade200,
                    ),
                    child: Text('Gold member',
                        style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(height: 10),
                  if (_isProfileLoading)
                    CircularProgressIndicator()
                  else ...[
                    Text(
                      _displayName,
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Text(_email),
                  ],
                ],
              ),
            ),
            SizedBox(height: 30),

            // ⚙️ Account Settings
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Account Settings',
                  style: TextStyle(color: Colors.brown)),
            ),
            SizedBox(height: 10),

// ---------- ปุ่มพิเศษสำหรับ Admin เท่านั้น ------------------
            if (_isAdmin)
              settingItem(
                Icons.admin_panel_settings,
                "จัดการออเดอร์ร้านค้า (Admin)",
                () {
                  // ✅ 1. เช็กก่อนว่า User ยัง Login อยู่ไหม เพื่อกันแอปพัง
                  final user = Supabase.instance.client.auth.currentUser;
                  if (user == null) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminPage(),
                    ),
                  );
                  debugPrint("ไปหน้าจัดการร้านค้าเรียบร้อย");
                },
                iconColor: Colors.pink.shade300,
                textColor: Colors.pink.shade300,
              ),
            settingItem(Icons.history, "ประวัติการสั่งซื้อ", () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => OrderHistoryPage()));
            }),
            settingItem(Icons.person, "แก้ไขข้อมูลส่วนตัว", () {}),
            settingItem(Icons.location_on, "ที่อยู่จัดส่ง", () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => AddressPage()));
            }),
            settingItem(Icons.credit_card, "วิธีชำระเงิน", () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => PaymentMethodPage()));
            }),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade200,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _handleLogout,
                icon: Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Cake Ease App Version 2.4.0",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    ));
  }
}
