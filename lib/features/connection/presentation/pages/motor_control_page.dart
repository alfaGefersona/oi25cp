import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MotorControlPage extends StatefulWidget {
  const MotorControlPage({super.key});

  @override
  State<MotorControlPage> createState() => _MotorControlPageState();
}

class _MotorControlPageState extends State<MotorControlPage> {
  WebSocketChannel? channel;
  bool connected = false;
  double speed = 0;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.4.1/ws'),
      );
      channel!.stream.listen(
            (message) {
          print('📩 ESP32 -> $message');
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('ESP32: $message')));
          }
        },
        onDone: () {
          print('🔌 Conexão encerrada');
          setState(() => connected = false);
        },
        onError: (error) {
          print('❌ Erro: $error');
          setState(() => connected = false);
        },
      );
      setState(() => connected = true);
    } catch (e) {
      print('❌ Falha ao conectar: $e');
      setState(() => connected = false);
    }
  }

  void _sendCommand(String direction) {
    if (channel != null && connected) {
      final command = {
        'motor': 1,
        'direction': direction,
        'speed': speed.toInt(),
      };
      channel!.sink.add(command.toString());
      print('➡️ Enviado: $command');
    } else {
      print('⚠️ Não conectado ao ESP32');
    }
  }

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text('Controle de Motores ⚙️'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Padding(
        padding: const EdgeInsets.all(16),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    connected ? '✅ Conectado ao ESP32' : '❌ Desconectado',
    style: TextStyle(
    color: connected ? Colors.green : Colors.red,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 20),
    Slider(
