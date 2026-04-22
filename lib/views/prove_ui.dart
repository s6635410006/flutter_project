// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/views/awesome_ui.dart';

class ProveUi extends StatefulWidget {
  const ProveUi({super.key});

  @override
  State<ProveUi> createState() => _ProveUiState();
}

class _ProveUiState extends State<ProveUi> {
  //รับค่าที่ผู้ใช้กรอก เอาค่า OTP ไปใช้ต่อ เช่น ส่งไป server
  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 231, 220),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(221, 126, 121, 94),
        //ระดับความสูง
        elevation: 0,
        //ปุ่มกดกลับ
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'FORGOT PASSWORD',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Enter verification code',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Image.asset(
                  'assets/images/email.png',
                  width: 200,
                  height: 200,
                ),
                SizedBox(
                  height: 50,
                ),
                //ช่องกรอกOTP
                TextField(
                  //เชื่อมกับotpControllerเพื่อเก็บค่าที่ผู้ใช้พิมพ์
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  //ช่อง OTP แบบห่าง
                  style: TextStyle(
                    fontSize: 24,
                    letterSpacing: 10,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                //กดปุ่มแบบข้อความ
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProveUi(),
                      ),
                    );
                  },
                  child: Text(
                    'Send verification code',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.brown,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AwesomeUi(),
                      ),
                    );
                  },
                  child: Text(
                    'CONFIRM',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 110, 72, 38),
                    fixedSize: Size(
                      150,
                      55,
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
}
