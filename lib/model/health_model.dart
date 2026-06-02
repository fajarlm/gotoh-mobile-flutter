/// Model MedicalCheckup sesuai BE (tabel medical_checkups)
class MedicalCheckupModel {
  final int id;
  final int userId;
  final String? date;
  final String? bloodPressure;
  final int? heartRate;
  final double? bloodSugar;
  final double? cholesterol;
  final double? weight;
  final double? height;
  final DateTime? createdAt;

  const MedicalCheckupModel({
    required this.id,
    required this.userId,
    this.date,
    this.bloodPressure,
    this.heartRate,
    this.bloodSugar,
    this.cholesterol,
    this.weight,
    this.height,
    this.createdAt,
  });

  /// Hitung BMI jika weight & height tersedia
  double? get bmi {
    if (weight != null && height != null && height! > 0) {
      final heightM = height! / 100;
      return weight! / (heightM * heightM);
    }
    return null;
  }

  /// Kategori BMI
  String get bmiCategory {
    final b = bmi;
    if (b == null) return 'Unknown';
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }

  factory MedicalCheckupModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return MedicalCheckupModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      date: json['date']?.toString(),
      bloodPressure: json['blood_pressure']?.toString(),
      heartRate: parseInt(json['heart_rate']),
      bloodSugar: parseDouble(json['blood_sugar']),
      cholesterol: parseDouble(json['cholesterol']),
      weight: parseDouble(json['weight']),
      height: parseDouble(json['height']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}

/// Model ExerciseRecommendation sesuai BE (tabel exercise_recommendations)
class ExerciseRecommendationModel {
  final int id;
  final String bmiCategory;
  final String recommendation;
  final int duration;
  final DateTime? createdAt;

  const ExerciseRecommendationModel({
    required this.id,
    required this.bmiCategory,
    required this.recommendation,
    required this.duration,
    this.createdAt,
  });

  factory ExerciseRecommendationModel.fromJson(Map<String, dynamic> json) {
    return ExerciseRecommendationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      bmiCategory: json['bmi_category'] ?? '',
      recommendation: json['recommendation'] ?? '',
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
