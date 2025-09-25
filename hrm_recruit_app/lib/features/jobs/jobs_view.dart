import 'package:flutter/material.dart';

class JobsView extends StatelessWidget {
  const JobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // <— bỏ const ở đây
      appBar: AppBar(title: const Text('Tuyển dụng')),
      body: const Center(child: Text('Danh sách công việc (Day 4)')),
    );
  }
}
