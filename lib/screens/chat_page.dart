import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../services/centrifugo_service.dart';

class Message {
  final String text;
  final int senderId;
  final DateTime time;

  Message({required this.text, required this.senderId, required this.time, required sender});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['content'] as String,
      senderId: json['sender_id'] as int,
      sender: json['sender'] ?? '',
      time: DateTime.parse(json['sent_at']),
    );
  }
}

class ChatPage extends StatefulWidget {
  final int userId;
  final int receiverId;
  final int orderId;
  final String senderRole;
  final String sender;
  final String receiverName;

  const ChatPage({
    required this.userId,
    required this.receiverId,
    required this.orderId,
    required this.senderRole,
    required this.sender,
    required this.receiverName,
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final CentrifugoService _centrifugoService = CentrifugoService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  String? token;

  final Color bgColor = Color(0xFF121212);         // soft black
  final Color bubbleMe = Color.fromARGB(255, 14, 69, 121);        // blue-cyan
  final Color bubbleOther = Color.fromARGB(255, 188, 89, 14);     // soft gray
  final Color accentOrange = Color(0xFFFF9800);    // orange

  @override
  void initState() {
    super.initState();
    loadMessagesFromDatabase();
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
        _scrollToBottom();
      });
    } else {
      print("❌ Failed to load messages: ${response.body}");
    }
  }

  Future<void> _initializeChat() async {
    final fetchedToken = await _fetchCentrifugoToken(widget.userId.toString());
    if (fetchedToken != null) {
      token = fetchedToken;
      await _centrifugoService.connect(
        widget.userId.toString(),
        token!,
        widget.orderId,
      );

      _centrifugoService.messageStream.listen((msg) {
        try {
          final messageData = msg as Map<String, dynamic>;
          final message = Message.fromJson(messageData);
          setState(() {
            _messages.add(message);
            _scrollToBottom();
          });
        } catch (e) {
          print("❌ Parse message error: $e");
        }
      });
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
      print('❌ Token fetch failed: ${response.body}');
      return null;
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final response = await http.post(
      Uri.parse('http://localhost:8080/chat/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'order_id': widget.orderId.toString(),
        'sender_id': widget.userId,
        'sender': widget.senderRole,
        'receiver_id': widget.receiverId,
        'message': messageText,
      }),
    );

    if (response.statusCode == 200) {
      _messageController.clear();
      final message = Message(
  text: messageText,
  senderId: widget.userId,
  time: DateTime.now(),
  sender: widget.sender,
);

      setState(() {
        _messages.add(message);
        _scrollToBottom();
      });
    } else {
      print('❌ Failed to send message: ${response.body}');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _centrifugoService.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
  automaticallyImplyLeading: false, // Ini menghilangkan tombol back
  backgroundColor: Colors.black,
  iconTheme: IconThemeData(color: Colors.white),
  elevation: 1,
  title: Row(
    children: [
      const CircleAvatar(
        backgroundColor: Color(0xFF444444),
        child: Icon(Icons.person, color: Colors.white),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          widget.receiverName,
          style: TextStyle(color: accentOrange, fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  ),
),

      body: Stack(
  children: [
    Opacity(
      opacity: 0.25,
      child: Image.asset(
        'lib/assets/pattern.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    ),
    Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isMe = msg.senderId == widget.userId;
              final time = DateFormat('HH:mm').format(msg.time);

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? bubbleMe : bubbleOther,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(isMe ? 12 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 12),
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tulis pesan...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ],
),

    );
  }
}
