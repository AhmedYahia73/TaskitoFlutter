import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class PaginationState<T> {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  PaginationState({
    required this.items,
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

class ProjectsNotifier extends StateNotifier<PaginationState<ProjectModel>> {
  final ApiService api;
  ProjectsNotifier(this.api) : super(PaginationState(items: [])) {
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true, page: 1, items: [], error: null, hasMore: true);
    await _fetchData();
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, page: state.page + 1);
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await api.dio.get('/api/admin/project?page=${state.page}&limit=10');
      final List<dynamic> jsonList = response.data['data']['Projects'] ?? [];
      final List<ProjectModel> newItems = jsonList.map((j) => ProjectModel.fromJson(j)).toList();
      
      final int totalPages = response.data['data']['pagination']['totalPages'] ?? 1;

      state = state.copyWith(
        items: [...state.items, ...newItems],
        hasMore: state.page < totalPages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final projectsProvider = StateNotifierProvider<ProjectsNotifier, PaginationState<ProjectModel>>((ref) {
  return ProjectsNotifier(ref.read(apiServiceProvider));
});

class GroupsNotifier extends StateNotifier<PaginationState<GroupModel>> {
  final ApiService api;
  final String projectId;
  
  GroupsNotifier(this.api, this.projectId) : super(PaginationState(items: [])) {
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true, page: 1, items: [], error: null, hasMore: true);
    await _fetchData();
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, page: state.page + 1);
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await api.dio.get('/api/admin/projectGroup?project_id=$projectId&page=${state.page}&limit=10');
      final List<dynamic> jsonList = response.data['data']['groups'] ?? [];
      final List<GroupModel> newItems = jsonList.map((j) => GroupModel.fromJson(j)).toList();
      
      final int totalPages = response.data['data']['pagination']['totalPages'] ?? 1;

      state = state.copyWith(
        items: [...state.items, ...newItems],
        hasMore: state.page < totalPages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final groupsProvider = StateNotifierProvider.family<GroupsNotifier, PaginationState<GroupModel>, String>((ref, projectId) {
  return GroupsNotifier(ref.read(apiServiceProvider), projectId);
});

class TasksNotifier extends StateNotifier<PaginationState<TaskModel>> {
  final ApiService api;
  final String groupId;
  
  TasksNotifier(this.api, this.groupId) : super(PaginationState(items: [])) {
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true, page: 1, items: [], error: null, hasMore: true);
    await _fetchData();
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, page: state.page + 1);
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await api.dio.get('/api/admin/tasks?group_id=$groupId&page=${state.page}&limit=10');
      final List<dynamic> jsonList = response.data['data']['tasks'] ?? [];
      final List<TaskModel> newItems = jsonList.map((j) => TaskModel.fromJson(j)).toList();
      
      final int totalPages = response.data['data']['pagination']['totalPages'] ?? 1;

      state = state.copyWith(
        items: [...state.items, ...newItems],
        hasMore: state.page < totalPages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  void invalidate() {
    fetchFirstPage();
  }
}

final tasksProvider = StateNotifierProvider.family<TasksNotifier, PaginationState<TaskModel>, String>((ref, groupId) {
  return TasksNotifier(ref.read(apiServiceProvider), groupId);
});

final projectUsersProvider = FutureProvider.family<List<UserModel>, String>((ref, projectId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.dio.get('/api/admin/projects/$projectId/users');
  return (response.data['data']['users'] as List).map((e) => UserModel.fromJson(e)).toList();
});

final groupUsersProvider = FutureProvider.family<List<UserModel>, String>((ref, groupId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.dio.get('/api/admin/project-groups/$groupId/users');
  return (response.data['data']['users'] as List).map((e) => UserModel.fromJson(e)).toList();
});
