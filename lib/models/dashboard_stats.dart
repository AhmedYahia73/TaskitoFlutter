class DashboardStats {
  final int pendingTasks;
  final int doneTasks;
  final int delayTasks;
  final int totalTasks;
  final int approveTasks;
  final int engineersCount;
  final int allProjects;

  DashboardStats({
    required this.pendingTasks,
    required this.doneTasks,
    required this.delayTasks,
    required this.totalTasks,
    required this.approveTasks,
    required this.engineersCount,
    required this.allProjects,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      pendingTasks: json['pending_tasks'] ?? 0,
      doneTasks: json['done_tasks'] ?? 0,
      delayTasks: json['delay_tasks'] ?? 0,
      totalTasks: json['total_tasks'] ?? 0,
      approveTasks: json['approve_tasks'] ?? 0,
      engineersCount: json['engineers_count'] ?? 0,
      allProjects: json['all_projects'] ?? 0,
    );
  }
}

class PointsData {
  final int totalPointsAllTime;
  final List<MonthlyPoint> chartData;

  PointsData({
    required this.totalPointsAllTime,
    required this.chartData,
  });

  factory PointsData.fromJson(Map<String, dynamic> json) {
    var chartList = json['chartData'] as List? ?? [];
    List<MonthlyPoint> chartData = chartList.map((i) => MonthlyPoint.fromJson(i)).toList();
    
    return PointsData(
      totalPointsAllTime: json['totalPointsAllTime'] ?? 0,
      chartData: chartData,
    );
  }
}

class MonthlyPoint {
  final String name;
  final int points;

  MonthlyPoint({
    required this.name,
    required this.points,
  });

  factory MonthlyPoint.fromJson(Map<String, dynamic> json) {
    return MonthlyPoint(
      name: json['name'] ?? '',
      points: json['points'] ?? 0,
    );
  }
}
