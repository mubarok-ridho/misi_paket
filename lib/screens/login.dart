import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import 'package:misi_paket/screens/User_Courrier/courier.dart';
import 'package:misi_paket/screens/User_Customer/customer.dart';
import 'package:misi_paket/screens/User_Admin/admin_main_page.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController identifierCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  bool isLoading = false;
  bool showPassword = false;
  String? errorMsg;
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _login() async {
    final identifier = identifierCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (identifier.isEmpty || pass.isEmpty) {
      setState(() => errorMsg = "Email / Nomor dan password wajib diisi");
      return;
    }

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      final res = await http.post(
        Uri.parse("http://localhost:8080/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': identifier, 'password': pass}), // Kirim ke backend
      );

      final data = jsonDecode(res.body);
      setState(() => isLoading = false);

      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('userId', data['user']['id']);

        final role = data['user']['role'];
        if (role == "customer") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomerDashboard()));
        } else if (role == "kurir") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CourierDashboard()));
        } else if (role == "admin") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminMainPage()));
        } else {
          setState(() => errorMsg = "Role tidak dikenali");
        }
      } else {
        setState(() => errorMsg = data['error'] ?? "Login gagal");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = "Gagal terhubung ke server";
      });
    }
  }

  Future<void> _loginWithBiometric() async {
    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Gunakan sidik jari untuk login',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        _login(); // Opsional: bisa disimpan token terakhir dan login otomatis
      }
    } catch (e) {
      setState(() => errorMsg = "Gagal autentikasi biometrik");
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF2D2F36),
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
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange, Colors.orangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Center(
                child: Image.asset('lib/assets/Logo.png', height: 120),
              ),
            ),

            // 🔶 FORM
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Log In",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                    const SizedBox(height: 24),

                    const Text("Email / Nomor Telepon",
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: identifierCtrl,
                      decoration: _inputDecoration("Masukkan email atau nomor telepon"),
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 16),
                    const Text("Password",
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),

                    // 🔒 Password + Fingerprint
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextField(
                            controller: passCtrl,
                            obscureText: !showPassword,
                            decoration: _inputDecoration("Masukkan password").copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.orange),
                                onPressed: () => setState(() => showPassword = !showPassword),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2F36),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.fingerprint, color: Colors.orange, size: 28),
                            onPressed: _loginWithBiometric,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/change-password");
                        },
                        child: const Text("Lupa Password?", style: TextStyle(color: Colors.deepOrange)),
                      ),
                    ),

                    if (errorMsg != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                      ),

                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D2F36),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.orange)
                              : const Text("Log In",
                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum punya akun?"),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const RegisterPage()));
                          },
                          child: const Text("Daftar di sini",
                              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
