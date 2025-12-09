import 'dart:io';
import 'dart:convert';

class EspSocketService {
  static final EspSocketService _instance = EspSocketService._internal();
  factory EspSocketService() => _instance;
  EspSocketService._internal();

  Socket? _socket;
  bool get isConnected => _socket != null;

  Future<void> connect() async {
    if (_socket != null) {
      try {
        _socket!.destroy();
      } catch (_) {}
      _socket = null;
    }

    _socket = await Socket.connect("192.168.4.1", 8080);
    _socket!.listen(
          (data) {
        final msg = utf8.decode(data);
        print('[ESP] $msg');
      },
      onDone: () {
        print('[ESP] conexão encerrada');
        _socket = null;
      },
      onError: (e) {
        print('[ESP] erro no socket: $e');
        _socket = null;
      },
    );
  }

  Future<void>  sendMotor(int motor, int speed) async{
    if (_socket == null) {
      print('[ESP] sendMotor chamado sem conexão');
      return;
    }

    final cmd = jsonEncode({
      "motor": motor,
      "direction": "forward",
      "speed": speed,
    });

    print('[ESP] >> $cmd');
    _socket!.write('$cmd\n');
    await _socket!.flush();
  }

  void stopAll() {
    if (_socket == null) {
      print('[ESP] stopAll chamado sem conexão');
      return;
    }

    final cmd = jsonEncode({
      "motor": 0,
      "direction": "stop_all",
      "speed": 0,
    });

    print('[ESP] >> $cmd');
    _socket!.write('$cmd\n');
  }
}
