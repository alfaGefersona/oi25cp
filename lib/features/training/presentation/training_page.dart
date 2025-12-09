import 'package:flutter/material.dart';
import 'package:oi25cp/features/connection/service/esp_socket_service.dart';
import 'training_control_page.dart';

class TrainingPage extends StatelessWidget {
  final trainings = const [
    {"title": "Topspin", "key": "topspin", "level": 1, "color": Colors.orange},
    {"title": "Backspin", "key": "backspin", "level": 2, "color": Colors.yellow},
    {"title": "Recepção de saque", "key": "recepcao", "level": 3, "color": Colors.lightBlue},
    {"title": "Batida", "key": "batida", "level": 1, "color": Colors.red},
    {"title": "Movimentação", "key": "mov", "level": 0, "color": Colors.blue},
  ];

  const TrainingPage({super.key});

  Map<String, Map<String, int>> get trainingConfig => {
    "topspin": {"A": 120, "B": 180, "C": 180},
    "backspin": {"A": 140, "B": 160, "C": 200},
    "recepcao": {"A": 100, "B": 200, "C": 200},
    "batida": {"A": 255, "B": 255, "C": 180},
    "mov": {"A": 150, "B": 150, "C": 150},
  };

  Future<void> _startTraining(BuildContext context, String key) async {
    final esp = EspSocketService();

    try {
      await esp.connect();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao conectar ao ESP: $e")),
      );
      return;
    }

    final cfg = trainingConfig[key]!;

    // IMPORTANTE: manda um por vez com delay
    esp.sendMotor(1, cfg["A"]!);
    await Future.delayed(const Duration(milliseconds: 120));

    esp.sendMotor(2, cfg["B"]!);
    await Future.delayed(const Duration(milliseconds: 120));

    esp.sendMotor(3, cfg["C"]!);

    _openTrainingModal(context, key);
  }

  void _openTrainingModal(BuildContext context, String key) {
    final esp = EspSocketService();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Treino: $key",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 55),
                ),
                onPressed: () {
                  esp.stopAll();
                  Navigator.pop(context);
                },
                child: const Text(
                  "PARAR TREINO",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trainings')),
      body: ListView.builder(
        itemCount: trainings.length,
        itemBuilder: (context, i) {
          final t = trainings[i];

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            // onTap: () => _startTraining(context, t["key"] as String),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrainingControlPage(trainingKey: t["key"] as String),
                ),
              );
            },

            child: Card(
              color: t["color"] as Color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t["title"] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Nível", style: TextStyle(color: Colors.white)),
                    Row(
                      children: List.generate(
                        4,
                            (i2) => Container(
                          margin: const EdgeInsets.only(right: 6, top: 5),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: i2 < (t["level"] as int)
                                ? Colors.white
                                : Colors.transparent,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
