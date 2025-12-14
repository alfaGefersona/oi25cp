import 'package:shared_preferences/shared_preferences.dart';

class TrainingStorage {
  final String trainingKey;

  TrainingStorage(this.trainingKey);

  /* ============================
     LOAD
     ============================ */
  Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      // Motores
      'motor1': prefs.getDouble('${trainingKey}_m1') ?? 120,
      'motor2': prefs.getDouble('${trainingKey}_m2') ?? 180,
      'motor3': prefs.getDouble('${trainingKey}_m3') ?? 180,
      'motor4': prefs.getDouble('${trainingKey}_m4') ?? 1,

      // Feeder
      'feederMode':
      prefs.getInt('${trainingKey}_feeder_mode') ?? 0, // enum index
      'feederIntervalSeconds':
      prefs.getDouble('${trainingKey}_feeder_interval') ?? 1,
    };
  }

  /* ============================
     SAVE
     ============================ */
  Future<void> save({
    required double motor1,
    required double motor2,
    required double motor3,
    required double motor4,
    required int feederModeIndex,
    required double feederIntervalSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('${trainingKey}_m1', motor1);
    await prefs.setDouble('${trainingKey}_m2', motor2);
    await prefs.setDouble('${trainingKey}_m3', motor3);
    await prefs.setDouble('${trainingKey}_m4', motor4);

    await prefs.setInt(
      '${trainingKey}_feeder_mode',
      feederModeIndex,
    );

    await prefs.setDouble(
      '${trainingKey}_feeder_interval',
      feederIntervalSeconds,
    );
  }
}
