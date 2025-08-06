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
  final String senderName;

  Message({
    required this.text,
    required this.senderId,
    required this.senderName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['content'] ?? '',
      senderId: json['sender_id'] ?? 0,
      senderName: json['Sender']?['name'] ?? 'Tidak diketahui',
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
    final response =
        await http.get(Uri.parse("http://localhost:8080/chat/load/${widget.orderId}"));

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
      debugPrint("❌ Gagal mengambil pesan: ${response.body}");
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
                  child: Text(
                    "Belum ada percakapan",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isKurir = msg.senderId == widget.kurirId;

                    final bool showName = index == 0 ||
                        msg.senderId != _messages[index - 1].senderId;

                    return Align(
                      alignment:
                          isKurir ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isKurir
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          // if (showName)
                          //   Padding(
                          //     padding: const EdgeInsets.only(bottom: 4, left: 4),
                          //     child: Text(
                          //       msg.senderName,
                          //       style: TextStyle(
                          //         color: Colors.grey[400],
                          //         fontSize: 12,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isKurir
                                  ? const Color.fromARGB(255, 0, 106, 200)
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isKurir ? 12 : 0),
                                bottomRight: Radius.circular(isKurir ? 0 : 12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                )
                              ],
                            ),
                            child: Column(
  crossAxisAlignment:
      isKurir ? CrossAxisAlignment.end : CrossAxisAlignment.start,
  children: [
    if (showName)
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          msg.senderName,
          style: TextStyle(
            color: isKurir ? Color.fromARGB(179, 12, 219, 255) : Colors.orange[200],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    Text(
      msg.text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
    ),
  ],
),

                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
