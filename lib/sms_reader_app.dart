import 'package:flutter/material.dart';

class SmsReaderApp extends StatelessWidget {
  const SmsReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Reader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SmsReaderHome(),
    );
  }
}

class SmsReaderHome extends StatefulWidget {
  const SmsReaderHome({super.key});

  @override
  State<SmsReaderHome> createState() => _SmsReaderHomeState();
}

class _SmsReaderHomeState extends State<SmsReaderHome> {
  // Dữ liệu tin nhắn SMS giả lập để test trên Chrome
  final List<Map<String, String>> _messages = [
    {'body': 'Đang test gửi tin nhắn.', 'address': '+1 650 555 1212'},
    {'body': 'Android is always a sweet treat!', 'address': '+1 650 555 1212'},
    {'body': 'Đang test gửi tin nhắn.', 'address': '+1 650 555 1212'},
    {'body': 'Android is always a sweet treat!', 'address': '+1 650 555 1212'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Reader')),
      body: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return ListTile(
            title: Text(message['body'] ?? ''),
            subtitle: Text('Từ: ${message['address']}'),
          );
        },
      ),
    );
  }
}