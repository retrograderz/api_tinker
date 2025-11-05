import 'package:http/http.dart' as http; // Gói http để gọi API
import 'dart:convert'; // Gói 'dart:convert' để làm việc với JSON

// --- HÀM CHO GET REQUEST ---

/**
 * Mục tiêu: Lấy 1 bài viết từ API theo id người dùng nhập
 * - Dùng 'async' vì đây là một hành động bất đồng bộ.
 * - Trả về một 'Future<Map<String, dynamic>>' vì kết quả là một Object JSON.
 */
Future<Map<String, dynamic>> fetchPostById(String id) async {
  // Nếu id rỗng, ném lỗi để UI xử lý
  if (id.isEmpty) {
    throw Exception('Vui lòng nhập ID');
  }

  final String apiUrl = 'https://jsonplaceholder.typicode.com/posts/$id';

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // API này trả về {} rỗng với mã 404 nếu không tìm thấy
      throw Exception(
        'Không tìm thấy bài viết (Mã lỗi: ${response.statusCode})',
      );
    }
  } catch (e) {
    throw Exception('Đã xảy ra lỗi: $e');
  }
}

/**
 * Lấy TẤT CẢ các bài viết dựa trên User ID.
 * Trả về một List, không phải Map.
 */
Future<List<dynamic>> fetchPostsByUserId(String userId) async {
  if (userId.isEmpty) {
    throw Exception('Vui lòng nhập User ID');
  }
  // URL sử dụng query parameter (dấu ?)
  final String apiUrl =
      'https://jsonplaceholder.typicode.com/posts?userId=$userId';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      // jsonDecode sẽ trả về một List<dynamic> vì JSON trả về là [...]
      return jsonDecode(response.body);
    } else {
      throw Exception('Lỗi khi tải dữ liệu (Mã lỗi: ${response.statusCode})');
    }
  } catch (e) {
    throw Exception('Đã xảy ra lỗi: $e');
  }
}

// --- HÀM CHO POST REQUEST ---

/**
 * Mục tiêu: Tạo một bài viết mới.
 * Cần 3 tham số: title, body, và userId.
 */
Future<Map<String, dynamic>> createPost(
  String title,
  String body,
  int userId,
) async {
  final String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

  // BƯỚC 1: Chuẩn bị dữ liệu (Body) và Headers

  // Dữ liệu chúng ta muốn gửi đi, tạo thành một Map
  final Map<String, dynamic> postData = {
    'title': title,
    'body': body,
    'userId': userId,
  };

  // Headers bắt buộc khi gửi JSON
  final Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // BƯỚC 2: Gọi http.post
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      // Dùng jsonEncode để chuyển đổi Map (postData) thành chuỗi JSON
      body: jsonEncode(postData),
    );

    // BƯỚC 3: Kiểm tra kết quả
    if (response.statusCode == 201) {
      // 201 Created -> Thành công
      // Trả về đối tượng JSON mà server đã tạo
      return jsonDecode(response.body);
    } else {
      // Ném lỗi nếu server trả về mã khác
      throw Exception('Tạo bài viết thất bại. Mã lỗi: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Đã xảy ra lỗi khi POST: $e');
  }
}
