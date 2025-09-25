import 'package:dio/dio.dart';
import '../../core/config/dio_client.dart';
import 'job_model.dart';

class JobService {
  final Dio _dio = DioClient.instance;

  Future<(List<Job>, int)> fetchJobs({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
  }) async {
    final res = await _dio.get(
      '/jobs',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final list = (res.data['data'] as List)
        .map((e) => Job.fromJson(e))
        .toList();
    final total = res.data['meta']['total'] as int;
    return (list, total);
  }

  Future<Job> create(Map<String, dynamic> data) async {
    final res = await _dio.post('/jobs', data: data);
    return Job.fromJson(res.data['data']);
  }

  Future<Job> getById(int id) async {
    final res = await _dio.get('/jobs/$id');
    return Job.fromJson(res.data['data']);
  }

  Future<Job> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/jobs/$id', data: data);
    return Job.fromJson(res.data['data']);
  }

  Future<Job> publish(int id) async {
    final res = await _dio.patch('/jobs/$id/publish');
    return Job.fromJson(res.data['data']);
  }

  Future<Job> close(int id) async {
    final res = await _dio.patch('/jobs/$id/close');
    return Job.fromJson(res.data['data']);
  }

  Future<void> remove(int id) async {
    await _dio.delete('/jobs/$id');
  }
}
