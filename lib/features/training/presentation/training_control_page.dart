import 'package:flutter/material.dart';
import 'package:oi25cp/features/connection/service/esp_socket_service.dart';

class TrainingControlPage extends StatefulWidget {
  final String trainingKey;

  const TrainingControlPage({super.key, required this.trainingKey});

  @override
  State<TrainingControlPage> createState() => _TrainingControlPageState();
}

class _TrainingControlPageState extends State<TrainingControlPage> {
  double motor1 = 120;
  double motor2 = 180;
  double motor3 = 180;
  double motor4 = 150;

  bool trainingStarted = false;

  final esp = EspSocketService();

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      await esp.connect();
      print("Conectado ao ESP");
    } catch (e) {
      print("Erro: $e");
    }
  }

  Future<void> _startTraining() async {
    setState(() => trainingStarted = true);

    await esp.sendMotor(1, motor1.toInt());
    await Future.delayed(const Duration(milliseconds: 1000));

    await esp.sendMotor(2, motor2.toInt());
    await Future.delayed(const Duration(milliseconds: 1000));

    await esp.sendMotor(3, motor3.toInt());
    await Future.delayed(const Duration(milliseconds: 1000));

    await esp.sendMotor(4, motor4.toInt());
  }

  Future<void> _stopTraining() async {
    esp.stopAll();
    setState(() => trainingStarted = false);
  }

  Widget _buildMotorSlider(String label, double value, ValueChanged<double> onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toInt()}", style: const TextStyle(fontSize: 16)),
        Slider(
          value: value,
          min: 0,
          max: 255,
          divisions: 255,
          onChanged: onChange,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurar treino - ${widget.trainingKey}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMotorSlider("Motor A", motor1, (v) => setState(() => motor1 = v)),
            _buildMotorSlider("Motor B", motor2, (v) => setState(() => motor2 = v)),
            _buildMotorSlider("Motor C", motor3, (v) => setState(() => motor3 = v)),
            _buildMotorSlider("Motor D (Stepper)", motor4, (v) => setState(() => motor4 = v)),

            const SizedBox(height: 25),

            if (!trainingStarted)
              ElevatedButton(
                onPressed: _startTraining,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: const Text("INICIAR TREINO"),
              )
            else
              ElevatedButton(
                onPressed: _stopTraining,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: const Text(
                  "PARAR TREINO",
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
