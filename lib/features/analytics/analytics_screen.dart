import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/providers/analytics_provider.dart';
import '../../core/providers/exercise_provider.dart';
import '../../core/utils/theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, size: 20),
            onPressed: () => context.read<AnalyticsProvider>().refresh(),
          ),
        ],
      ),
      body: const _AnalyticsBody(),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody();

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();

    if (!analytics.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (analytics.totalWorkouts == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.chart_2, size: 56, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text('No data yet', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Complete workouts to see your analytics',
                style: TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryRow(analytics: analytics),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Weekly Volume', subtitle: 'Last 8 weeks (kg)'),
        const SizedBox(height: 12),
        _VolumeChart(analytics: analytics),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Workout Frequency', subtitle: 'Workouts per month'),
        const SizedBox(height: 12),
        _FrequencyChart(analytics: analytics),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Personal Records', subtitle: 'Estimated 1RM per exercise'),
        const SizedBox(height: 12),
        _PRList(analytics: analytics),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final AnalyticsProvider analytics;
  const _SummaryRow({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final hours = analytics.totalTime.inHours;
    final mins = analytics.totalTime.inMinutes.remainder(60);
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Row(children: [
      Expanded(child: _SummaryCard(icon: Iconsax.activity, label: 'Workouts', value: '${analytics.totalWorkouts}', color: AppTheme.primary)),
      const SizedBox(width: 10),
      Expanded(child: _SummaryCard(icon: Iconsax.timer_1, label: 'Total Time', value: timeStr, color: AppTheme.accent)),
      const SizedBox(width: 10),
      Expanded(child: _SummaryCard(icon: Iconsax.flash_1, label: 'Streak', value: '${analytics.currentStreak}d', color: AppTheme.warning)),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _SummaryCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title, subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        ],
      );
}

class _VolumeChart extends StatelessWidget {
  final AnalyticsProvider analytics;
  const _VolumeChart({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final data = analytics.weeklyVolume;
    if (data.isEmpty) return const SizedBox.shrink();

    final entries = data.entries.toList();
    final maxVol = entries.map((e) => e.value).fold(0.0, (a, b) => a > b ? a : b);

    final bars = List.generate(entries.length, (i) {
      final vol = entries[i].value;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: vol,
            color: vol == maxVol && vol > 0
                ? AppTheme.primary
                : AppTheme.primary.withValues(alpha: 0.45),
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ],
      );
    });

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(4, 12, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: BarChart(
        BarChartData(
          barGroups: bars,
          maxY: maxVol > 0 ? maxVol * 1.2 : 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (val, _) => Text(
                  val >= 1000 ? '${(val / 1000).toStringAsFixed(1)}k' : val.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= entries.length) return const SizedBox();
                  final d = entries[idx].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${d.day}/${d.month}',
                        style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppTheme.surfaceElevated,
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${rod.toY.toStringAsFixed(0)} kg',
                const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FrequencyChart extends StatelessWidget {
  final AnalyticsProvider analytics;
  const _FrequencyChart({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final data = analytics.monthlyCount;
    if (data.isEmpty) return const SizedBox.shrink();

    final entries = data.entries.toList();
    final maxCount = entries.map((e) => e.value).fold(0, (a, b) => a > b ? a : b);
    final spots = List.generate(entries.length, (i) => FlSpot(i.toDouble(), entries[i].value.toDouble()));

    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(4, 12, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxCount > 0 ? (maxCount + 2).toDouble() : 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 2,
                getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= entries.length) return const SizedBox();
                  final parts = entries[idx].key.split('-');
                  const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                  final m = int.tryParse(parts.last) ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(monthNames[m],
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.accent,
              barWidth: 2.5,
              dotData: FlDotData(
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.accent,
                  strokeColor: AppTheme.bg,
                  strokeWidth: 2,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.accent.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PRList extends StatelessWidget {
  final AnalyticsProvider analytics;
  const _PRList({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final prs = analytics.personalRecords;
    final exerciseProvider = context.read<ExerciseProvider>();

    if (prs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Center(
          child: Text('No PRs yet — complete some workouts!',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    final sorted = prs.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: sorted.asMap().entries.map((entry) {
          final idx = entry.key;
          final pr = entry.value;
          final exercise = exerciseProvider.getById(pr.key);
          final name = exercise?.name ?? pr.key;
          final isLast = idx == sorted.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: idx < 3
                          ? AppTheme.pr.withValues(alpha: 0.15)
                          : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        idx < 3 ? ['🥇', '🥈', '🥉'][idx] : '${idx + 1}',
                        style: TextStyle(
                          fontSize: idx < 3 ? 14 : 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        if (exercise != null)
                          Text(exercise.muscleGroup,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${pr.value.toStringAsFixed(1)} kg',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.pr)),
                      const Text('est. 1RM', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    ],
                  ),
                ]),
              ),
              if (!isLast) const Divider(height: 1, indent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
