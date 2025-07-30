import 'package:flutter/material.dart';
import '../../models/kurir_model.dart';
import 'package:misi_paket/models/kurir_stats_model.dart' as model;
import 'package:misi_paket/services/kurir_stats_service.dart';

class KurirDetailPage extends StatefulWidget {
  final Kurir kurir;
  final int kurirId;

  const KurirDetailPage({
    super.key,
    required this.kurir,
    required this.kurirId,
  });

  @override
  State<KurirDetailPage> createState() => _KurirDetailPageState();
}

class _KurirDetailPageState extends State<KurirDetailPage> {
  model.KurirStatsModel? stats;
  bool isLoading = true;

  final Color primaryColor = const Color(0xFFE64513); // Oranye FaiExpress
  final Color backgroundColor = const Color(0xFF121212); // Dark
  final Color cardColor = const Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final fetchedStats = await KurirStatsService.fetchStats(widget.kurirId);
    if (fetchedStats != null) {
      setState(() {
        stats = fetchedStats;
        isLoading = false;
      });
    }
  }

  Widget buildStatCard(String title, String value, IconData icon) {
    return Card(
      color: cardColor,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.15),
              child: Icon(icon, color: primaryColor),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Detail Kurir"),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Kurir
                  Text(
                    widget.kurir.nama,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Text(
                  //   // "No. HP: ${widget.kurir.noHp}",
                  //   style: const TextStyle(fontSize: 16, color: Colors.white54),
                  // ),
                  // const SizedBox(height: 30),

                  // Statistik
                  buildStatCard(
                    "Pesanan Diproses",
                    "${stats?.pesananDiproses ?? 0}",
                    Icons.sync,
                  ),
                  const SizedBox(height: 16),
                  buildStatCard(
                    "Pesanan Selesai Hari Ini",
                    "${stats?.pesananSelesaiHariIni ?? 0}",
                    Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 16),
                  buildStatCard(
                    "Pendapatan Hari Ini",
                    "Rp${stats?.pendapatanHariIni.toStringAsFixed(0) ?? 0}",
                    Icons.attach_money,
                  ),
                ],
              ),
            ),
    );
  }
}
