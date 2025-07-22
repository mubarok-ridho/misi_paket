import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/centrifugo_service.dart';

class ChatPage extends StatefulWidget {
  final int userId;
  final String token;
  final int receiverId;
  final int orderId; // 👈 Tambahkan ini

  const ChatPage({
    required this.userId,
    required this.token,
    required this.receiverId,
    required this.orderId, // 👈 Tambahkan ini
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final CentrifugoService _centrifugoService = CentrifugoService();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
_centrifugoService.connect(
  widget.userId.toString(),
  widget.token,
  widget.orderId, // ✅ kirimkan orderId
  
);

    _centrifugoService.messageStream.listen((msg) {
      setState(() {
        _messages.add(msg);
      });
    });
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final response = await http.post(
      Uri.parse('http://localhost:8080/chat/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({
        'sender_id': widget.userId,
        'receiver_id': widget.receiverId,
        'content': messageText,
      }),
    );

    if (response.statusCode == 200) {
      _messageController.clear();
    } else {
      print('❌ Failed to send message: ${response.body}');
    }
  }

  @override
  void dispose() {
    _centrifugoService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with User ${widget.receiverId}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['sender_id'] == widget.userId;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      msg['content'],
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
