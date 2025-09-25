import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'jobs_controller.dart';

class JobsView extends StatelessWidget {
  const JobsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(JobsController());
    c.load();

    final searchCtl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Tuyển dụng')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchCtl,
                    decoration: const InputDecoration(
                      hintText: 'Tìm theo tiêu đề/mô tả',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (v) {
                      c.search.value = v;
                      c.load(p: 1);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: c.status.value.isEmpty ? null : c.status.value,
                  hint: const Text('Trạng thái'),
                  items: const [
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    DropdownMenuItem(
                      value: 'published',
                      child: Text('Published'),
                    ),
                    DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  ],
                  onChanged: (v) {
                    c.status.value = v ?? '';
                    c.load(p: 1);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (c.items.isEmpty) {
                return const Center(child: Text('Chưa có tin tuyển dụng'));
              }
              return ListView.separated(
                itemCount: c.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final job = c.items[i];
                  return ListTile(
                    title: Text(job.title),
                    subtitle: Text(
                      '${job.status.toUpperCase()} • ${job.level ?? '-'} • ${job.type ?? '-'}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        switch (v) {
                          case 'publish':
                            c.publishJob(job.id);
                            break;
                          case 'close':
                            c.closeJob(job.id);
                            break;
                          case 'delete':
                            c.deleteJob(job.id);
                            break;
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'publish',
                          child: Text('Publish'),
                        ),
                        const PopupMenuItem(
                          value: 'close',
                          child: Text('Close'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Xoá'),
                        ),
                      ],
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => _JobForm(
                          onSubmit: (data) async {
                            await c.createJob(data);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => _JobForm(
              onSubmit: (data) async {
                await c.createJob(data);
                Navigator.pop(context);
              },
            ),
          );
        },
        label: const Text('Đăng tin'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _JobForm extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onSubmit;
  const _JobForm({required this.onSubmit});

  @override
  State<_JobForm> createState() => _JobFormState();
}

class _JobFormState extends State<_JobForm> {
  final _formKey = GlobalKey<FormState>();
  final titleCtl = TextEditingController();
  final descCtl = TextEditingController();
  final levelCtl = TextEditingController();
  final typeCtl = TextEditingController();
  final salaryFromCtl = TextEditingController();
  final salaryToCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tạo/Sửa tin tuyển dụng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: titleCtl,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nhập tiêu đề' : null,
              ),
              TextFormField(
                controller: descCtl,
                decoration: const InputDecoration(labelText: 'Mô tả công việc'),
                minLines: 3,
                maxLines: 5,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nhập mô tả' : null,
              ),
              TextFormField(
                controller: levelCtl,
                decoration: const InputDecoration(
                  labelText: 'Cấp độ (tuỳ chọn)',
                ),
              ),
              TextFormField(
                controller: typeCtl,
                decoration: const InputDecoration(
                  labelText: 'Hình thức (tuỳ chọn)',
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: salaryFromCtl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Lương từ'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: salaryToCtl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Lương đến'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final data = {
                    'title': titleCtl.text.trim(),
                    'description': descCtl.text.trim(),
                    if (levelCtl.text.isNotEmpty) 'level': levelCtl.text.trim(),
                    if (typeCtl.text.isNotEmpty) 'type': typeCtl.text.trim(),
                    if (salaryFromCtl.text.isNotEmpty)
                      'salaryFrom': int.tryParse(salaryFromCtl.text),
                    if (salaryToCtl.text.isNotEmpty)
                      'salaryTo': int.tryParse(salaryToCtl.text),
                  };
                  await widget.onSubmit(data);
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
