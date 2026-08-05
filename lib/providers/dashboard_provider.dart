import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/dashboard_stats.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  try {
    final response = await apiService.dio.get('/api/admin/dashboard');
    if (response.statusCode == 200) {
      // Handle wrapped data depending on your API structure. 
      // If data is inside 'data' key: response.data['data']
      final data = response.data['data'] ?? response.data;
      return DashboardStats.fromJson(data);
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  } catch (e) {
    throw Exception('Error loading dashboard stats: $e');
  }
});

final pointsDataProvider = FutureProvider.family<PointsData, int>((ref, year) async {
  try {
    final response = await apiService.dio.get('/api/admin/dashboard/points-chart?year=$year');
    if (response.statusCode == 200) {
      final data = response.data['data'] ?? response.data;
      return PointsData.fromJson(data);
    } else {
      throw Exception('Failed to load points data');
    }
  } catch (e) {
    throw Exception('Error loading points data: $e');
  }
});
