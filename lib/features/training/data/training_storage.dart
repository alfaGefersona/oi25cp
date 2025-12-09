import 'package:shared_preferences/shared_preferences.dart';

class TrainingStorage {
  final String trainingKey;

  TrainingStorage(this.trainingKey);

  Future<Map<String, double>> load() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'motor1': prefs.getDouble('${trainingKey}_m1') ?? 120,
      'motor2': prefs.getDouble('${trainingKey}_m2') ?? 180,
      'motor3': prefs.getDouble('${trainingKey}_m3') ?? 180,
      'motor4': prefs.getDouble('${trainingKey}_m4') ?? 150,
    };
  }

  Future<void> save({
    required double motor1,
    required double motor2,
    required double motor3,
    required double motor4,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('${trainingKey}_m1', motor1);
    await prefs.setDouble('${trainingKey}_m2', motor2);
    await prefs.setDouble('${trainingKey}_m3', motor3);
    await prefs.setDouble('${trainingKey}_m4', motor4);
  }
}
