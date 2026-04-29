import 'package:flutter/material.dart';
import 'package:flutter_project/views/awesome_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewPasswordUi extends StatefulWidget {
  const NewPasswordUi({super.key});

  @override
  State<NewPasswordUi> createState() => _NewPasswordUiState();
}

class _NewPasswordUiState extends State<NewPasswordUi> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> updatePassword() async {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AwesomeUi(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF6F4E5C)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'NEW PASSWORD',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6F4E5C),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Create new password',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8B5E6B),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'รหัสผ่านใหม่',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'New Password',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
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
                              const SizedBox(height: 20),
                              Text(
                                'ยืนยันรหัสผ่าน',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: confirmPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Confirm Password',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
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
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : updatePassword,
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
                                    child: Center(
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'SAVE',
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
