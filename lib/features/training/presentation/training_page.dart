import 'package:flutter/material.dart';
import 'ping_pong_scene_page.dart';

class TrainingPage extends StatelessWidget {
  final trainings = const [
    {"title": "Topspin", "level": 1, "color": Colors.orange},
    {"title": "Backspin", "level": 2, "color": Colors.yellow},
    {"title": "Recepção de saque", "level": 3, "color": Colors.lightBlue},
    {"title": "Batida", "level": 1, "color": Colors.red},
    {"title": "Movimentação", "level": 0, "color": Colors.blue},
  ];

  const TrainingPage({super.key});

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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PingPongScenePage(),
                ),
              );
            },
            child: Card(
              color: t["color"] as Color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t["title"] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
