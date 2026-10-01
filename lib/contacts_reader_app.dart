import 'package:flutter/material.dart';

class ContactsReaderApp extends StatelessWidget {
  const ContactsReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts Reader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ContactsReaderHome(),
    );
  }
}

class ContactsReaderHome extends StatefulWidget {
  const ContactsReaderHome({super.key});

  @override
  State<ContactsReaderHome> createState() => _ContactsReaderHomeState();
}

class _ContactsReaderHomeState extends State<ContactsReaderHome> {
  // Dữ liệu danh bạ giả lập để test trên Chrome
  final List<Map<String, String>> _contacts = [
    {'name': 'Bích Ngân', 'phone': '(908) 765-7765'},
    {'name': 'Vân Vinh', 'phone': '(890) 754-4468'},
    {'name': 'Tam Đinh', 'phone': '0976555567'},
    {'name': 'Hoa Mi', 'phone': '096976552'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts Reader')),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return ListTile(
            title: Text(contact['name'] ?? ''),
            subtitle: Text(contact['phone'] ?? ''),
          );
        },
      ),
    );
  }
}