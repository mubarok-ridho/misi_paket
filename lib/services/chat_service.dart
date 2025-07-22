import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart';

class ChatService {
  static const String baseUrl = 'http://localhost:8080';

  static Future<List<ChatMessage>> fetchMessages(String orderId) async {
    final response = await http.get(Uri.parse('$baseUrl/chat/order/$orderId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ChatMessage.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  static Future<ChatMessage> sendMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'order_id': orderId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_role': senderRole,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      return ChatMessage(
        orderId: orderId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message,
        time: DateTime.now(),
      );
    } else {
      throw Exception('Failed to send message');
    }
  }
}
