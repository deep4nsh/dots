import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/daily_insight.dart';
import '../../../../core/theme/app_colors.dart';

class MoodTrendChart extends StatelessWidget {
  final List<MoodDataPoint> dataPoints;

  const MoodTrendChart({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 8),
      decoration: BoxDecoration(
        color: AppColors.greyDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyMedium.withOpacity(0.3)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.greyMedium.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _calculateInterval(),
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) return const SizedBox.shrink();
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: AppColors.greyLight,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: dataPoints.first.time.millisecondsSinceEpoch.toDouble(),
          maxX: dataPoints.last.time.millisecondsSinceEpoch.toDouble(),
          minY: -1.2,
          maxY: 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints.map((p) => FlSpot(
                p.time.millisecondsSinceEpoch.toDouble(),
                p.sentiment,
              )).toList(),
              isCurved: true,
              color: AppColors.white,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.black,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.white.withOpacity(0.2),
                    AppColors.white.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.white,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final data = dataPoints[spot.spotIndex];
                  return LineTooltipItem(
                    '${data.mood ?? 'Neutral'}\n${(data.sentiment * 100).toInt()}%',
                    const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  double _calculateInterval() {
    if (dataPoints.length < 2) return 1.0;
    final diff = dataPoints.last.time.difference(dataPoints.first.time).inMilliseconds;
    return diff / 3;
  }
}
