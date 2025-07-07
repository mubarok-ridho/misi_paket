import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  bool isLoading = false;
  String? errorMsg;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    final url = Uri.parse('http://localhost:8080/register');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameCtrl.text,
        'email': emailCtrl.text,
        'password': passCtrl.text,
        'phone': phoneCtrl.text,
        'role': 'customer',
        'status': 'offline'
      }),
    );

    setState(() => isLoading = false);

    if (res.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      setState(() {
        errorMsg = jsonDecode(res.body)['error'] ?? 'Gagal register';
      });
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFF2D2F36),
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Daftar Akun",
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: _inputDecoration("Nama Lengkap"),
                        validator: (val) =>
                            val == null || val.isEmpty ? "Nama wajib diisi" : null,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: _inputDecoration("Email"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Email wajib diisi" : null,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passCtrl,
                        decoration: _inputDecoration("Password"),
                        obscureText: true,
                        validator: (val) => val != null && val.length < 6
                            ? "Minimal 6 karakter"
                            : null,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: _inputDecoration("Nomor Telepon"),
                        keyboardType: TextInputType.phone,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Nomor wajib diisi" : null,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      if (errorMsg != null)
                        Text(errorMsg!,
                            style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D2F36),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)
                            : const Text("Daftar",
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Sudah punya akun? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      )
                    ],
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
