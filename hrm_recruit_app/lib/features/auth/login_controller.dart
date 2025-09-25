import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../core/config/dio_client.dart';

class LoginController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;
  final storage = const FlutterSecureStorage();

  Future<bool> login() async {
    isLoading.value = true;
    try {
      final dio = DioClient.instance;
      final res = await dio.post(
        '/auth/login',
        data: {'email': email.value, 'password': password.value},
      );
      if (res.statusCode == 200 && res.data['ok'] == true) {
        await storage.write(key: 'accessToken', value: res.data['accessToken']);
        await storage.write(
          key: 'refreshToken',
          value: res.data['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
