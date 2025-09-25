// Model Job an toàn null-safety + parse linh hoạt
class Job {
  final int id;
  final String title;
  final String description;
  final String? level; // Junior/Mid/Senior (optional)
  final String? type; // Full-time/Part-time/Intern (optional)
  final int? salaryFrom; // optional
  final int? salaryTo; // optional
  final String status; // draft|published|closed
  final DateTime createdAt;
  final DateTime? publishedAt;
  final DateTime? updatedAt; // optional (nếu BE trả về)

  const Job({
    required this.id,
    required this.title,
    required this.description,
    this.level,
    this.type,
    this.salaryFrom,
    this.salaryTo,
    required this.status,
    required this.createdAt,
    this.publishedAt,
    this.updatedAt,
  });

  /// Parse linh hoạt từ JSON (string datetime hoặc DateTime, int/double cho lương)
  factory Job.fromJson(Map<String, dynamic> j) {
    DateTime _parseDt(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) return DateTime.parse(v);
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      throw FormatException('Unsupported datetime format: $v');
    }

    DateTime? _parseDtNullable(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) return DateTime.parse(v);
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return null;
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is num) return v.toInt();
      if (v is String && v.trim().isNotEmpty) {
        final n = num.tryParse(v.trim());
        return n?.toInt();
      }
      return null;
    }

    return Job(
      id: (j['id'] as num).toInt(),
      title: (j['title'] ?? '') as String,
      description: (j['description'] ?? '') as String,
      level: j['level'] as String?,
      type: j['type'] as String?,
      salaryFrom: _toInt(j['salaryFrom']),
      salaryTo: _toInt(j['salaryTo']),
      status: (j['status'] ?? 'draft') as String,
      createdAt: _parseDt(j['createdAt']),
      publishedAt: _parseDtNullable(j['publishedAt']),
      updatedAt: _parseDtNullable(j['updatedAt']),
    );
    // Lưu ý: nếu BE không trả createdAt/updatedAt/publishedAt,
    // bạn có thể bỏ các field này hoặc để nullable tùy nhu cầu UI.
  }

  /// toJson để gửi lên BE (create/update). Không include các field server quản lý.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      if (level != null) 'level': level,
      if (type != null) 'type': type,
      if (salaryFrom != null) 'salaryFrom': salaryFrom,
      if (salaryTo != null) 'salaryTo': salaryTo,
      if (status.isNotEmpty) 'status': status,
      // Không gửi createdAt/publishedAt/updatedAt/id khi tạo/sửa
    };
  }

  Job copyWith({
    int? id,
    String? title,
    String? description,
    String? level,
    String? type,
    int? salaryFrom,
    int? salaryTo,
    String? status,
    DateTime? createdAt,
    DateTime? publishedAt,
    DateTime? updatedAt,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      type: type ?? this.type,
      salaryFrom: salaryFrom ?? this.salaryFrom,
      salaryTo: salaryTo ?? this.salaryTo,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Job(id: $id, title: $title, status: $status, level: $level, type: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Job && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
