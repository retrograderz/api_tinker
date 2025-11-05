import 'package:flutter/material.dart';
import 'get_screen.dart'; // Import màn hình GET mới
import 'post_screen.dart'; // Import màn hình POST mới

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo Flutter API',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        // Cài đặt chung cho Card và TextField để trông đẹp hơn
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const HomeScreen(), // Trang chủ là HomeScreen
    );
  }
}

// HomeScreen là màn hình điều hướng
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onDestSelect(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.get_app), label: "GET"),
          NavigationDestination(icon: Icon(Icons.upload), label: "POST"),
        ],
        onDestinationSelected: _onDestSelect,
        selectedIndex: _currentIndex,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [GetScreen(), PostScreen()],
      ),
    );
  }
}
