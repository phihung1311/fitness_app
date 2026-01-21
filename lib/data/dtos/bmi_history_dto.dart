import '../../domain/entities/bmi_history.dart';

class BMIHistoryDto {
  final List<Map<String, dynamic>> daily_data;
  final Map<String, dynamic> summary;

  BMIHistoryDto({
    required this.daily_data,
    required this.summary,
  });

  factory BMIHistoryDto.fromJson(Map<String, dynamic> json) {
    return BMIHistoryDto(
      daily_data: (json['daily_data'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      summary: json['summary'] as Map<String, dynamic>? ?? {},
    );
  }

  BMIHistory toEntity() {
    return BMIHistory(
      dailyData: daily_data.map((d) => DailyBMIData(
            date: d['date']?.toString() ?? '',
            bmi: d['bmi'] is double
                ? d['bmi'] as double
                : double.tryParse(d['bmi']?.toString() ?? '0') ?? 0.0,
          )).toList(),
      summary: BMISummary(
        currentBMI: summary['current_bmi'] is double
            ? summary['current_bmi'] as double?
            : double.tryParse(summary['current_bmi']?.toString() ?? ''),
        averageBMI: summary['average_bmi'] is double
            ? summary['average_bmi'] as double?
            : double.tryParse(summary['average_bmi']?.toString() ?? ''),
        minBMI: summary['min_bmi'] is double
            ? summary['min_bmi'] as double?
            : double.tryParse(summary['min_bmi']?.toString() ?? ''),
        maxBMI: summary['max_bmi'] is double
            ? summary['max_bmi'] as double?
            : double.tryParse(summary['max_bmi']?.toString() ?? ''),
      ),
    );
  }
}
