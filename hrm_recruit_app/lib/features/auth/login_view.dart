import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LoginController());
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (v) => c.email.value = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
              onChanged: (v) => c.password.value = v,
            ),
            const SizedBox(height: 20),
            Obx(
              () => ElevatedButton(
                onPressed: c.isLoading.value
                    ? null
                    : () async {
                        final ok = await c.login();
                        if (ok) {
                          Get.snackbar('Success', 'Đăng nhập thành công');
                          Get.offAllNamed('/'); // về MainNav
                        } else {
                          Get.snackbar('Error', 'Sai email hoặc mật khẩu');
                        }
                      },
                child: c.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text('Đăng nhập'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
