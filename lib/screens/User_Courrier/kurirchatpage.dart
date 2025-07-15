import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPageCourier extends StatefulWidget {
  final String orderId;

  const ChatPageCourier({super.key, required this.orderId});

  @override
  State<ChatPageCourier> createState() => _ChatPageCourierState();
}

class _ChatPageCourierState extends State<ChatPageCourier> {
  late WebSocketChannel channel;
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isSendEnabled = false;

  final String currentRole = "kurir";

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('chat_${widget.orderId}');
    if (stored != null) {
      final decoded = jsonDecode(stored);
      setState(() {
        messages = List<Map<String, String>>.from(decoded);
      });
    }

    channel = WebSocketChannel.connect(
      Uri.parse('wss://backendpackagefaiexspress-mubarok-ridho6586-w980izdc.leapcell.dev/ws/${widget.orderId}'),
    );

    channel.stream.listen((message) {
      final decoded = jsonDecode(message);
      setState(() {
        messages.add({"sender": decoded['sender'], "text": decoded['text']});
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

    final message = jsonEncode({"sender": currentRole, "text": text});
    channel.sink.add(message);

    setState(() {
      messages.add({"sender": currentRole, "text": text});
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
      backgroundColor: const Color(0xFF1E2A35),
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
                final isMe = msg['sender'] == currentRole;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? const LinearGradient(
                              colors: [Color(0xFF4BB543), Color(0xFF2D8432)],
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
                    child: Text(
                      msg['text'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, size: 28),
                  color: isSendEnabled ? const Color(0xFF4BB543) : Colors.grey,
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
