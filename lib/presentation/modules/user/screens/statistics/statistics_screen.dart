import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/injector.dart';
import '../../bloc/statistics/statistics_bloc.dart';
import '../../bloc/statistics/statistics_event.dart';
import '../../bloc/statistics/statistics_state.dart';

class StatisticsScreen extends StatelessWidget {
  static const String routeName = '/statistics';

  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = StatisticsBloc(
          injector(),
          injector(),
        );
        // Set period và load data
        bloc.add(const ChangePeriod('week'));
        bloc.add(const LoadWeightPrediction());
        return bloc;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0F0E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0F0E),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Thống kê',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            if (state.isLoadingCalories && state.isLoadingPrediction) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF52C41A)),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selector
                  _buildPeriodSelector(context, state),
                  const SizedBox(height: 24),
                  
                  // Calories Stats Chart
                  if (state.caloriesStats != null)
                    _buildCaloriesChart(context, state.caloriesStats!),
                  
                  const SizedBox(height: 24),
                  
                  // Weight Prediction
                  if (state.weightPrediction != null)
                    _buildWeightPrediction(context, state.weightPrediction!),
                  
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, StatisticsState state) {
    return Center( // Căn giữa nếu cần
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment<String>(
            value: 'week',
            label: Text('Tuần'),
          ),
          ButtonSegment<String>(
            value: 'month',
            label: Text('Tháng'),
          ),
        ],
        selected: {state.selectedPeriod},
        onSelectionChanged: (Set<String> newSelection) {
          if (newSelection.isNotEmpty) {
            context.read<StatisticsBloc>().add(ChangePeriod(newSelection.first));
          }
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.grey.shade900.withOpacity(0.8), // Nền nút không chọn: xám rất tối, hơi trong suốt để hòa với background
          selectedBackgroundColor: const Color(0xFF52C41A), // Nền nút chọn: xanh lá nổi bật
          foregroundColor: Colors.white, // Chữ luôn trắng
          selectedForegroundColor: Colors.black87, // Chữ trên nút chọn: đen đậm để tương phản tốt với nền xanh
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Bo tròn mạnh hơn, giống capsule/pill shape
            side: const BorderSide(color: Color(0xFF52C41A), width: 1.5), // Viền xanh lá nhẹ quanh toàn bộ segmented button
          ),
          elevation: 4, // Thêm bóng nhẹ để nổi lên
          shadowColor: Colors.black.withOpacity(0.4),
        ),
        showSelectedIcon: false,
        emptySelectionAllowed: false,
      ),
    );
  }

  Widget _buildCaloriesChart(BuildContext context, caloriesStats) {
    final dailyData = caloriesStats.dailyData;
    final summary = caloriesStats.summary;

    // Luôn hiển thị biểu đồ và summary, kể cả khi không có dữ liệu
    // (dailyData sẽ có tất cả các ngày với giá trị 0)

    return Card(
      color: const Color(0xFF1C1E1D),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calories Nạp vào & Tiêu thụ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < dailyData.length) {
                            final date = dailyData[value.toInt()].date;
                            final dateObj = DateTime.tryParse(date);
                            if (dateObj != null) {
                              return Text(
                                DateFormat('dd/MM').format(dateObj),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              );
                            }
                          }
                          return const Text('');
                        },
                        interval: dailyData.length > 7 ? 2 : 1,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyData.asMap().entries.map<FlSpot>((e) {
                        return FlSpot(e.key.toDouble(), e.value.caloriesIn.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: dailyData.asMap().entries.map<FlSpot>((e) {
                        return FlSpot(e.key.toDouble(), e.value.caloriesOut.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildLegend('Nạp vào', Colors.blue),
                const SizedBox(width: 16),
                _buildLegend('Tiêu thụ', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Tổng nạp vào', '${summary.totalCaloriesIn} cal'),
            _buildSummaryRow('Tổng tiêu thụ', '${summary.totalCaloriesOut} cal'),
            _buildSummaryRow('Net calories', '${summary.totalNetCalories} cal'),
            _buildSummaryRow('Trung bình/ngày', '${summary.avgDailyNet} cal'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightPrediction(BuildContext context, prediction) {
    return Card(
      color: const Color(0xFF1C1E1D),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dự đoán Đạt Mục tiêu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Cân nặng hiện tại', '${prediction.currentWeight.toStringAsFixed(1)} kg'),
            _buildSummaryRow('Mục tiêu', '${prediction.goalWeight.toStringAsFixed(1)} kg'),
            _buildSummaryRow('Cần thay đổi', '${prediction.weightToChange.toStringAsFixed(2)} kg'),
            const SizedBox(height: 8),
            _buildSummaryRow('Tốc độ/ngày', '${prediction.ratePerDay.toStringAsFixed(3)} kg'),
            _buildSummaryRow('Tốc độ/tuần', '${prediction.ratePerWeek.toStringAsFixed(2)} kg'),
            _buildSummaryRow('Tốc độ/tháng', '${prediction.ratePerMonth.toStringAsFixed(2)} kg'),
            const SizedBox(height: 16),
            if (prediction.canReachGoal && prediction.targetDate != null) ...[
              const SizedBox(height: 16),
              _buildSummaryRow(
                'Dự kiến đạt mục tiêu',
                _formatDate(prediction.targetDate!),
                color: const Color(0xFF52C41A),
              ),
              if (prediction.daysToGoal != null)
                _buildSummaryRow('Còn lại', '${prediction.daysToGoal} ngày'),
              if (prediction.weeksToGoal != null)
                _buildSummaryRow('', '(${prediction.weeksToGoal} tuần)'),
            ] else if (prediction.message != null) ...[
              const SizedBox(height: 16),
              Text(
                prediction.message!,
                style: const TextStyle(color: Colors.orange),
              ),
            ],
            if (prediction.predictions != null) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                'Dự đoán tương lai:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildSummaryRow('1 tuần', '${prediction.predictions!.in1Week.toStringAsFixed(1)} kg'),
              _buildSummaryRow('1 tháng', '${prediction.predictions!.in1Month.toStringAsFixed(1)} kg'),
              _buildSummaryRow('3 tháng', '${prediction.predictions!.in3Months.toStringAsFixed(1)} kg'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

