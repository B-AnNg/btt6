import 'package:flutter/material.dart';

void main() {
  runApp(const SmsAnalyzerApp());
}

class SmsAnalyzerApp extends StatelessWidget {
  const SmsAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const SmsAnalyzerHome(),
    );
  }
}

// Model đại diện cho một tin nhắn SMS
class SmsModel {
  final String sender;
  final String body;
  final String date;

  SmsModel({required this.sender, required this.body, required this.date});

  // Kiểm tra nhóm quảng cáo ([QC] ở đầu)
  bool get isAd => body.trim().startsWith('[QC]');

  // Kiểm tra nhóm OTP ([OTP] kèm mã 6 số)
  bool get isOtp {
    return body.contains('[OTP]') && RegExp(r'\b\d{6}\b').hasMatch(body);
  }

  // Trích xuất mã OTP 6 chữ số
  String? get extractOtpCode {
    final match = RegExp(r'\b\d{6}\b').firstMatch(body);
    return match?.group(0);
  }
}

class SmsAnalyzerHome extends StatefulWidget {
  const SmsAnalyzerHome({super.key});

  @override
  State<SmsAnalyzerHome> createState() => _SmsAnalyzerHomeState();
}

class _SmsAnalyzerHomeState extends State<SmsAnalyzerHome> {
  int _currentIndex = 0;

  // Dữ liệu tin nhắn mẫu (Mock Data)
  final List<SmsModel> _allMessages = [
    SmsModel(
      sender: '+84988111222',
      body: '[QC] Giam gia 50% tat ca san pham thoi trang tai Ha Noi trong tuan nay.',
      date: '2026-06-01',
    ),
    SmsModel(
      sender: 'MoMo',
      body: 'Ma xac thuc [OTP] cua ban la 849204. Tuyet dai khong chia se cho bat ky ai.',
      date: '2026-06-02',
    ),
    SmsModel(
      sender: '+84911222333',
      body: 'Chieu nay may sang nha tao lay tai lieu nhe.',
      date: '2026-06-02',
    ),
    SmsModel(
      sender: 'ViettelPay',
      body: 'Ma OTP giao dich chuyen tien cua ban la 591823. Hieu luc trong 5 phut.',
      date: '2026-06-03',
    ),
    SmsModel(
      sender: '[QC]',
      body: '[QC] Vay von nhanh chong, lai suat thap tai ngan hang ABC.',
      date: '2026-06-03',
    ),
  ];

  String? _selectedSenderFilter; // Dùng để lọc theo số điện thoại cụ thể

  @override
  Widget build(BuildContext context) {
    // Các màn hình tương ứng với các tab
    final List<Widget> pages = [
      _buildStatisticsTab(), // Thống kê tổng quan & theo ngày/tháng
      _buildFilterSenderTab(), // Lọc tin nhắn theo số điện thoại cụ thể
      _buildGroupTab(), // Phân nhóm QC, OTP và xử lý bóc tách mã 6 số
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Analyzer - Bài tập 7'),
        centerTitle: true,
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: 'Lọc SĐT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Nhóm (QC / OTP)',
          ),
        ],
      ),
    );
  }

  // --- TAB 1: THỐNG KÊ TỔNG QUAN & THEO NGÀY/THÁNG ---
  Widget _buildStatisticsTab() {
    int totalMessages = _allMessages.length;
    int totalAd = _allMessages.where((m) => m.isAd).length;
    int totalOtp = _allMessages.where((m) => m.isOtp).length;

    // Thống kê số lượng theo ngày
    Map<String, int> dateStats = {};
    for (var msg in _allMessages) {
      dateStats[msg.date] = (dateStats[msg.date] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            'Thống kê tổng quan tin nhắn',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Tổng số tin nhắn nhận được: $totalMessages',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('• Tổng số tin Quảng cáo ([QC]): $totalAd',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('• Tổng số tin chứa mã OTP: $totalOtp',
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Thống kê theo Ngày / Tháng',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...dateStats.entries.map((entry) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.indigo),
                title: Text('Ngày: ${entry.key}'),
                trailing: Text(
                  '${entry.value} tin nhắn',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- TAB 2: LỌC TIN NHẮN THEO SỐ ĐIỆN THOẠI / NGƯỜI GỬI ---
  Widget _buildFilterSenderTab() {
    // Lấy danh sách các số gửi độc lập
    List<String> senders = _allMessages.map((m) => m.sender).toSet().toList();

    List<SmsModel> filteredList = _selectedSenderFilter == null
        ? _allMessages
        : _allMessages.where((m) => m.sender == _selectedSenderFilter).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lọc danh sách tin nhắn theo số/người gửi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Chọn số điện thoại / Người gửi',
            ),
            value: _selectedSenderFilter,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Tất cả các số'),
              ),
              ...senders.map((sender) {
                return DropdownMenuItem<String>(
                  value: sender,
                  child: Text(sender),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSenderFilter = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final msg = filteredList[index];
                return Card(
                  child: ListTile(
                    title: Text(msg.body),
                    subtitle: Text('Từ: ${msg.sender} | Ngày: ${msg.date}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: PHÂN NHÓM QUẢNG CÁO & MÃ OTP (BÓC TÁCH 6 SỐ) ---
  Widget _buildGroupTab() {
    List<SmsModel> adMessages = _allMessages.where((m) => m.isAd).toList();
    List<SmsModel> otpMessages = _allMessages.where((m) => m.isOtp).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Quảng cáo ([QC])'),
              Tab(text: 'Mã OTP (Xử lý 6 số)'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Tab con Quảng cáo
                ListView.builder(
                  itemCount: adMessages.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.pink.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.campaign, color: Colors.red),
                        title: Text(adMessages[index].body),
                        subtitle: Text('Gửi từ: ${adMessages[index].sender}'),
                      ),
                    );
                  },
                ),
                // Tab con OTP (Bấm vào để hiển thị mã 6 số)
                ListView.builder(
                  itemCount: otpMessages.length,
                  itemBuilder: (context, index) {
                    final msg = otpMessages[index];
                    return Card(
                      color: Colors.green.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.security, color: Colors.green),
                        title: Text(msg.body),
                        subtitle: Text('Gửi từ: ${msg.sender} (Bấm để xem OTP)'),
                        trailing: const Icon(Icons.touch_app),
                        onTap: () {
                          // Xử lý lấy chuỗi 6 ký số của OTP và hiển thị khi được chọn
                          String? otpCode = msg.extractOtpCode;
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác thực mã OTP'),
                              content: Text(
                                'Mã OTP 6 số được tìm thấy:\n\n👉 $otpCode 👈',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Đóng'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}