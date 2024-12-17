import 'package:dashboard/screens/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MachineScreen extends StatefulWidget {
  const MachineScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MachineScreenState createState() => _MachineScreenState();
}

class _MachineScreenState extends State<MachineScreen> {
  TextEditingController ipController = TextEditingController();
  bool isServer = false;

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  _checkFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstRun = prefs.getBool('isFirstRun');
    if (isFirstRun == null || isFirstRun) {
      _showServerClientDialog();
      await prefs.setBool('isFirstRun', false);
    } else {
      _navigateToDashboard();
    }
  }

  _showServerClientDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Configuração Inicial',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text(
                    'O dispositivo será configurado como servidor ou cliente?'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          isServer = true;
                        });
                        Navigator.pop(context);
                        _saveServerConfig();
                      },
                      child: const Text('Servidor',
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          isServer = false;
                        });
                        Navigator.pop(context);
                        Future.delayed(const Duration(milliseconds: 300), () {
                          _showIpInput();
                        });
                      },
                      child: const Text('Cliente',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _saveServerConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isServer) {
      await prefs.setString('apiUrl', 'http://127.0.0.1:3000');
      _showRestartDialog();
    } else {
      _showIpInput();
    }
  }

  _showIpInput() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Informe o IP do Servidor',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: ipController,
                  decoration: InputDecoration(
                    labelText: 'IP do servidor',
                    prefixIcon: const Icon(Icons.network_check),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    String ip = ipController.text.trim();
                    if (ip.isNotEmpty) {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString('apiUrl', 'http://$ip:3000');
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      _showRestartDialog();
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _showRestartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reinicie o Sistema'),
          content: const Text(
              'As configurações foram aplicadas. Por favor, reinicie o sistema para que as alterações entrem em vigor.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToDashboard();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Dispositivo'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
