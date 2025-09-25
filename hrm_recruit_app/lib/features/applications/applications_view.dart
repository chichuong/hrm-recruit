import 'package:flutter/material.dart';

class ApplicationsView extends StatelessWidget {
  const ApplicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ứng viên')),
      body: const Center(child: Text('Quản lý hồ sơ ứng viên (Day 6)')),
    );
  }
}
