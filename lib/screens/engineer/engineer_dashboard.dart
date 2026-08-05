import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard_stats.dart';
import 'hrm/my_hrm_view.dart' as hrm;

class EngineerDashboard extends ConsumerStatefulWidget {
  const EngineerDashboard({super.key});

  @override
  ConsumerState<EngineerDashboard> createState() => _EngineerDashboardState();
}

class _EngineerDashboardState extends ConsumerState<EngineerDashboard> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardStatsProvider);
    final pointsAsync = ref.watch(pointsDataProvider(_selectedYear));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDKaopi0pxG06IiW-SjMZ01I3cBPJ70x6Hjl0XqOa-Di6A0YvL_RhJq6mbfPpbZ0v23roO0hALT2t0JKFGv4BTEE8uM-7a25IOFCLhzK5R9p-qwSebam8M8qR18DEiwH7PSrxypwx0RDamSMwzC29K9lHF6beWCLIqeq7ex-W5Cgwmh7Up7nRBPh0PNkGyczydg1-9ZjAJNKkL2dGvMhbLPYBHIE8Glms9dqoJxFMoW24ZYol73sZ6PpwvP1aA0O9w35aY',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.business),
            ),
            const SizedBox(width: 8),
            Text('WegoStation', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCheckInCard(context),
            const SizedBox(height: 24),
            Text(
              'My Workspace',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome back! Here\'s your task overview.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 24),
            
            // Dashboard Stats
            dashboardAsync.when(
              data: (stats) => _buildOverviewGrid(context, stats),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
            ),
            
            const SizedBox(height: 32),
            
            // Points Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.purple, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Points Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                DropdownButton<int>(
                  value: _selectedYear,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: List.generate(5, (index) => DateTime.now().year - index)
                      .map((year) => DropdownMenuItem(
                            value: year,
                            child: Text(year.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedYear = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Points Stats
            pointsAsync.when(
              data: (points) => _buildPointsSection(context, points),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Ready to start your day?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const hrm.MyHrmView()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.fingerprint,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tap to Check In',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(BuildContext context, DashboardStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _GlassCard(
                color: Colors.amber,
                icon: Icons.access_time_filled,
                title: 'Pending Tasks',
                value: stats.pendingTasks.toString(),
                progressValue: stats.doneTasks,
                progressTotal: stats.pendingTasks,
                progressLabel: 'Done / Pending',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GlassCard(
                color: Colors.red,
                icon: Icons.error,
                title: 'Delayed Tasks',
                value: stats.delayTasks.toString(),
                progressValue: stats.doneTasks,
                progressTotal: stats.delayTasks,
                progressLabel: 'Done / Delay',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _GlassCard(
          color: Theme.of(context).primaryColor,
          icon: Icons.check_circle,
          title: 'My Progress',
          value: '',
          progressValue: stats.doneTasks,
          progressTotal: stats.totalTasks,
          progressLabel: 'Done Tasks',
          isFullWidth: true,
          extraProgressValue: stats.approveTasks,
          extraProgressLabel: 'Approved',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _GlassCard(
                color: Colors.indigo,
                icon: Icons.group,
                title: 'Team Members',
                value: stats.engineersCount.toString(),
                subtitle: 'Engineers & Testers',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GlassCard(
                color: Colors.teal,
                icon: Icons.business_center,
                title: 'All Projects',
                value: stats.allProjects.toString(),
                subtitle: 'Total system projects',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPointsSection(BuildContext context, PointsData data) {
    int thisYearPoints = data.chartData.fold(0, (sum, item) => sum + item.points);
    int thisMonthPoints = data.chartData.isNotEmpty && DateTime.now().month <= data.chartData.length
        ? data.chartData[DateTime.now().month - 1].points
        : 0;

    return Column(
      children: [
        _PointCard(
          title: 'All Time Points',
          points: data.totalPointsAllTime,
          color: Colors.purple,
          icon: Icons.workspace_premium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PointCard(
                title: 'This Year',
                points: thisYearPoints,
                color: Colors.blue,
                icon: Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PointCard(
                title: 'This Month',
                points: thisMonthPoints,
                color: Colors.green,
                icon: Icons.today,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final int? progressValue;
  final int? progressTotal;
  final String? progressLabel;
  final int? extraProgressValue;
  final String? extraProgressLabel;
  final bool isFullWidth;

  const _GlassCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.progressValue,
    this.progressTotal,
    this.progressLabel,
    this.extraProgressValue,
    this.extraProgressLabel,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              letterSpacing: 1.1,
                            ),
                      ),
                    ),
                    if (value.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            value,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                subtitle!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (progressTotal != null && progressValue != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: isFullWidth ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
              children: [
                _buildCircularProgress(context, progressValue!, progressTotal!, progressLabel!, color),
                if (extraProgressValue != null && extraProgressLabel != null)
                  _buildCircularProgress(context, extraProgressValue!, progressTotal!, extraProgressLabel!, Colors.green),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildCircularProgress(BuildContext context, int val, int total, String label, Color ringColor) {
    double percent = total > 0 ? (val / total) : 0;
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: percent,
                strokeWidth: 6,
                backgroundColor: ringColor.withOpacity(0.1),
                color: ringColor,
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${(percent * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$val / $total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _PointCard extends StatelessWidget {
  final String title;
  final int points;
  final Color color;
  final IconData icon;

  const _PointCard({
    required this.title,
    required this.points,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: color.withOpacity(0.8),
                  ),
                ),
                Text(
                  points.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    color: color.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
