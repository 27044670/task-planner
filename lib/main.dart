import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TaskPlannerApp());
}

class TaskPlannerApp extends StatelessWidget {
  const TaskPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '任务规划表',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
