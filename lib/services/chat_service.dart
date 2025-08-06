import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:misi_paket/models/chat_message_model.dart';

class Message {
  final String text;
  final int senderId;
  final DateTime time;
  final String sender;

  Message({
    required this.text,
    required this.senderId,
    required this.time,
    required this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['content'] as String,
      senderId: json['sender_id'] as int,
      sender: json['sender'] ?? '',
      time: DateTime.parse(json['sent_at']),
    );
  }
}


class ChatService {
  static const String baseUrl = 'http://localhost:8080'; // Ganti jika perlu

  static Future<ChatMessage> sendMessage({
    required String orderId,
    required String sender,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/send-chat');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      'order_id': orderId,
      'sender': sender,
      'message': message,
    });

    // Debug print untuk memantau body yang dikirim
    print("🔼 Sending chat message:");
    print(body);

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print("✅ Message sent. Response: ${response.body}");
      return ChatMessage.fromJson(jsonDecode(response.body));
    } else {
      print("❌ Failed to send message. Status: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception('Failed to send chat message');
    }
  }
}
