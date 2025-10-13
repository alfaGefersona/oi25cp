import 'package:flutter/material.dart';

import '../features/connection/presentation/pages/wifi_socket_page.dart';
import '../features/explore/presentation/explore_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/training/presentation/training_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int index = 0;
  final pages = const [HomePage(), ExplorePage(), TrainingPage(), WifiSocketPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.travel_explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_tennis), label: "Treinos"),
          BottomNavigationBarItem(icon: Icon(Icons.wifi), label: "Wi-Fi"),
        ],
      ),
    );
  }
}
