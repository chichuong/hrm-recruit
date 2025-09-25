import 'package:get/get.dart';
import 'job_model.dart';
import 'job_service.dart';

class JobsController extends GetxController {
  final _service = JobService();

  final items = <Job>[].obs;
  final isLoading = false.obs;
  final page = 1.obs;
  final limit = 10.obs;
  final total = 0.obs;
  final search = ''.obs;
  final status = ''.obs;

  Future<void> load({int? p}) async {
    isLoading.value = true;
    try {
      final cur = p ?? page.value;
      final (list, t) = await _service.fetchJobs(
        page: cur,
        limit: limit.value,
        search: search.value.isEmpty ? null : search.value,
        status: status.value.isEmpty ? null : status.value,
      );
      items.assignAll(list);
      total.value = t;
      page.value = cur;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createJob(Map<String, dynamic> data) async {
    await _service.create(data);
    await load(p: 1);
  }

  Future<void> publishJob(int id) async {
    await _service.publish(id);
    await load(p: page.value);
  }

  Future<void> closeJob(int id) async {
    await _service.close(id);
    await load(p: page.value);
  }

  Future<void> deleteJob(int id) async {
    await _service.remove(id);
    await load(p: 1);
  }
}
