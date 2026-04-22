import 'package:flutter/material.dart';
import 'package:flutter_project/views/login_ui.dart';

class ScreenUi extends StatefulWidget {
  const ScreenUi({super.key});

  @override
  State<ScreenUi> createState() => _ScreenUiState();
}

class _ScreenUiState extends State<ScreenUi> {
  @override
  void initState() {
    // โค้ดหน่วง
    Future.delayed(
      //ระยเวลาหน่วง

      Duration(seconds: 5),

      //ครบเวลาแล้วทำอะไร

      () {
        //ไปหน้า login แบบย้อนกลับไม่ได้
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginUi(),
          ),
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 240, 222, 195),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                'Cake Ease',
                style: TextStyle(
                  color: const Color.fromARGB(255, 154, 139, 73),
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              CircularProgressIndicator(
                color: Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}
