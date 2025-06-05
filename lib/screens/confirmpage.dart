import 'package:flutter/material.dart';

class ConfirmPage extends StatelessWidget {
  final Map<String, dynamic> fullData;
  ConfirmPage({required this.fullData});

  @override
  Widget build(BuildContext context) {
    String namaKurir = fullData['kurir'] ?? 'Kurir Tidak Diketahui';
    String noHpKurir = '0823 1283 1238'; // Bisa kamu ganti dinamis nanti
    String alamatJemput = fullData['lokasiJemput'] ?? '-';
    String alamatAntar = fullData['lokasiAntar'] ?? '-';
    String namaBarang = fullData['namaBarang'] ?? '-';
    String catatan = fullData['catatan'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: Text("Konfirmasi Pesanan"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            // Card Info Kurir
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Color(0xFF1C1B33),
              elevation: 4,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/kurir1.png'),
                  radius: 24,
                ),
                title: Text(namaKurir, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(noHpKurir, style: TextStyle(color: Colors.white70)),
              ),
            ),

            SizedBox(height: 16),

            // Alamat Penjemputan
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Alamat Penjemputan", style: sectionTitleStyle()),
                    SizedBox(height: 4),
                    Text(alamatJemput, style: addressStyle()),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12),

            // Alamat Pengantaran
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Alamat Pengantaran", style: sectionTitleStyle()),
                    SizedBox(height: 4),
                    Text(alamatAntar, style: addressStyle()),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFFFF6B00)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          // TODO: aksi ganti alamat
                        },
                        child: Text("Ganti Alamat", style: TextStyle(color: Color(0xFFFF6B00))),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Detail Barang
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Detail Barang", style: sectionTitleStyle()),
                    SizedBox(height: 6),
                    Text(
                      namaBarang,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(catatan),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Tombol Konfirmasi
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Pesanan Dikonfirmasi!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                "Order dan antar sekarang",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle sectionTitleStyle() {
    return TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]);
  }

  TextStyle addressStyle() {
    return TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  }
}
