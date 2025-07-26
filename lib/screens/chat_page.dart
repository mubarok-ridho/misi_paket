import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/centrifugo_service.dart';

class Message {
  final String text;
  final int senderId;
  final DateTime time;

  Message({required this.text, required this.senderId, required this.time});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['content'] as String,
      senderId: json['sender_id'] as int,
      time: DateTime.parse(json['sent_at']),
    );
  }
}

class ChatPage extends StatefulWidget {
  final int userId;
  final int receiverId;
  final int orderId;
  final senderRole;

  const ChatPage({
    required this.userId,
    required this.receiverId,
    required this.orderId,
    required this.senderRole,
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final CentrifugoService _centrifugoService = CentrifugoService();
  final TextEditingController _messageController = TextEditingController();
  // final List<Map<String, dynamic>> _messages = [];
  // List<String> _messages = [];
  List<Message> _messages = [];

  String? token;

  @override
  void initState() {
    super.initState();
    loadMessagesFromDatabase(); // Tambahkan ini dulu
    _initializeChat();
  }

  Future<void> loadMessagesFromDatabase() async {
    final url = Uri.parse('http://localhost:8080/chat/load/${widget.orderId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List messagesJson = data['messages'];
      final List<Message> messages = messagesJson
          .map((json) => Message.fromJson(json))
          .toList()
          .cast<Message>();

      setState(() {
        _messages = messages;
      });
    } else {
      print("❌ Failed to load messages from DB: ${response.body}");
    }
  }

  Future<void> _initializeChat() async {
    final fetchedToken = await _fetchCentrifugoToken(widget.userId.toString());
    if (fetchedToken != null) {
      token = fetchedToken;
      print("DEBUG: Received token from backend:\n$token");
      print("idorder ${widget.orderId}");
      await _centrifugoService.connect(
        widget.userId.toString(),
        token!,
        widget.orderId,
      );

      _centrifugoService.messageStream.listen((msg) {
        try {
          final messageData = msg as Map<String, dynamic>;
          print(messageData);

          final message = Message.fromJson(messageData); // Buat Message object
          setState(() {
            _messages.add(message);
          });
        } catch (e) {
          print("ERROR: Failed to parse message: $e");
        }
      });
    } else {
      print("❌ Failed to fetch token.");
    }
  }

  Future<String?> _fetchCentrifugoToken(String userId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/centrifugo/token?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      print('❌ Failed to fetch centrifugo token: ${response.body}');
      return null;
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final response = await http.post(
      Uri.parse('http://localhost:8080/chat/send'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'order_id': widget.orderId.toString(),
        'sender_id': widget.userId, // <== tambah ini
        'sender': widget.senderRole,
        'receiver_id': widget.receiverId, // contoh: "customer"
        'message': messageText,
      }),
      
    );
    print(widget.orderId);
    if (response.statusCode == 200) {
      _messageController.clear();
      print("✅ Message sent");
    } else {
      print('❌ Failed to send message: ${response.body}');
    }

    if (response.statusCode == 200) {
  _messageController.clear();
  print("✅ Message sent");

  // Tambahkan ini untuk langsung tampilkan sementara sambil nunggu dari Centrifugo
  final message = Message(
    text: messageText,
    senderId: widget.userId,
    time: DateTime.now(), // sementara
  );

  setState(() {
    _messages.add(message);
  });
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
                final isMe = msg.senderId == widget.userId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isMe ? Color.fromARGB(255, 10, 69, 93) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      msg.text,
                      style:
                          TextStyle(color: isMe ? Colors.white : Colors.black),
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
