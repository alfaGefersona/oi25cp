import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WifiSocketPage extends StatefulWidget {
  const WifiSocketPage({super.key});

  @override
  State<WifiSocketPage> createState() => _WifiSocketPageState();
}

class _WifiSocketPageState extends State<WifiSocketPage> {
  late IO.Socket socket;
  final controller = TextEditingController();
  final List<String> messages = [];
  bool connected = false;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    socket = IO.io(
      'http://192.168.0.10:3000', // 👉 coloque o IP do servidor na mesma rede Wi-Fi
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      setState(() => connected = true);
      print('✅ Conectado ao servidor');
    });

    socket.onDisconnect((_) {
      setState(() => connected = false);
      print('🔴 Desconectado');
    });

    socket.on('mensagem', (data) {
      setState(() => messages.add("📩 $data"));
    });

    socket.connect();
  }

  void _enviarMensagem() {
    if (controller.text.trim().isEmpty) return;
    socket.emit('mensagem', controller.text);
    setState(() => messages.add("📤 ${controller.text}"));
    controller.clear();
  }

  @override
  void dispose() {
    socket.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Socket.IO via Wi-Fi')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: connected ? Colors.green[100] : Colors.red[100],
            child: Row(
              children: [
                Icon(connected ? Icons.wifi : Icons.wifi_off, color: connected ? Colors.green : Colors.red),
                const SizedBox(width: 10),
                Text(connected ? 'Conectado ao servidor' : 'Desconectado'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(messages[i]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Digite uma mensagem...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _enviarMensagem,
                  icon: const Icon(Icons.send),
                  label: const Text("Enviar"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
