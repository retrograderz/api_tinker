import 'package:flutter/material.dart';
import 'api_service.dart'; // Import service của bạn

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  // Biến quản lý trạng thái
  bool _isLoading = false;
  String? _statusMessage; // Để hiển thị thông báo thành công hoặc lỗi
  Color _messageColor = Colors.black;

  Future<void> _submitData() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Vui lòng nhập cả Tiêu đề và Nội dung';
        _messageColor = Colors.red;
      });
      return;
    }

    // Bắt đầu loading
    setState(() {
      _isLoading = true;
      _statusMessage = null; // Xóa thông báo cũ
    });

    try {
      // Dữ liệu mẫu (userId = 1)
      final newPost = await createPost(
        _titleController.text,
        _bodyController.text,
        1,
      );

      // Thành công!
      setState(() {
        _statusMessage = 'Tạo bài viết thành công! ID mới là: ${newPost['id']}';
        _messageColor = Colors.green;
        _titleController.clear();
        _bodyController.clear();
      });
    } catch (e) {
      // Bị lỗi
      setState(() {
        _statusMessage = 'Lỗi: $e';
        _messageColor = Colors.red;
      });
    } finally {
      // Dừng loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo POST Request')),
      body: SingleChildScrollView(
        // Dùng SingleChildScrollView để tránh lỗi overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "https://jsonplaceholder.typicode.com/",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Tạo bài viết mới',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Trường nhập Tiêu đề
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tiêu đề (Title)',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Trường nhập Nội dung
                      TextField(
                        controller: _bodyController,
                        decoration: const InputDecoration(
                          labelText: 'Nội dung (Body)',
                        ),
                        maxLines: 5, // Cho phép nhập nhiều dòng
                      ),
                      const SizedBox(height: 24),

                      // Nút Gửi hoặc Vòng xoay
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _submitData,
                              child: const Text('GỬI LÊN SERVER'),
                            ),

                      // Vùng hiển thị thông báo
                      if (_statusMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _statusMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _messageColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
