import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: Center(
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'API /health: ${c.status.value}',
                style: const TextStyle(fontSize: 18),
              ),
              if (c.timestamp.isNotEmpty) Text('ts: ${c.timestamp.value}'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: c.checkHealth,
                child: const Text('Kiểm tra lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
