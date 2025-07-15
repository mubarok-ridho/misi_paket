import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPageCustomer extends StatefulWidget {
  final String orderId;

  const ChatPageCustomer({super.key, required this.orderId});

  @override
  State<ChatPageCustomer> createState() => _ChatPageCustomerState();
}

class _ChatPageCustomerState extends State<ChatPageCustomer> {
  late WebSocketChannel channel;
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isSendEnabled = false;

  final String currentRole = "customer";

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('chat_${widget.orderId}');
    if (stored != null) {
      setState(() {
        final List<dynamic> decoded = jsonDecode(stored);
        messages = decoded.map((e) => Map<String, String>.from(e)).toList();
      });
    }

    channel = WebSocketChannel.connect(
      Uri.parse('wss://backendpackagefaiexspress-mubarok-ridho6586-w980izdc.leapcell.dev/ws/${widget.orderId}'),
    );

    channel.stream.listen((message) {
      final decoded = jsonDecode(message);
      setState(() {
        messages.add({
          'sender': decoded['sender'] ?? 'unknown',
          'text': decoded['text'] ?? ''
        });
      });
      _saveChat();
      _scrollToBottom();
    });

    controller.addListener(() {
      setState(() {
        isSendEnabled = controller.text.trim().isNotEmpty;
      });
    });
  }

  Future<void> _saveChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_${widget.orderId}', jsonEncode(messages));
  }

  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final message = {
      "sender": currentRole,
      "text": text,
    };
    channel.sink.add(jsonEncode(message));

    setState(() {
      messages.add(message);
      controller.clear();
    });

    _saveChat();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24313F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF334856),
        foregroundColor: Colors.white,
        title: Text("Chat Order #${widget.orderId}"),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final sender = msg['sender'];
                final text = msg['text'] ?? '';
                final isMe = sender == currentRole;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? const LinearGradient(
                              colors: [Color(0xFFFF7E30), Color(0xFFE04924)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF3C4A57), Color(0xFF2C3944)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(text, style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      hintStyle: const TextStyle(color: Color(0xFFA5B0BA)),
                      filled: true,
                      fillColor: const Color(0xFF3C4A57),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, size: 28),
                  color: isSendEnabled ? const Color(0xFFFF7E30) : Colors.grey,
                  onPressed: isSendEnabled ? sendMessage : null,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}