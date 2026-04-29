//-------หน้าล็อคอินหน้าแรก-------

import 'package:flutter/material.dart';
import 'package:flutter_project/views/create_account_ui.dart';
import 'package:flutter_project/views/forgot_ui.dart';
import 'package:flutter_project/views/home_ui.dart';
import 'package:flutter_project/views/admin_page.dart'; // 1. เพิ่มการ Import หน้าแอดมิน
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginUi extends StatefulWidget {
  const LoginUi({super.key});

  @override
  State<LoginUi> createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- ฟังก์ชัน Login ที่ปรับปรุงใหม่ ---
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'กรุณากรอกอีเมลและรหัสผ่าน';
      });
      return;
    }

    try {
      // 1. ตรวจสอบอีเมลและรหัสผ่าน
      final authResponse =
          await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (authResponse.session == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'ยังไม่ยืนยันอีเมล กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ';
        });
        return;
      }

      // 2. ดึงค่าสิทธิ์ (role) จากตาราง profiles
      final userData = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', authResponse.user!.id)
          .single();

      final String userRole = userData['role'] ?? 'customer';

      setState(() => _isLoading = false);

      // 3. สับราง: ถ้าเป็น admin ไปหน้า AdminPage ถ้าไม่ใช่ไปหน้า HomeUi
      if (userRole == 'admin') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminPage(),
            ));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeUi()), // ไปหน้าลูกค้า
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.message.contains('Email not confirmed')
            ? 'ยังไม่ยืนยันอีเมล กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ'
            : error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/bg_pattern.png'), // อย่าลืมเซฟรูปภาพนี้ไว้ที่ assets/images/bg_pattern.png
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.85), // ทำให้ภาพจางลงเพื่อให้ข้อความอ่านง่าย
              BlendMode.lighten,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50),
                Image.asset(
                  'assets/images/lg4.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 127, 55, 97)),
                ),
                SizedBox(height: 50),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'อีเมล',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'กรุณากรอกอีเมล',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.grey.shade500,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'รหัสผ่าน',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'กรุณากรอกรหัสผ่าน',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: Colors.grey.shade500,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey.shade500,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) =>
                                    setState(() => _rememberMe = value!),
                                activeColor: Color(0xFFB87B8E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              Text(
                                'Remember me',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotUi(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ).copyWith(
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            shadowColor: WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF8B5E6B),
                                  Color(0xFFB87B8E),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'login',
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
                    ],
                  ),
                ),
                SizedBox(height: 70),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create an account?',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAccountUi(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.brown,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
