import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../core/config/dio_client.dart';

class HomeController extends GetxController {
  final status = RxString('checking...');
  final timestamp = RxString('');

  @override
  void onInit() {
    super.onInit();
    checkHealth();
  }

  Future<void> checkHealth() async {
    try {
      final Dio dio = DioClient.instance;
      final res = await dio.get('/health');
      if (res.statusCode == 200 && res.data['ok'] == true) {
        status.value = 'OK';
        timestamp.value = res.data['ts'] ?? '';
      } else {
        status.value = 'Service not ready';
      }
    } catch (e) {
      status.value = 'Cannot reach API';
    }
  }
}
