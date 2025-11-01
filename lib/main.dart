// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final TextEditingController _controller = TextEditingController();

  // UI state
  String cityName = '';
  String description = '';
  String temp = '';
  String feelsLike = '';
  String humidity = '';
  String windSpeed = '';
  String iconCode = '';
  String weatherMain = '';
  bool isLoading = false;
  String errorMessage = '';

  // Replace with your OpenWeatherMap API key
  static const String _apiKey = '13d0b60cc2aed04d21d81507dd947651';

  // ---------------------
  // Permission & Location
  // ---------------------
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw ('Location services are disabled. Please enable them in device settings.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw ('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw ('Location permissions are permanently denied. Please enable them from app settings.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ---------------------
  // Fetch weather methods
  // ---------------------
  Future<void> fetchWeatherByCity(String city) async {
    if (city.trim().isEmpty) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(city.trim())}&appid=$_apiKey&units=metric',
    );

    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 12));
      final body = json.decode(resp.body);
      if (resp.statusCode == 200) {
        _applyWeatherData(body);
      } else {
        setState(() {
          errorMessage = body['message'] ?? 'City not found';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch weather. Check connection.';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchWeatherByLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final pos = await _determinePosition();
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&appid=$_apiKey&units=metric',
      );

      final resp = await http.get(url).timeout(const Duration(seconds: 12));
      final body = json.decode(resp.body);
      if (resp.statusCode == 200) {
        _applyWeatherData(body);
      } else {
        setState(() {
          errorMessage = body['message'] ?? 'Unable to fetch location weather';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------------------
  // Parse & apply response
  // ---------------------
  void _applyWeatherData(Map<String, dynamic> data) {
    // Defensive checks
    final weather =
        (data['weather'] as List<dynamic>?)?.firstWhere(
              (e) => e != null,
              orElse: () => null,
            )
            as Map<String, dynamic>?;

    setState(() {
      cityName = data['name'] ?? '';
      weatherMain = (weather?['main'] as String?) ?? '';
      description = (weather?['description'] as String?) ?? '';
      iconCode = (weather?['icon'] as String?) ?? '';
      final main = data['main'] as Map<String, dynamic>?;
      temp = main != null && main['temp'] != null
          ? (main['temp'].toString())
          : '';
      feelsLike = main != null && main['feels_like'] != null
          ? (main['feels_like'].toString())
          : '';
      humidity = main != null && main['humidity'] != null
          ? (main['humidity'].toString())
          : '';
      final wind = data['wind'] as Map<String, dynamic>?;
      windSpeed = wind != null && wind['speed'] != null
          ? wind['speed'].toString()
          : '';
      errorMessage = '';
    });
  }

  // ---------------------
  // Helpers: gradient & icon url
  // ---------------------
  LinearGradient _backgroundGradient(String main) {
    // choose gradient by main weather value (common ones)
    switch (main.toLowerCase()) {
      case 'clear':
        return const LinearGradient(
          colors: [Color(0xFFf6d365), Color(0xFFfda085)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'clouds':
        return const LinearGradient(
          colors: [Color(0xFF2b5876), Color(0xFF4e4376)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'rain':
      case 'drizzle':
        return const LinearGradient(
          colors: [Color(0xFF3a7bd5), Color(0xFF00d2ff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'thunderstorm':
        return const LinearGradient(
          colors: [Color(0xFF232526), Color(0xFF414345)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'snow':
        return const LinearGradient(
          colors: [Color(0xFF83a4d4), Color(0xFFb6fbff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'mist':
      case 'fog':
      case 'haze':
        return const LinearGradient(
          colors: [Color(0xFF606c88), Color(0xFF3f4c6b)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  String _iconUrl(String code) {
    if (code.isEmpty) return '';
    return 'https://openweathermap.org/img/wn/$code@4x.png'; // high-res icon
  }

  // ---------------------
  // UI
  // ---------------------
  @override
  Widget build(BuildContext context) {
    final gradient = _backgroundGradient(weatherMain);

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Weather Pro'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              children: [
                // Search bar + buttons
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter city (e.g. Delhi)',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _onSearch(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _onSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.35),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: fetchWeatherByLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.35),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.my_location, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Loading / Error states
                if (isLoading) ...[
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  const Text(
                    'Fetching weather...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ] else if (errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 40),
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (cityName.isEmpty) ...[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.cloud, size: 76, color: Colors.white24),
                          SizedBox(height: 12),
                          Text(
                            'Search for a city or use your location',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Weather card
                  Expanded(
                    child: Center(
                      child: Card(
                        color: Colors.white.withOpacity(0.12),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 28,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // top row: city + icon
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cityName,
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            weatherMain +
                                                (description.isNotEmpty
                                                    ? ' • $description'
                                                    : ''),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    if (iconCode.isNotEmpty)
                                      Image.network(
                                        _iconUrl(iconCode),
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.fill,
                                      )
                                    else
                                      const Icon(
                                        Icons.wb_sunny,
                                        size: 86,
                                        color: Colors.white24,
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // temperature & details
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      temp.isNotEmpty ? '${temp}°C' : '--',
                                      style: const TextStyle(
                                        fontSize: 46,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (feelsLike.isNotEmpty)
                                            Text(
                                              'Feels like ${feelsLike}°C',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          if (humidity.isNotEmpty)
                                            Text(
                                              'Humidity: ${humidity}%',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          if (windSpeed.isNotEmpty)
                                            Text(
                                              'Wind: ${windSpeed} m/s',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                ElevatedButton.icon(
                                  onPressed: () => fetchWeatherByCity(cityName),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Refresh'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white10,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // handler for search button or Enter
  void _onSearch() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a city name';
      });
      return;
    }
    FocusScope.of(context).unfocus();
    fetchWeatherByCity(text);
  }
}
