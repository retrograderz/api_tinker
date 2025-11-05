import 'package:flutter/material.dart';
import 'api_service.dart'; // Import service của bạn

// Định nghĩa 2 chế độ tìm kiếm
enum SearchType { byPostId, byUserId }

class GetScreen extends StatefulWidget {
  const GetScreen({Key? key}) : super(key: key);

  @override
  State<GetScreen> createState() => _GetScreenState();
}

class _GetScreenState extends State<GetScreen> {
  final TextEditingController _idController = TextEditingController(text: '1');

  // Biến state để lưu trữ chế độ tìm kiếm
  SearchType _searchType = SearchType.byPostId;

  // Biến Future bây giờ phải là <dynamic> vì nó có thể là Map hoặc List
  Future<dynamic>? _apiFuture;

  @override
  void initState() {
    super.initState();
    // Tự động gọi API lần đầu tiên với Post ID = 1
    _fetchData();
  }

  // Hàm được gọi khi nhấn nút
  void _fetchData() {
    // Cập nhật state để FutureBuilder chạy lại với Future mới
    setState(() {
      if (_searchType == SearchType.byPostId) {
        // Nếu tìm theo Post ID, gọi hàm trả về Map
        _apiFuture = fetchPostById(_idController.text);
      } else {
        // Nếu tìm theo User ID, gọi hàm trả về List
        _apiFuture = fetchPostsByUserId(_idController.text);
      }
    });
  }

  // Lấy label cho TextField dựa trên chế độ tìm kiếm
  String get _labelText {
    return _searchType == SearchType.byPostId
        ? 'Nhập Post ID (ví dụ: 1, 2...)'
        : 'Nhập User ID (ví dụ: 1, 2...)';
  }

  // Lấy prefix text cho TextField
  String get _prefixText {
    return _searchType == SearchType.byPostId ? 'posts/' : 'posts?userId=';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo GET Request')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            // --- VÙNG NHẬP LIỆU ---
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Nút chọn chế độ
                    ToggleButtons(
                      isSelected: [
                        _searchType == SearchType.byPostId,
                        _searchType == SearchType.byUserId,
                      ],
                      onPressed: (index) {
                        setState(() {
                          _searchType = index == 0
                              ? SearchType.byPostId
                              : SearchType.byUserId;
                        });
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Tìm theo Post ID'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Tìm theo User ID'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Hàng nhập liệu
                    Row(
                      children: [
                        Text(
                          _prefixText,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _idController,
                            decoration: InputDecoration(labelText: _labelText),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _fetchData,
                          child: const Text('GET'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- VÙNG HIỂN THỊ KẾT QUẢ ---
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    // FutureBuilder bây giờ là <dynamic>
                    child: FutureBuilder<dynamic>(
                      future: _apiFuture,
                      builder: (context, snapshot) {
                        // 1. Đang tải
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        // 2. Bị Lỗi
                        if (snapshot.hasError) {
                          return Text(
                            'Lỗi: ${snapshot.error}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          );
                        }

                        // 3. Có Dữ Liệu
                        if (snapshot.hasData) {
                          final data = snapshot.data;

                          // --- KIỂM TRA QUAN TRỌNG ---
                          // Kiểm tra xem data trả về là Map hay List

                          if (data is Map<String, dynamic>) {
                            // Nếu là Map, hiển thị 1 bài viết (kết quả từ byPostId)
                            return _buildSinglePost(data);
                          } else if (data is List) {
                            // Nếu là List, hiển thị danh sách (kết quả từ byUserId)
                            if (data.isEmpty) {
                              return const Text(
                                'Không tìm thấy bài viết nào cho User ID này.',
                                style: TextStyle(fontSize: 16),
                              );
                            }
                            return _buildPostList(data);
                          }
                        }

                        // Mặc định
                        return const Text('Chưa có dữ liệu.');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget phụ để hiển thị 1 bài viết (Khi data là Map) ---
  Widget _buildSinglePost(Map<String, dynamic> post) {
    return ListView(
      children: [
        Text(
          post['title'] ?? 'Không có tiêu đề',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          post['body'] ?? 'Không có nội dung',
          style: const TextStyle(fontSize: 18),
        ),
        const Divider(height: 30),
        Text('User ID: ${post['userId']}'),
        Text('Post ID: ${post['id']}'),
      ],
    );
  }

  // --- Widget phụ để hiển thị danh sách bài viết (Khi data là List) ---
  Widget _buildPostList(List<dynamic> posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tìm thấy ${posts.length} bài viết:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index] as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text(post['id'].toString())),
                  title: Text(
                    post['title'] ?? 'Không có tiêu đề',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    post['body'] ?? 'Không có nội dung',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
