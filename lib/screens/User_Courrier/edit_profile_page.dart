import 'package:flutter/material.dart';
import 'profile_form_field.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "Budi Kurir");
  final _phoneController = TextEditingController(text: "08123456789");
  final _emailController = TextEditingController(text: "budi.kurir@email.com");
  final _addressController =
      TextEditingController(text: "Jl. Raya Jakarta No. 123");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Color(0xFF334856),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.orangeAccent,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // Handle image change
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Color(0xFFDE6029),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  ProfileFormField(
                    label: "Nama Lengkap",
                    controller: _nameController,
                    icon: Icons.person,
                  ),
                  SizedBox(height: 16),
                  ProfileFormField(
                    label: "Nomor Telepon",
                    controller: _phoneController,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16),
                  ProfileFormField(
                    label: "Email",
                    controller: _emailController,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  ProfileFormField(
                    label: "Alamat",
                    controller: _addressController,
                    icon: Icons.location_on,
                    maxLines: 3,
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Profile berhasil diperbarui")),
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDE6029),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Simpan Perubahan",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}