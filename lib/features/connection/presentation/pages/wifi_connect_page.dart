import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiConnectPage extends StatefulWidget {
  const WifiConnectPage({super.key});

  @override
  State<WifiConnectPage> createState() => _WifiConnectPageState();
}

class _WifiConnectPageState extends State<WifiConnectPage> {
  String _status = "Aguardando ação...";
  bool _isConnecting = false;
  bool _connected = false;

  static const String _ssid = "Robot";
  static const String _password = "12345678";

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permissions = [
      Permission.location,
      Permission.nearbyWifiDevices,
    ];

    Map<Permission, PermissionStatus> results = await permissions.request();

    if (results[Permission.location]!.isGranted) {
      setState(() => _status = " Permissões concedidas");
    } else {
      setState(() => _status = "️ Permissões negadas");
    }
  }

  Future<void> _connectToWifi() async {
    setState(() {
      _isConnecting = true;
      _status = "Conectando a $_ssid...";
    });

    try {
      bool? wifiEnabled = await WiFiForIoTPlugin.isEnabled();
      if (wifiEnabled == false) {
        await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: false);
        await Future.delayed(const Duration(seconds: 2));
      }

      bool connected = await WiFiForIoTPlugin.connect(
        _ssid,
        password: _password,
        security: NetworkSecurity.WPA,
        joinOnce: true,
      );

      if (connected) {
        setState(() {
          _connected = true;
          _status = "Conectado à rede $_ssid";
        });
      } else {
        setState(() {
          _connected = false;
          _status = "Falha ao conectar";
        });
      }
    } catch (e) {
      setState(() => _status = "Erro: $e");
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  /// Desconecta da rede
  Future<void> _disconnectWifi() async {
    await WiFiForIoTPlugin.disconnect();
    setState(() {
      _connected = false;
      _status = "Desconectado da rede Wi-Fi";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conectar ao Robô'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 30),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 30),
            if (_isConnecting)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(_connected ? Icons.wifi_off : Icons.wifi),
                    label: Text(_connected ? "Desconectar" : "Conectar ao robô"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      _connected ? Colors.red : Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed:
                    _connected ? _disconnectWifi : _connectToWifi,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.shield),
                    label: const Text("Verificar permissões"),
                    onPressed: _checkPermissions,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
