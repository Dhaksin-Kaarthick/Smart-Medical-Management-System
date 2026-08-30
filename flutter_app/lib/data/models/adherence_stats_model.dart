/// Statistical aggregation of medicine adherence rates, missed counts, and weekly trend data.
class AdherenceStatsModel {
  final double overallPercentage;
  final double weekPercentage;
  final double monthPercentage;
  final int totalScheduled;
  final int totalTaken;
  final int totalMissed;
  final int totalLate;
  final List<DailyAdherenceData> weeklyTrend;

  const AdherenceStatsModel({
    required this.overallPercentage,
    required this.weekPercentage,
    required this.monthPercentage,
    required this.totalScheduled,
    required this.totalTaken,
    required this.totalMissed,
    required this.totalLate,
    required this.weeklyTrend,
  });

  factory AdherenceStatsModel.empty() {
    return AdherenceStatsModel(
      overallPercentage: 100.0,
      weekPercentage: 100.0,
      monthPercentage: 100.0,
      totalScheduled: 0,
      totalTaken: 0,
      totalMissed: 0,
      totalLate: 0,
      weeklyTrend: [
        DailyAdherenceData(day: 'Mon', rate: 100),
        DailyAdherenceData(day: 'Tue', rate: 100),
        DailyAdherenceData(day: 'Wed', rate: 100),
        DailyAdherenceData(day: 'Thu', rate: 100),
        DailyAdherenceData(day: 'Fri', rate: 100),
        DailyAdherenceData(day: 'Sat', rate: 100),
        DailyAdherenceData(day: 'Sun', rate: 100),
      ],
    );
  }
}

class DailyAdherenceData {
  final String day;
  final double rate; // 0 - 100

  const DailyAdherenceData({
    required this.day,
    required this.rate,
  });
}
