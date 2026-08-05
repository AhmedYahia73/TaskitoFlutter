class UserModel {
  final String id;
  final String name;
  final String email;
  final String? image;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
      role: json['role'] ?? '',
    );
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return double.tryParse(value)?.toInt() ?? 0;
  return 0;
}

class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final String? documentation;
  final int progress;
  final int doneProgress;
  final String? testerName;
  final String? testerImage;
  final List<UserModel> users;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.documentation,
    required this.progress,
    required this.doneProgress,
    this.testerName,
    this.testerImage,
    required this.users,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      documentation: json['documentation'],
      progress: _parseInt(json['progress']),
      doneProgress: _parseInt(json['done_progress']),
      testerName: json['tester_name'],
      testerImage: json['tester_image'],
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => UserModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String? documentation;
  final int progress;
  final int doneProgress;
  final String createdAt;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.documentation,
    required this.progress,
    required this.doneProgress,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      documentation: json['documentation'],
      progress: _parseInt(json['progress']),
      doneProgress: _parseInt(json['done_progress']),
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class TaskModel {
  final String id;
  final String name;
  final String? description;
  final String status;
  final String importanceStatus;
  final String? deliveryDate;
  final String? testerNote;
  final String? documentation;
  final String? userId;
  final String? userName;
  final String? userImage;

  TaskModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.importanceStatus,
    this.deliveryDate,
    this.testerNote,
    this.documentation,
    this.userId,
    this.userName,
    this.userImage,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'pending',
      importanceStatus: json['importanc_status'] ?? 'medium',
      deliveryDate: json['delivery_date'],
      testerNote: json['tester_note'],
      documentation: json['documentation'],
      userId: json['user_id']?.toString(),
      userName: json['user_name'],
      userImage: json['user_image'],
    );
  }
}
