import 'dart:io';
import 'package:flutter/foundation.dart'; // Để dùng kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(PhotoCaptureApp());
}

class PhotoCaptureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Capture & Preview',
      theme: ThemeData(primarySwatch: Colors.green),
      home: PhotoCaptureHome(),
    );
  }
}

class PhotoCaptureHome extends StatefulWidget {
  @override
  _PhotoCaptureHomeState createState() => _PhotoCaptureHomeState();
}

class _PhotoCaptureHomeState extends State<PhotoCaptureHome> {
  File? _imageFile;
  String? _assetImagePath; // Lưu đường dẫn ảnh từ assets (h1.jpg hoặc h2.jpg)
  final ImagePicker _picker = ImagePicker();

  Future<void> _requestPermission(Permission permission) async {
    if (!kIsWeb && await permission.isDenied) {
      await permission.request();
    }
  }

  // Thay vì mở thư viện, nút này sẽ gán trực tiếp ảnh h1.jpg vào ứng dụng
  Future<void> _pickImageFromGallery() async {
    setState(() {
      _assetImagePath = 'assets/images/h1.jpg'; // Gán ảnh 1 cho Gallery
      _imageFile = null;
    });
  }

  // Thay vì mở camera, nút này sẽ gán trực tiếp ảnh h2.jpg vào ứng dụng
  Future<void> _captureImageFromCamera() async {
    setState(() {
      _assetImagePath = 'assets/images/h2.jpg'; // Gán ảnh 2 cho Camera
      _imageFile = null;
    });
  }

  // Xem trước ảnh toàn màn hình
  void _showFullScreenPreview(BuildContext context) {
    if (_imageFile != null || _assetImagePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImage(
            imageFile: _imageFile,
            assetImagePath: _assetImagePath,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo Capture & Preview')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hiển thị trạng thái hoặc ảnh đã chọn
              (_imageFile == null && _assetImagePath == null)
                  ? Text('Chưa có ảnh nào được chọn.', style: TextStyle(fontSize: 16))
                  : GestureDetector(
                      onTap: () => _showFullScreenPreview(context),
                      child: _imageFile != null
                          ? Image.file(_imageFile!, height: 250, fit: BoxFit.cover)
                          : Image.asset(_assetImagePath!, height: 250, fit: BoxFit.cover),
                    ),
              SizedBox(height: 20),

              // Nút "Chọn ảnh từ Gallery" -> Tự động load h1.jpg
              ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: Text('Chọn ảnh từ Gallery (Load h1.jpg)'),
              ),
              SizedBox(height: 10),

              // Nút "Chụp ảnh từ Camera" -> Tự động load h2.jpg
              ElevatedButton(
                onPressed: _captureImageFromCamera,
                child: Text('Chụp ảnh từ Camera (Load h2.jpg)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget xem trước toàn màn hình
class FullScreenImage extends StatelessWidget {
  final File? imageFile;
  final String? assetImagePath;

  FullScreenImage({this.imageFile, this.assetImagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Xem trước toàn màn hình')),
      body: Center(
        child: InteractiveViewer(
          child: imageFile != null
              ? Image.file(imageFile!)
              : Image.asset(assetImagePath!),
        ),
      ),
    );
  }
}