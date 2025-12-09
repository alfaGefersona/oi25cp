import 'package:flutter/material.dart';
import 'package:oi25cp/features/connection/service/esp_socket_service.dart';
import 'package:oi25cp/features/training/data/training_storage.dart';

class TrainingControlPage extends StatefulWidget {
  final String trainingKey;

  const TrainingControlPage({super.key, required this.trainingKey});

  @override
  State<TrainingControlPage> createState() => _TrainingControlPageState();
}

class _TrainingControlPageState extends State<TrainingControlPage> {
  double motor1 = 0;
  double motor2 = 0;
  double motor3 = 0;
  double motor4 = 0;

  bool trainingStarted = false;
  bool editing = false;

  final esp = EspSocketService();

  late TrainingStorage storage;

  @override
  void initState() {
    super.initState();
    storage = TrainingStorage(widget.trainingKey);
    _connect();
    _load();
  }

  Future<void> _connect() async {
    try {
      await esp.connect();
      print("Conectado ao ESP");
    } catch (e) {
      print("Erro: $e");
    }
  }

  Future<void> _load() async {
    final data = await storage.load();

    setState(() {
      motor1 = data['motor1']!;
      motor2 = data['motor2']!;
      motor3 = data['motor3']!;
      motor4 = data['motor4']!;
    });
  }

  Future<void> _save() async {
    await storage.save(
      motor1: motor1,
      motor2: motor2,
      motor3: motor3,
      motor4: motor4,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treino salvo com sucesso!')),
    );
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
          onChanged: editing ? onChange : null,
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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "editar") {
                setState(() => editing = true);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "editar",
                child: Text("Habilitar edição"),
              ),
            ],
          ),
        ],
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

            if (!editing) ...[
              if (!trainingStarted)
                ElevatedButton(
                  onPressed: _startTraining,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                  child: const Text("INICIAR TREINO"),
                )
              else
                ElevatedButton(
                  onPressed: _stopTraining,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("PARAR TREINO", style: TextStyle(color: Colors.white)),
                ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _save();
                        setState(() => editing = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 55),
                      ),
                      child: const Text("SALVAR", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => editing = false);
                        _load(); // restaura valores do storage
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        minimumSize: const Size(double.infinity, 55),
                      ),
                      child: const Text("CANCELAR", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
