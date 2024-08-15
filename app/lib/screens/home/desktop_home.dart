import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  _DesktopHomeScreenState createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  Future<String>? _weatherData;
  Future<String> _motivationalQuote =
      Future.value('Carregando...');

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchMotivationalQuote();
  }

  Future<void> _requestLocationPermission() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _weatherData = Future.value('Location services are disabled.');
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _weatherData = Future.value('Location permission denied');
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _weatherData = Future.value('Location permission denied forever');
        });
        return;
      }

      _getLocation();
    } catch (e) {
      setState(() {
        _weatherData = Future.value('Error: $e');
      });
      if (kDebugMode) {
        print('Error requesting location permission: $e');
      }
    }
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _getCityNameFromLocation(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _weatherData = Future.value('Error: $e');
      });
      if (kDebugMode) {
        print('Error getting location: $e');
      }
    }
  }

  Future<void> _getCityNameFromLocation(
      double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (kDebugMode) {
          print('Geolocation JSON: $jsonData');
        }
        String cityName;
        if (jsonData['address']['city'] != null) {
          cityName = jsonData['address']['city'];
        } else if (jsonData['address']['town'] != null) {
          cityName = jsonData['address']['town'];
        } else if (jsonData['address']['village'] != null) {
          cityName = jsonData['address']['village'];
        } else {
          cityName = 'Unknown';
        }

        cityName = cityName.trim();
        if (kDebugMode) {
          print('City name before fetching weather data: $cityName');
        }

        setState(() {
          _weatherData = _getWeatherData(latitude, longitude);
        });
      } else {
        setState(() {
          _weatherData = Future.value('Error: ${response.statusCode}');
        });
        if (kDebugMode) {
          print('Error getting city name: ${response.statusCode}');
        }
      }
    } catch (e) {
      setState(() {
        _weatherData = Future.value('Error: $e');
      });
      if (kDebugMode) {
        print('Error getting city name from location: $e');
      }
    }
  }

  Future<String> _getWeatherData(double latitude, double longitude) async {
    try {
      String apiUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&timezone=auto';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData != null && jsonData['current_weather'] != null) {
          final weatherData = jsonData['current_weather'];
          final temperature = (weatherData['temperature'] ?? 0).toInt();
          return '$temperature°C';
        } else {
          return 'Error: No weather data found';
        }
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      if (e is HttpException) {
        return 'Error: ${e.message}';
      } else {
        return 'Error: $e';
      }
    }
  }

  Future<void> _fetchMotivationalQuote() async {
    try {
      final response = await http.get(Uri.parse(
          'https://testefunctionsbeto.azurewebsites.net/api/frases-api'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final String quoteText = jsonData['texto'];
        final String quoteAuthor = jsonData['autor'];

        setState(() {
          _motivationalQuote = Future.value('$quoteText\n- $quoteAuthor');
        });
      } else {
        setState(() {
          _motivationalQuote =
              Future.value('Erro ao carregar a frase motivacional');
        });
      }
    } catch (e) {
      setState(() {
        _motivationalQuote = Future.value('Erro: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 40),
                _buildWelcomeSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFooter(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_people_outlined, size: 40),
            const SizedBox(width: 10),
            Text(
              'Bem vindo',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        FutureBuilder<String>(
          future: _weatherData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator.adaptive();
            } else if (snapshot.hasError) {
              return const Text('Erro ao carregar o clima');
            } else if (snapshot.hasData) {
              return Row(
                children: [
                  const Icon(Icons.wb_sunny, color: Colors.orange, size: 30),
                  const SizedBox(width: 8),
                  Text(
                    snapshot.data!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Center(
      child: FutureBuilder<String>(
        future: _motivationalQuote,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator.adaptive();
          } else if (snapshot.hasError) {
            return const Text('Erro ao carregar a frase motivacional');
          } else if (snapshot.hasData) {
            return Text(
              snapshot.data!,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.blueGrey.shade900,
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Text(
          '© ${DateTime.now().year} Hendril Mendes - Todos os direitos reservados',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
