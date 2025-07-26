import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String orderId;
  final String sender;
  final String message;

  ChatMessage({
    required this.orderId,
    required this.sender,
    required this.message,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      orderId: json['order_id'],
      sender: json['sender'],
      message: json['message'],
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
