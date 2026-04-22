import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/views/login_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateAccountUi extends StatefulWidget {
  const CreateAccountUi({super.key});

  @override
  State<CreateAccountUi> createState() => _CreateAccountUiState();
}

class _CreateAccountUiState extends State<CreateAccountUi> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    setState(() {
      _errorMessage = null;
    });

    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'กรุณากรอกข้อมูลให้ครบทุกช่อง';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน';
      });
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();

    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: <String, dynamic>{
          'username': name,
          'phone': phone,
        },
      );

      final userId = authResponse.user?.id;
      var hasSession = authResponse.session != null;

      if (userId != null && !hasSession) {
        try {
          await Supabase.instance.client.auth.signInWithPassword(
            email: email,
            password: password,
          );
          hasSession = Supabase.instance.client.auth.currentSession != null;
        } on AuthException {
          // ถ้า sign in ไม่ได้ (เช่นยังต้องยืนยันอีเมล) จะไปแสดงข้อความด้านล่าง
        }
      }

      if (userId != null && hasSession) {
        await Supabase.instance.client.from('profiles').upsert(<String, dynamic>{
          'id': userId,
          'username': name,
          'phone': phone,
          'email': email,
        });
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasSession
                ? 'สมัครสมาชิกสำเร็จ กรุณาเข้าสู่ระบบ'
                : 'สมัครสมาชิกสำเร็จ กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ',
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginUi()),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } on PostgrestException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'สมัครสำเร็จ แต่บันทึกตาราง profiles ไม่ได้: ${error.message}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'สร้างบัญชีไม่สำเร็จ: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // พื้นหลังหน้า Create Account ให้โทนเดียวกับหน้า Login
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                // โลโก้และหัวข้อหน้า
                Image.asset(
                  'assets/images/Le.png',
                  width: 200,
                  height: 180,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                Text(
                  'สร้างบัญชีผู้ใช้',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6F4E5C),
                  ),
                ),
                const SizedBox(height: 24),
                // กล่องฟอร์มสมัครสมาชิก
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // กลุ่มช่องกรอกข้อมูลผู้ใช้
                      _buildLabel('ชื่อ-นามสกุล'),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: _fullNameController,
                        hintText: 'กรุณากรอกชื่อ-นามสกุล',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
                      _buildLabel('อีเมล'),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: _emailController,
                        hintText: 'example@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _buildLabel('เบอร์โทรศัพท์'),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: _phoneController,
                        hintText: 'กรุณากรอกเบอร์โทร',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildLabel('รหัสผ่าน'),
                      const SizedBox(height: 8),
                      _buildPasswordInput(
                        controller: _passwordController,
                        hintText: 'กรุณากรอกรหัสผ่าน',
                        obscureText: _obscurePassword,
                        onToggle: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildLabel('ยืนยันรหัสผ่าน'),
                      const SizedBox(height: 8),
                      _buildPasswordInput(
                        controller: _confirmPasswordController,
                        hintText: 'กรุณากรอกยืนยันรหัสผ่าน',
                        obscureText: _obscureConfirmPassword,
                        onToggle: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      // แสดงข้อความ error จาก validation
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // ปุ่มสร้างบัญชี
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleCreateAccount,
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
                                colors: [Color(0xFF8B5E6B), Color(0xFFB87B8E)],
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
                                      'Create account',
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
                const SizedBox(height: 24),
                // ลิงก์กลับไปหน้า Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'มีบัญชีอยู่แล้ว?',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginUi(),
                          ),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF8B5E6B),
                          fontWeight: FontWeight.bold,
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

  Widget _buildLabel(String text) {
    // Widget สำหรับหัวข้อของแต่ละช่องกรอก
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    // Widget ช่องกรอกข้อมูลทั่วไป เช่น ชื่อ อีเมล เบอร์โทร
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordInput({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    // Widget ช่องกรอกรหัสผ่าน พร้อมปุ่มซ่อน/แสดงรหัส
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 14,
        ),
        prefixIcon: Icon(Icons.lock_outlined, color: Colors.grey.shade500),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade500,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
