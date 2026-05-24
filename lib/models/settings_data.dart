import '../utils/number_utils.dart';

class SettingsData {
  const SettingsData({
    required this.annualTarget,
    required this.monthlyDeductibleCap,
    required this.notificationsEnabled,
  });

  factory SettingsData.defaults() => const SettingsData(
    annualTarget: 15000,
    monthlyDeductibleCap: 1800,
    notificationsEnabled: true,
  );

  final double annualTarget;
  final double monthlyDeductibleCap;
  final bool notificationsEnabled;

  SettingsData copyWith({
    double? annualTarget,
    double? monthlyDeductibleCap,
    bool? notificationsEnabled,
  }) {
    return SettingsData(
      annualTarget: annualTarget ?? this.annualTarget,
      monthlyDeductibleCap: monthlyDeductibleCap ?? this.monthlyDeductibleCap,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'annualTarget': annualTarget,
    'monthlyDeductibleCap': monthlyDeductibleCap,
    'notificationsEnabled': notificationsEnabled,
  };

  factory SettingsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SettingsData.defaults();
    return SettingsData(
      annualTarget: readDouble(json['annualTarget'], 15000),
      monthlyDeductibleCap: readDouble(json['monthlyDeductibleCap'], 1800),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }
}
