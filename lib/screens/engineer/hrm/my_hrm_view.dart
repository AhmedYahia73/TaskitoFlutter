import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/hrm_providers.dart';
import 'widgets/request_bottom_sheet.dart';

class MyHrmView extends ConsumerStatefulWidget {
  const MyHrmView({super.key});

  @override
  ConsumerState<MyHrmView> createState() => _MyHrmViewState();
}

class _MyHrmViewState extends ConsumerState<MyHrmView> {
  late String _fromDate;
  late String _toDate;
  final ScrollController _scrollController = ScrollController();
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
    _toDate = DateTime(now.year, now.month + 1, 0).toIso8601String().split('T')[0];

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(attendanceReportProvider({'from': _fromDate, 'to': _toDate}).notifier).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleAttendanceAction(bool isCheckIn) async {
    setState(() => _isChecking = true);
    try {
      final actions = ref.read(hrmActionsProvider);
      if (isCheckIn) {
        await actions.checkIn();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully checked in!')));
      } else {
        await actions.checkOut();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully checked out!')));
      }
      ref.invalidate(attendanceStatusProvider);
      ref.read(attendanceReportProvider({'from': _fromDate, 'to': _toDate}).notifier).fetchFirstPage();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(attendanceStatusProvider);
    final reportState = ref.watch(attendanceReportProvider({'from': _fromDate, 'to': _toDate}));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My HRM', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Attendance Status Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: statusAsync.when(
                data: (status) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.location_on, size: 40, color: Colors.blue),
                        const SizedBox(height: 16),
                        Text(
                          status.isCheckedIn ? 'You are currently checked in.' : 'You have not checked in yet today.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: status.isCheckedIn ? Colors.amber.shade700 : Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isChecking ? null : () => _handleAttendanceAction(!status.isCheckedIn),
                            icon: _isChecking
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Icon(status.isCheckedIn ? Icons.logout : Icons.login),
                            label: Text(status.isCheckedIn ? 'Check Out' : 'Check In'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: status.isCheckedIn ? Colors.amber.shade600 : Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading status: $e')),
              ),
            ),
          ),

          // Monthly Report Section Title & Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly Attendance Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker('From', _fromDate, (val) {
                          setState(() {
                            _fromDate = val;
                            ref.read(attendanceReportProvider({'from': _fromDate, 'to': _toDate}).notifier).fetchFirstPage();
                          });
                        }),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePicker('To', _toDate, (val) {
                          setState(() {
                            _toDate = val;
                            ref.read(attendanceReportProvider({'from': _fromDate, 'to': _toDate}).notifier).fetchFirstPage();
                          });
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Premium Summary Cards
          if (reportState.reportData != null)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (reportState.reportData!.yearlyHolidaysSummary != null)
                      _buildGradientCard(
                        'Yearly Holidays',
                        'Remaining: ${reportState.reportData!.yearlyHolidaysSummary!.remaining}',
                        'Used: ${reportState.reportData!.yearlyHolidaysSummary!.used}',
                        Colors.indigo,
                        Colors.blue,
                        Icons.park,
                      ),
                    if (reportState.reportData!.financials != null) ...[
                      _buildGradientCard(
                        'Bonuses',
                        '\$${reportState.reportData!.financials!.bonuses.where((b) => b.type == 'amount').fold(0.0, (sum, b) => sum + (b.amount is num ? b.amount : double.tryParse(b.amount.toString()) ?? 0))}',
                        'Days: ${reportState.reportData!.financials!.bonuses.where((b) => b.type == 'days').fold(0.0, (sum, b) => sum + (b.amount is num ? b.amount : double.tryParse(b.amount.toString()) ?? 0))}',
                        Colors.teal,
                        Colors.tealAccent,
                        Icons.card_giftcard,
                      ),
                      _buildGradientCard(
                        'Deductions',
                        '\$${reportState.reportData!.financials!.deductions.where((d) => d.type == 'amount').fold(0.0, (sum, d) => sum + (d.amount is num ? d.amount : double.tryParse(d.amount.toString()) ?? 0))}',
                        'Days: ${reportState.reportData!.financials!.deductions.where((d) => d.type == 'days').fold(0.0, (sum, d) => sum + (d.amount is num ? d.amount : double.tryParse(d.amount.toString()) ?? 0))}',
                        Colors.red.shade700,
                        Colors.pink,
                        Icons.money_off,
                      ),
                    ],
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Report List
          if (reportState.isLoading && reportState.reportData == null)
            const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))),
          
          if (reportState.reportData != null)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == reportState.reportData!.report.length) {
                    return reportState.hasMore
                        ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                        : const SizedBox.shrink();
                  }
                  final item = reportState.reportData!.report[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(item.day, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(item.status, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (item.attendance?.from != null) Text('In: ${DateFormat('hh:mm a').format(DateTime.parse(item.attendance!.from!))}'),
                            if (item.attendance?.to != null) Text('Out: ${DateFormat('hh:mm a').format(DateTime.parse(item.attendance!.to!))}'),
                            if (item.attendance?.hours != null) Text('Hours: ${item.attendance!.hours!.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                childCount: reportState.reportData!.report.length + (reportState.hasMore ? 1 : 0),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const RequestBottomSheet(),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add_task),
        label: const Text('New Request'),
      ),
    );
  }

  Widget _buildDatePicker(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.parse(value),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              onChanged(picked.toIso8601String().split('T')[0]);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 14)),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientCard(String title, String val1, String val2, Color color1, Color color2, IconData icon) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color1.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Icon(icon, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 16),
          Text(val1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          Text(val2, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}
