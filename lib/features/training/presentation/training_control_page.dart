import 'package:flutter/material.dart';
import 'package:oi25cp/features/connection/service/esp_socket_service.dart';
import 'package:oi25cp/features/training/data/training_storage.dart';

enum FeederMode {
  bolinhasPorSegundo,
  umaBolinhaPorIntervalo,
}

class TrainingControlPage extends StatefulWidget {
  final String trainingKey;

  const TrainingControlPage({super.key, required this.trainingKey});

  @override
  State<TrainingControlPage> createState() => _TrainingControlPageState();
}

class _TrainingControlPageState extends State<TrainingControlPage>
    with SingleTickerProviderStateMixin {
  double motor1 = 0;
  double motor2 = 0;
  double motor3 = 0;
  double motor4 = 1;

  double feederIntervalSeconds = 1;
  FeederMode feederMode = FeederMode.bolinhasPorSegundo;

  bool editing = false;
  bool trainingStarted = false;
  bool launchersOn = false;
  bool feederOn = false;

  late AnimationController pulse;

  final EspSocketService esp = EspSocketService();
  late TrainingStorage storage;

  @override
  void initState() {
    super.initState();
    storage = TrainingStorage(widget.trainingKey);

    pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _connect();
    _load();
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    await esp.connect();
  }

  Future<void> _load() async {
    final data = await storage.load();

    setState(() {
      motor1 = (data['motor1'] as double);
      motor2 = (data['motor2'] as double);
      motor3 = (data['motor3'] as double);
      motor4 = (data['motor4'] as double).clamp(0, 8);
      feederMode = FeederMode.values[
      data['feederMode'] as int
      ];
      feederIntervalSeconds =
      (data['feederIntervalSeconds'] as double);
    });
  }

  Future<void> _save() async {
    await storage.save(
      motor1: motor1,
      motor2: motor2,
      motor3: motor3,
      motor4: motor4,
      feederModeIndex: feederMode.index,
      feederIntervalSeconds: feederIntervalSeconds,
    );
  }


  Future<void> _startTraining() async {
    setState(() => trainingStarted = true);
    pulse.repeat(reverse: true);

    esp.sendMotor(1, motor1.toInt());
    esp.sendMotor(2, motor2.toInt());

    esp.sendMotor(3, motor3.toInt());

    _startFeeder();

    setState(() {
      launchersOn = true;
      feederOn = true;
    });
  }

  Future<void> _stopTraining() async {
    esp.stopAll();
    pulse.stop();

    setState(() {
      trainingStarted = false;
      launchersOn = false;
      feederOn = false;
    });
  }

  Future<void> _startFeeder() async {
    if (feederMode == FeederMode.bolinhasPorSegundo) {
     esp.sendFeederBolinhas(motor4.toInt());
    } else {
      esp.sendFeederIntervalo(
        (feederIntervalSeconds * 1000).toInt(),
      );
    }
  }

  Future<void> _toggleLaunchers() async {
    if (launchersOn) {
      esp.sendMotor(1, 0);
      esp.sendMotor(2, 0);
      esp.sendMotor(3, 0);
    } else {
      esp.sendMotor(1, motor1.toInt());
      esp.sendMotor(2, motor2.toInt());
      esp.sendMotor(3, motor3.toInt());
    }

    setState(() => launchersOn = !launchersOn);
  }


  Future<void> _toggleFeeder() async {
    if (feederOn) {
      esp.sendMotor(4, 0);
    } else {
      await _startFeeder();
    }

    setState(() => feederOn = !feederOn);
  }

  Widget slider(String label, double value, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toInt()}"),
        Slider(
          value: value,
          min: 0,
          max: max,
          divisions: max.toInt(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Treino ${widget.trainingKey}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => editing = true),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: editing
            ? Column(
          children: [
            slider("Motor A", motor1, 255, (v) => setState(() => motor1 = v)),
            slider("Motor B", motor2, 255, (v) => setState(() => motor2 = v)),
            slider("Motor C", motor3, 255, (v) => setState(() => motor3 = v)),
            ToggleButtons(
              isSelected: [
                feederMode == FeederMode.bolinhasPorSegundo,
                feederMode == FeederMode.umaBolinhaPorIntervalo,
              ],
              onPressed: (i) {
                setState(() {
                  feederMode = FeederMode.values[i];
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Bolinhas/s"),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("1 bolinha / X s"),
                ),
              ],
            ),
            feederMode == FeederMode.bolinhasPorSegundo
                ? slider("Alimentador", motor4, 8, (v) => setState(() => motor4 = v))
                : slider("Intervalo (s)", feederIntervalSeconds, 10,
                    (v) => setState(() => feederIntervalSeconds = v)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _save();
                      setState(() => editing = false);
                    },
                    child: const Text("SALVAR"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _load();
                      setState(() => editing = false);
                    },
                    child: const Text("CANCELAR"),
                  ),
                ),
              ],
            ),
          ],
        )
            : Column(
          children: [
            ScaleTransition(
              scale: trainingStarted
                  ? Tween(begin: 1.0, end: 1.05).animate(pulse)
                  : const AlwaysStoppedAnimation(1),
              child: Card(
                child: ListTile(
                  title: Text(
                    trainingStarted ? "TREINO EM ANDAMENTO" : "TREINO PARADO",
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: trainingStarted ? _stopTraining : _startTraining,
              child: Text(trainingStarted ? "PARAR TREINO" : "INICIAR TREINO"),
            ),
            ElevatedButton(
              onPressed: _toggleLaunchers,
              child: Text(launchersOn ? "DESLIGAR LANÇADORES" : "LIGAR LANÇADORES"),
            ),
            ElevatedButton(
              onPressed: _toggleFeeder,
              child: Text(feederOn ? "DESLIGAR ALIMENTADOR" : "LIGAR ALIMENTADOR"),
            ),
          ],
        ),
      ),
    );
  }
}
