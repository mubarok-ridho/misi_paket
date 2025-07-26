import 'dart:async';
import 'dart:convert';
import 'package:centrifuge/centrifuge.dart';

class CentrifugoService {
  late Client client;
  Subscription? subscription;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> connect(String userId, String token, int orderId) async {
  client = createClient(
    'ws://localhost:9000/connection/websocket?format=json',
    ClientConfig(token: token),
  );

  client.connected.listen((event) {
    print('✅ Connected to Centrifugo');
  });

  client.disconnected.listen((event) {
    print('❌ Disconnected: ${event.reason}');
  });

  await client.connect();

  final channel = 'chat:$orderId'; 
  subscription = client.newSubscription(channel);

  subscription!.publication.listen((event) {
    final data = jsonDecode(utf8.decode(event.data));
    print('📥 New message from $channel: $data');
    _messageController.add(data);
  });

  subscription!.subscribed.listen((_) {
    print('📡 Subscribed to $channel');
  });

  subscription!.subscribe();
}


  Future<void> disconnect() async {
    await subscription?.unsubscribe();
    await client.disconnect();
    await _messageController.close();
  }
}
