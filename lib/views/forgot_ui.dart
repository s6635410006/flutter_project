import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/views/prove_ui.dart';

class ForgotUi extends StatefulWidget {
  const ForgotUi({super.key});

  @override
  State<ForgotUi> createState() => _ForgotUiState();
}

class _ForgotUiState extends State<ForgotUi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 231, 220),
      //แถบบา
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
                  'Let’s verify your number!',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Image.asset(
                  'assets/images/phone.png',
                  width: 300,
                  height: 300,
                ),
                SizedBox(
                  height: 50,
                ),
                TextField(
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9.0),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 128, 94, 39),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      //กดกรอกแล้วเปลี่ยนสีขอบ
                      borderRadius: BorderRadius.circular(9.0),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 225, 190, 132),
                        width: 2,
                      ),
                    ),
                    hintText: 'Phone number',
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 95, 71, 37),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 25.0,
                      horizontal: 20.0,
                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
