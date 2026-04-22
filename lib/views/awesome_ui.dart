// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_project/views/create_account_ui.dart';

class AwesomeUi extends StatefulWidget {
  const AwesomeUi({super.key});

  @override
  State<AwesomeUi> createState() => _AwesomeUiState();
}

class _AwesomeUiState extends State<AwesomeUi> {
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
                  'Awesome !',
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
                Text(
                  'Your Mobile number has been verified successfully ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAccountUi(),
                      ),
                    );
                  },
                  child: Text(
                    'DONE',
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
