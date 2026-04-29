import 'package:flutter/material.dart';
import 'package:flutter_project/views/cart_page.dart';
import 'package:flutter_project/views/CustomerChatPage.dart';
import 'package:flutter_project/views/custom_page.dart';
import 'package:flutter_project/views/home_page.dart';
import 'package:flutter_project/views/profile_page.dart';
import 'package:flutter_project/views/admin_inbox_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeUi extends StatefulWidget {
  const HomeUi({super.key});

  @override
  State<HomeUi> createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi> {
  bool _isAdmin = false;
  int currentIndex = 0;
  final List<CartItemData> _cartItems = [];

  Future<void> _checkUserRole() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        // 3. ดึงข้อมูลจากตาราง profiles
        final data = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single();

        if (data['role'] == 'admin') {
          setState(() {
            _isAdmin = true;
          });
        } else {
          setState(() {
            _isAdmin = false;
          });
        }
      } catch (e) {
        debugPrint("Error fetching role: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // 🚩 สั่งให้เช็กทันทีที่หน้าจอโหลดเสร็จ
  }

  void _openCartTab() {
    setState(() {
      currentIndex = 2;
    });
  }

  void _addToCart({
    required String name,
    required int price,
    required String imageUrl,
  }) {
    final existingIndex = _cartItems.indexWhere((item) => item.name == name);
    setState(() {
      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(
          CartItemData(
              name: name, price: price, imageUrl: imageUrl, quantity: 1),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final pages = [
      HomePage(
        
        onOrderCake: _addToCart,
        onOpenCart: _openCartTab,
      ),
      
       CustomPage(),
      CartPage(cartItems: _cartItems),
       ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],

      // 2. เพิ่มปุ่มลอย (FloatingActionButton) สำหรับแชท
      floatingActionButton: FloatingActionButton(
        backgroundColor:  Color(0xFF8B5E6B), // สีชมพูเดิม
        onPressed: () {
          
          if (_isAdmin) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  AdminInboxPage()),
              
            );
            
          } else {
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  CustomerChatPage(
                  adminId: '0efef310-8e42-4f73-94b4-e7c90dc8acb6',
                  adminName: 'Admin',
                ),
              ),
            );
          }
        },
        child:  Icon(Icons.chat_bubble, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.pink,
        unselectedItemColor:  Color.fromARGB(255, 134, 132, 132),
        type: BottomNavigationBarType
            .fixed, // เพิ่มเพื่อให้ไอคอนไม่ขยับเวลาเปลี่ยนหน้า
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.cake), label: "Custom"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
