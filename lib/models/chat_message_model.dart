class ChatMessage {
  final String orderId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final DateTime time;

  ChatMessage({
    required this.orderId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.time,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      orderId: json['order_id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderRole: json['sender_role'],
      message: json['message'],
      time: DateTime.parse(json['time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'message': message,
      'time': time.toIso8601String(),
    };
  }
}
