import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/hrm_models.dart';
import '../services/api_service.dart';

// Provider for checking attendance status
final attendanceStatusProvider = FutureProvider.autoDispose<AttendanceStatusModel>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final response = await api.dio.get('/api/user/attendance/status');
    return AttendanceStatusModel.fromJson(response.data);
  } catch (e) {
    throw Exception('Failed to load attendance status: $e');
  }
});

// State for Report Pagination
class AttendanceReportState {
  final AttendanceReportResponse? reportData;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  AttendanceReportState({
    this.reportData,
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  AttendanceReportState copyWith({
    AttendanceReportResponse? reportData,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return AttendanceReportState(
      reportData: reportData ?? this.reportData,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

// Notifier for fetching report
class AttendanceReportNotifier extends StateNotifier<AttendanceReportState> {
  final ApiService api;
  final String from;
  final String to;

  AttendanceReportNotifier(this.api, this.from, this.to) : super(AttendanceReportState()) {
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true, page: 1, error: null, hasMore: true);
    await _fetchData();
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, page: state.page + 1);
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await api.dio.get('/api/user/attendance/report?from=$from&to=$to&page=${state.page}&limit=15');
      final newResponse = AttendanceReportResponse.fromJson(response.data['data'] ?? response.data);

      if (state.page == 1) {
        state = state.copyWith(
          reportData: newResponse,
          hasMore: state.page < newResponse.totalPages,
          isLoading: false,
        );
      } else {
        final existingReport = state.reportData;
        if (existingReport != null) {
          final updatedItems = [...existingReport.report, ...newResponse.report];
          final updatedResponse = AttendanceReportResponse(
            yearlyHolidaysSummary: existingReport.yearlyHolidaysSummary,
            financials: existingReport.financials,
            summary: existingReport.summary,
            report: updatedItems,
            totalPages: newResponse.totalPages,
          );
          state = state.copyWith(
            reportData: updatedResponse,
            hasMore: state.page < newResponse.totalPages,
            isLoading: false,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Family provider to pass 'from' and 'to' dates
final attendanceReportProvider = StateNotifierProvider.family<AttendanceReportNotifier, AttendanceReportState, Map<String, String>>((ref, dates) {
  return AttendanceReportNotifier(ref.read(apiServiceProvider), dates['from']!, dates['to']!);
});

// Helper class for HRM Actions
class HrmActions {
  final ApiService api;

  HrmActions(this.api);

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    } 

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> checkIn() async {
    try {
      final position = await _determinePosition();
      final res = await api.dio.post('/api/user/attendance/check-in', data: {
        'lat': position.latitude,
        'lng': position.longitude,
      });
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkOut() async {
    try {
      final position = await _determinePosition();
      final res = await api.dio.put('/api/user/attendance/check-out', data: {
        'lat': position.latitude,
        'lng': position.longitude,
      });
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitHolidayRequest(String date) async {
    final res = await api.dio.post('/api/user/requests/holiday', data: {'date': date});
    return res.data;
  }

  Future<Map<String, dynamic>> submitOnlineRequest(String date) async {
    final res = await api.dio.post('/api/user/requests/online', data: {'date': date});
    return res.data;
  }

  Future<Map<String, dynamic>> submitPermissionRequest(String date, double hours, String reason) async {
    final res = await api.dio.post('/api/user/requests/permission', data: {
      'date': date,
      'hours': hours,
      'reason': reason,
    });
    return res.data;
  }
}

final hrmActionsProvider = Provider((ref) => HrmActions(ref.read(apiServiceProvider)));
