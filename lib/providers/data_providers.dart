import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final projectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final response = await api.dio.get('/api/admin/project?limit=100');
    final List<dynamic> projectsJson = response.data['Projects'] ?? [];
    return projectsJson.map((json) => ProjectModel.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Failed to load projects: $e');
  }
});

final groupsProvider = FutureProvider.family<List<GroupModel>, int>((ref, projectId) async {
  final api = ref.read(apiServiceProvider);
  try {
    final response = await api.dio.get('/api/admin/projectGroup?project_id=$projectId&limit=100');
    final List<dynamic> groupsJson = response.data['groups'] ?? [];
    return groupsJson.map((json) => GroupModel.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Failed to load groups: $e');
  }
});

final tasksProvider = FutureProvider.family<List<TaskModel>, int>((ref, groupId) async {
  final api = ref.read(apiServiceProvider);
  try {
    final response = await api.dio.get('/api/admin/tasks?group_id=$groupId&limit=100');
    final List<dynamic> tasksJson = response.data['tasks'] ?? [];
    return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Failed to load tasks: $e');
  }
});
