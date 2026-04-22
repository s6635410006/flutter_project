class CartItem {
  final String name; // ชื่อสินค้า
  final int price; // ราคา
  int qty; // จำนวน

  CartItem({
    required this.name,
    required this.price,
    this.qty = 1,
  });
}
