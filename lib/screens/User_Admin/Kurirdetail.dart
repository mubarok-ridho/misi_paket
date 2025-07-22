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

  Widget buildStatCard(String title, String value, Color color) {
    return Card(
      color: color,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Kurir"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Kurir
                  Text(widget.kurir.nama,
                      style:
                          const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("No. HP: ${widget.kurir.noHp}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),

                  const SizedBox(height: 24),

                  // Statistik Kurir
                  buildStatCard(
                      "Pesanan Diproses",
                      "${stats?.pesananDiproses ?? 0}",
                      Colors.blueAccent),
                  const SizedBox(height: 12),
                  buildStatCard(
                      "Pesanan Selesai Hari Ini",
                      "${stats?.pesananSelesaiHariIni ?? 0}",
                      Colors.green),
                  const SizedBox(height: 12),
                  buildStatCard(
                      "Pendapatan Hari Ini",
                      "Rp${stats?.pendapatanHariIni ?? 0}",
                      Colors.deepPurple),
                ],
              ),
            ),
    );
  }
}
