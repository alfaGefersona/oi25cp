import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class WifiSocketPage extends StatefulWidget {
  const WifiSocketPage({super.key});

  @override
  State<WifiSocketPage> createState() => _WifiSocketPageState();
}

class _WifiSocketPageState extends State<WifiSocketPage> {
  Socket? _socket;
  bool _connected = false;
  String _log = '';
  double _speed = 128; // velocidade inicial

  Future<void> _connect() async {
    try {
      _log += 'tentando conectar ao ESP32...\n';
      setState(() {});

      _socket = await Socket.connect('192.168.4.1', 8080,
          timeout: const Duration(seconds: 5));

      _socket!.listen((data) {
        final message = utf8.decode(data);
        setState(() {
          _log += 'ESP: $message\n';
        });
      }, onDone: () {
        setState(() {
          _connected = false;
          _log += 'Conexão encerrada\n';
        });
      }, onError: (e) {
        setState(() {
          _connected = false;
          _log += 'Erro no socket: $e\n';
        });
      });

      setState(() {
        _connected = true;
        _log += 'Conectado ao ESP32 (192.168.4.1:8080)\n';
      });
    } catch (e) {
      setState(() {
        _log += 'Falha ao conectar: $e\n';
      });
    }
  }

  void _sendCommand(String direction) {
    if (_socket == null || !_connected) {
      setState(() {
        _log += 'Não conectado ao ESP32\n';
      });
      return;
    }

    final command = jsonEncode({
      'motor': 1,
      'direction': direction,
      'speed': _speed.toInt(),
    });

    _socket!.write(command);
    setState(() {
      _log += 'Enviado: $command\n';
    });
  }

  void _disconnect() {
    _socket?.destroy();
    setState(() {
      _connected = false;
      _log += 'Desconectado manualmente\n';
    });
  }

  void _changeSpeed(double delta) {
    setState(() {
      _speed = (_speed + delta).clamp(0, 255);
    });
  }

  @override
  void dispose() {
    _socket?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Controle do Motor'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _connected ? 'Conectado ao ESP32' : 'Desconectado',
              style: TextStyle(
                color: _connected ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Controle de velocidade
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.blueGrey,
                  onPressed: _connected ? () => _changeSpeed(-1) : null,
                ),
                Expanded(
                  child: Slider(
                    value: _speed,
                    min: 0,
                    max: 255,
                    divisions: 255,
                    label: _speed.toInt().toString(),
                    onChanged: (value) {
                      setState(() => _speed = value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.blueGrey,
                  onPressed: _connected ? () => _changeSpeed(1) : null,
                ),
              ],
            ),
            Text(
              'Velocidade: ${_speed.toInt()} / 255',
              style: const TextStyle(fontFamily: 'monospace'),
            ),

            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed:
                  _connected ? () => _sendCommand('forward') : null,
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Frente'),
                ),
                ElevatedButton.icon(
                  onPressed:
                  _connected ? () => _sendCommand('backward') : null,
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Trás'),
                ),
                ElevatedButton.icon(
                  onPressed: _connected ? () => _sendCommand('stop') : null,
                  icon: const Icon(Icons.stop_circle_outlined),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  label: const Text('Parar'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _connected ? _disconnect : _connect,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                _connected ? Colors.redAccent : Colors.green,
              ),
              child: Text(_connected ? 'Desconectar' : 'Conectar'),
            ),
            const Divider(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _log,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
