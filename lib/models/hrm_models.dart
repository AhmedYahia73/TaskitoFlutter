class AttendanceStatusModel {
  final bool isCheckedIn;

  AttendanceStatusModel({required this.isCheckedIn});

  factory AttendanceStatusModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatusModel(
      isCheckedIn: json['isCheckedIn'] ?? false,
    );
  }
}

class YearlyHolidaysSummary {
  final int remaining;
  final int used;
  final int totalAllowed;
  final int exceeded;

  YearlyHolidaysSummary({
    required this.remaining,
    required this.used,
    required this.totalAllowed,
    required this.exceeded,
  });

  factory YearlyHolidaysSummary.fromJson(Map<String, dynamic> json) {
    return YearlyHolidaysSummary(
      remaining: json['remaining'] ?? 0,
      used: json['used'] ?? 0,
      totalAllowed: json['totalAllowed'] ?? 0,
      exceeded: json['exceeded'] ?? 0,
    );
  }
}

class FinancialItem {
  final String type;
  final dynamic amount;

  FinancialItem({required this.type, required this.amount});

  factory FinancialItem.fromJson(Map<String, dynamic> json) {
    return FinancialItem(
      type: json['type'] ?? '',
      amount: json['amount'] ?? 0,
    );
  }
}

class Financials {
  final List<FinancialItem> bonuses;
  final List<FinancialItem> deductions;

  Financials({required this.bonuses, required this.deductions});

  factory Financials.fromJson(Map<String, dynamic> json) {
    return Financials(
      bonuses: (json['bonuses'] as List<dynamic>?)
              ?.map((e) => FinancialItem.fromJson(e))
              .toList() ??
          [],
      deductions: (json['deductions'] as List<dynamic>?)
              ?.map((e) => FinancialItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ReportSummary {
  final double totalDelay;
  final int onsiteDays;
  final int onlineWithRequest;
  final int onlineWithoutRequest;
  final int onlineRejected;
  final int holidayApproved;
  final int holidayRejected;
  final int holidayStandard;
  final int unexcusedAbsence;
  final double totalPermissionHours;

  ReportSummary({
    required this.totalDelay,
    required this.onsiteDays,
    required this.onlineWithRequest,
    required this.onlineWithoutRequest,
    required this.onlineRejected,
    required this.holidayApproved,
    required this.holidayRejected,
    required this.holidayStandard,
    required this.unexcusedAbsence,
    required this.totalPermissionHours,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalDelay: (json['totalDelay'] ?? 0).toDouble(),
      onsiteDays: json['onsiteDays'] ?? 0,
      onlineWithRequest: json['onlineWithRequest'] ?? 0,
      onlineWithoutRequest: json['onlineWithoutRequest'] ?? 0,
      onlineRejected: json['onlineRejected'] ?? 0,
      holidayApproved: json['holidayApproved'] ?? 0,
      holidayRejected: json['holidayRejected'] ?? 0,
      holidayStandard: json['holidayStandard'] ?? 0,
      unexcusedAbsence: json['unexcusedAbsence'] ?? 0,
      totalPermissionHours: (json['totalPermissionHours'] ?? 0).toDouble(),
    );
  }
}

class ReportAttendance {
  final String? from;
  final String? to;
  final double? hours;
  final double? delay;
  final double? permissionHours;

  ReportAttendance({
    this.from,
    this.to,
    this.hours,
    this.delay,
    this.permissionHours,
  });

  factory ReportAttendance.fromJson(Map<String, dynamic> json) {
    return ReportAttendance(
      from: json['from'],
      to: json['to'],
      hours: json['hours'] != null ? double.tryParse(json['hours'].toString()) : null,
      delay: json['delay'] != null ? double.tryParse(json['delay'].toString()) : null,
      permissionHours: json['permissionHours'] != null ? double.tryParse(json['permissionHours'].toString()) : null,
    );
  }
}

class ReportItem {
  final String date;
  final String day;
  final String status;
  final String? color;
  final ReportAttendance? attendance;

  ReportItem({
    required this.date,
    required this.day,
    required this.status,
    this.color,
    this.attendance,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      status: json['status'] ?? '',
      color: json['color'],
      attendance: json['attendance'] != null
          ? ReportAttendance.fromJson(json['attendance'])
          : null,
    );
  }
}

class AttendanceReportResponse {
  final YearlyHolidaysSummary? yearlyHolidaysSummary;
  final Financials? financials;
  final ReportSummary? summary;
  final List<ReportItem> report;
  final int totalPages;

  AttendanceReportResponse({
    this.yearlyHolidaysSummary,
    this.financials,
    this.summary,
    required this.report,
    required this.totalPages,
  });

  factory AttendanceReportResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceReportResponse(
      yearlyHolidaysSummary: json['yearlyHolidaysSummary'] != null
          ? YearlyHolidaysSummary.fromJson(json['yearlyHolidaysSummary'])
          : null,
      financials: json['financials'] != null
          ? Financials.fromJson(json['financials'])
          : null,
      summary: json['summary'] != null
          ? ReportSummary.fromJson(json['summary'])
          : null,
      report: (json['report'] as List<dynamic>?)
              ?.map((e) => ReportItem.fromJson(e))
              .toList() ??
          [],
      totalPages: json['pagination']?['totalPages'] ?? 1,
    );
  }
}
