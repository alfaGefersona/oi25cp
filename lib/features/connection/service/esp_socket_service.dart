import 'dart:io';
import 'dart:convert';

class EspSocketService {
  static final EspSocketService _instance = EspSocketService._internal();
  factory EspSocketService() => _instance;
  EspSocketService._internal();

  Socket? _socket;

  Future<void> connect() async {
    _socket?.destroy();
    _socket = await Socket.connect("192.168.4.1", 8080);
  }

  void _send(Map<String, dynamic> cmd) {
    if (_socket == null) return;
    _socket!.write('${jsonEncode(cmd)}\n');
  }

  // Motores DC
  void sendMotor(int motor, int speed) {
    _send({
      "motor": motor,
      "direction": speed > 0 ? "forward" : "stop",
      "speed": speed,
    });
  }

  // Alimentador - bolinhas por segundo
  void sendFeederBolinhas(int bolinhas) {
    _send({
      "motor": 4,
      "direction": bolinhas > 0 ? "forward" : "stop",
      "bolinhas": bolinhas,
    });
  }

  // Alimentador - 1 bolinha a cada X ms
  void sendFeederIntervalo(int intervaloMs) {
    _send({
      "motor": 4,
      "direction": intervaloMs > 0 ? "forward" : "stop",
      "intervalo_ms": intervaloMs,
    });
  }

  void stopAll() {
    _send({
      "motor": 0,
      "direction": "stop_all",
    });
  }
}
