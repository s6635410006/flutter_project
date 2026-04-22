import 'package:flutter/material.dart';

class CustomPage extends StatefulWidget {
  const CustomPage({super.key});

  @override
  State<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  // เก็บค่าที่ผู้ใช้เลือก
  int selectedSize = 0; // index ขนาด
  int selectedFlavor = 1; // index รส
  int selectedColor = 0; // index สี
  bool isChocolate = true; // topping chocolate
  bool isFruit = false; // topping fruit

  // รายการตัวเลือก
  List<String> sizes = ["1 ปอนด์", "2 ปอนด์", "3 ปอนด์"];
  List<int> prices = [350, 550, 750];
  List<String> flavors = ["ช็อกโกแลต", "วานิลลา", "สตรอว์เบอร์รี่"];

  // สี frosting
  List<Color> colors = [
    Colors.pink.shade100,
    Colors.yellow.shade200,
    Colors.orange.shade200,
    Colors.pink.shade200,
    Colors.brown.shade200,
  ];

  // 🔥 ฟังก์ชันคำนวณราคา
  // -----------------------------
  int calculatePrice() {
    int total = prices[selectedSize];
    // ราคาเริ่มต้นจากขนาด

    if (isFruit) total += 20;
    // ถ้าเลือก fruit เพิ่ม 20

    if (isChocolate) total += 30;
    // ถ้าเลือก chocolate เพิ่ม 30

    return total;
  }

  //คือการ สร้างตัวควบคุม (controller) สำหรับ TextField เพื่อใช้ “เก็บและจัดการข้อความที่ผู้ใช้พิมพ์”
  TextEditingController messageCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    int totalPrice = calculatePrice();
    return Scaffold(
      backgroundColor: Color(0xFFF5F1EC), // สีพื้นหลังครีม
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F1EC),
        elevation: 0,
        title: Text(
          "Sweet Cake",
          style: TextStyle(color: Colors.brown),
        ),
        centerTitle: true,
        leading: Icon(Icons.menu, color: Colors.brown),
        actions: [
          Icon(Icons.shopping_bag, color: Colors.brown),
          SizedBox(width: 10),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16), //ระยะขอบหน้า
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //รูปเค้ก
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(25),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/c4.jpg',
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    //กล่อง previews ลอย
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "LIVE PREVIEWS",
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              "Your Artisan Creation",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //หัวข้อ
              Text("CUSTOM DESIGNER",
                  style: TextStyle(
                    color: Colors.brown,
                  )),
              SizedBox(
                height: 5,
              ),

              Text(
                "Design Your\nSignature Cake",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // 🔘 เลือกขนาด
              Text(
                'Choose Size',
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: List.generate(sizes.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(sizes[index]),
                      selected: selectedSize == index,
                      selectedColor: Colors.pink.shade100,
                      onSelected: (_) {
                        setState(() {
                          selectedSize = index; // เปลี่ยนค่า
                        });
                      },
                    ),
                  );
                }),
              ),
              SizedBox(
                height: 20,
              ),
              // 🍰 เลือกรส
              Text(
                "Cake Flavor",
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: List.generate(flavors.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 10),
                    //-----
                    child: ChoiceChip(
                      label: Text(flavors[index]),
                      selected: selectedFlavor == index,
                      selectedColor: Colors.pink.shade100,
                      //------
                      onSelected: (_) {
                        setState(() {
                          selectedFlavor = index;
                        });
                      },
                    ),
                  );
                }),
              ),
              SizedBox(
                height: 20,
              ),
              // 🎨 COLOR
              Text(
                "Frosting Color",
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: List.generate(
                  colors.length,
                  (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = index;
                        });
                      },
                      //----
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        width: 40,
                        height: 40,
                        //----
                        decoration: BoxDecoration(
                          color: colors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == index
                                ? Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // ✍️ MESSAGE
              Text(
                "Personal Message",
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: messageCtrl,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: "ข้อความบนเค้ก",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // 🍓 TOPPING
              Text(
                "Premium Toppings",
              ),
              SizedBox(
                height: 20,
              ),
              SwitchListTile(
                title: Text("Fruit +฿20"),
                value: isFruit,
                onChanged: (val) {
                  setState(() {
                    isFruit = val;
                  });
                },
              ),
              //----
              SwitchListTile(
                title: Text("Chocolate +฿30"),
                value: isChocolate,
                onChanged: (val) {
                  setState(() {
                    isChocolate = val;
                  });
                },
              ),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),

      // 💰 BOTTOM BAR
      bottomSheet: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30), // โค้งทุกด้าน
          ),
          child: Row(
            children: [
              /// 💰 PRICE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "ESTIMATED TOTAL",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          "฿${totalPrice + 40}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "฿$totalPrice",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B5E57),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// 🛒 BUTTON
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7B5E57),
                  padding: EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    Text(
                      "เพิ่มลง\nตะกร้า",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 สำคัญมาก (เพิ่มเข้ามา) คือ ฟังก์ชันทำความสะอาดหน่วยความจำ (cleanup) ของหน้า Flutter ก่อนที่หน้านั้นจะถูกปิด ❗
  @override
  void dispose() {
    messageCtrl.dispose();
    super.dispose();
  }
}
