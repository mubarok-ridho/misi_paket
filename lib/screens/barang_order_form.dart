import 'package:flutter/material.dart';
import 'package:misi_paket/screens/select_location_page.dart';

class BarangOrderForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _pController = TextEditingController();
  final _lController = TextEditingController();
  final _tController = TextEditingController();
  final _catatanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final darkFieldColor = Color(0xFF1E1F26);
    final orangeColor = Color(0xFFDE6029);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Pengantaran Barang",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDE6029), Color(0xFFD2785C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Barang
              Text("Nama barang",
                  style: TextStyle(
                      color: orangeColor, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration(darkFieldColor),
              ),
              SizedBox(height: 20),

              // Dimensi Barang
              Text("Dimensi barang",
                  style: TextStyle(
                      color: orangeColor, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  _buildDimensiField(_pController, "P", darkFieldColor),
                  SizedBox(width: 8),
                  _buildDimensiField(_lController, "L", darkFieldColor),
                  SizedBox(width: 8),
                  _buildDimensiField(_tController, "T", darkFieldColor),
                ],
              ),
              SizedBox(height: 20),

              // Catatan
              Text("Tambahkan catatan",
                  style: TextStyle(
                      color: orangeColor, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextFormField(
                controller: _catatanController,
                style: TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: _inputDecoration(darkFieldColor),
              ),
              SizedBox(height: 30),

              // Submit Button
              Center(
                  child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LokasiPickerPage()),
                  );

                  if (result != null) {
                    print("Lokasi Jemput: ${result['pickup']}");
                    print("Lokasi Antar: ${result['drop']}");
                    // Simpan ke backend atau lanjut ke tahap pilih kurir
                  }
                },
                child: Text('Submit'),
              )),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(Color fillColor) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Expanded _buildDimensiField(
      TextEditingController controller, String label, Color color) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: color,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}
