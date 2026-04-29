// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_project/views/login_ui.dart';

class AwesomeUi extends StatefulWidget {
  const AwesomeUi({super.key});

  @override
  State<AwesomeUi> createState() => _AwesomeUiState();
}

class _AwesomeUiState extends State<AwesomeUi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5C6CB),
              Color(0xFFF8D7DA),
              Color(0xFFFFF0F3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Awesome !',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6F4E5C),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Image.asset(
                          'assets/images/phone.png',
                          width: 250,
                          height: 250,
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Password changed successfully',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF8B5E6B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 50),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginUi(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ).copyWith(
                              backgroundColor: const WidgetStatePropertyAll(
                                Colors.transparent,
                              ),
                              shadowColor: const WidgetStatePropertyAll(
                                Colors.transparent,
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B5E6B),
                                    Color(0xFFB87B8E),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Center(
                                child: Text(
                                  'DONE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
