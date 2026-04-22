import 'package:flutter/material.dart';
import 'package:flutter_project/views/cart_page.dart';
import 'package:flutter_project/views/custom_page.dart';
import 'package:flutter_project/views/home_page.dart';
import 'package:flutter_project/views/profile_page.dart';

class HomeUi extends StatefulWidget {
  const HomeUi({super.key});

  @override
  State<HomeUi> createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi> {
  int currentIndex = 0; // เก็บ index ของ tab ปัจจุบัน
  final List<CartItemData> _cartItems = [];

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
      ), // หน้า Home
      const CustomPage(), // หน้า Custom Cake
      CartPage(cartItems: _cartItems), // หน้า Cart
      const ProfilePage(), // หน้า Profile
    ];

    return Scaffold(
      body: pages[currentIndex], // แสดงหน้าตาม index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex, // tab ที่ active
        // 🎨 สี
        backgroundColor: Colors.white,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        //----
        onTap: (index) {
          setState(() {
            currentIndex = index; // เปลี่ยนหน้า
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
