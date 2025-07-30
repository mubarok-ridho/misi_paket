import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReadOnlyChatPage extends StatefulWidget {
  final int orderId;
  final int customerId;
  final int kurirId;

  const ReadOnlyChatPage({
    super.key,
    required this.orderId,
    required this.customerId,
    required this.kurirId,
  });

  @override
  State<ReadOnlyChatPage> createState() => _ReadOnlyChatPageState();
}

class Message {
  final String text;
  final int senderId;

  Message({required this.text, required this.senderId});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['content'] ?? '',
      senderId: json['sender_id'] ?? 0,
    );
  }
}

class _ReadOnlyChatPageState extends State<ReadOnlyChatPage> {
  List<Message> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final response = await http.get(
        Uri.parse("http://localhost:8080/chat/load/${widget.orderId}"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List messagesJson = data['messages'];

      final List<Message> messages = messagesJson
          .map((json) => Message.fromJson(json))
          .toList()
          .cast<Message>();

      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } else {
      print("❌ Gagal mengambil pesan: ${response.body}");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Chat"),
        backgroundColor: const Color(0xFFDE6029),
      ),
      backgroundColor: const Color(0xFF121212),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? const Center(
                  child: Text("Belum ada percakapan",
                      style: TextStyle(color: Colors.white70)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isKurir = msg.senderId == widget.kurirId;

                    return Align(
                      alignment: isKurir
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              isKurir ? Color.fromARGB(255, 11, 82, 153) : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg.text,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
