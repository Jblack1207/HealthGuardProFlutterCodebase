import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HRLineChart extends StatelessWidget {
  final List<dynamic> readings;

  const HRLineChart({
    super.key,
    required this.readings,
  });

  @override
  Widget build(BuildContext context) {
    final chartReadings = readings
        .whereType<Map<String, dynamic>>()
        .toList()
        .reversed
        .take(20)
        .toList();

    if (chartReadings.length < 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF27272A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: const Column(
          children: [
            Text(
              'Not enough data to show graph.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ChartKeyItem(color: Color(0xffffc21c), label: 'BPM'),
                _ChartKeyItem(color: Color(0xff4FC3F7), label: 'SpO2'),
                _ChartKeyItem(color: Color(0xff66BB6A), label: 'Temp'),
              ],
            ),
          ],
        ),
      );
    }

    final hrSpots = <FlSpot>[];
    final spo2Spots = <FlSpot>[];
    final tempSpots = <FlSpot>[];

    for (int i = 0; i < chartReadings.length; i++) {
      final reading = chartReadings[i];

      final bpm = (reading['heart_rate'] as num?)?.toDouble();
      final spo2 = (reading['spo2'] as num?)?.toDouble();
      final temp = (reading['temperature'] as num?)?.toDouble();

      if (bpm != null) {
        hrSpots.add(FlSpot(i.toDouble(), bpm));
      }

      if (spo2 != null) {
        spo2Spots.add(FlSpot(i.toDouble(), spo2));
      }

      if (temp != null) {
        tempSpots.add(FlSpot(i.toDouble(), temp));
      }
    }
    return Container(
      height: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF27272A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 10,
                maxY: 200,
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Colors.white10,
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (_) => const FlLine(
                    color: Colors.white10,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white12),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: hrSpots,
                    isCurved: true,
                    color: const Color(0xffffc21c),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: spo2Spots,
                    isCurved: true,
                    color: const Color(0xff4FC3F7),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: tempSpots,
                    isCurved: true,
                    color: const Color(0xff66BB6A),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ChartKeyItem(color: Color(0xffffc21c), label: 'BPM'),
              _ChartKeyItem(color: Color(0xff4FC3F7), label: 'SpO2'),
              _ChartKeyItem(color: Color(0xff66BB6A), label: 'Temp'),
            ],
          ),
        ],
      ),
    );
  }
}
class _ChartKeyItem extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartKeyItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

