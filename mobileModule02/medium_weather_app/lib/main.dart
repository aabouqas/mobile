import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;
  Position? _currentPosition;
  List _suggestions = [];
  final TextEditingController _textEditingController = TextEditingController();

  Map<IconData, String> tabs = {
    Icons.settings_rounded: "Currently",
    Icons.today_rounded: "Today",
    Icons.calendar_month_rounded: "Weekly",
  };

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    debugPrint("Fetching location...");
    setLoading(true);
    _currentPosition = null;
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      setLoading(false);
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == .deniedForever) {
      setLoading(false);
      return;
    }

    if (permission == .denied) {
      permission = await Geolocator.requestPermission();
      if (permission == .denied || permission == .deniedForever) {
        setLoading(false);
        return;
      }
    }
    try {
      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      debugPrint("Location: $pos");
      _currentPosition = pos;
    } catch (e) {
      debugPrint("Location error: $e");
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool isLoading) => setState(() => _isLoading = isLoading);

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              icon: const Icon(Icons.search),
              border: .none,
              focusedBorder: .none,
              hint: const Text(
                'Search location...',
                maxLines: 1,
                style: TextStyle(color: Colors.grey),
              ),
              suffixIcon: _textEditingController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _textEditingController.clear();
                        setState(() => _suggestions = []);
                      },
                    )
                  : null,
            ),
            onChanged: (txt) => _searchCities(txt),
            onSubmitted: (text) async {
              if (_suggestions.isNotEmpty) {
                Map<String, dynamic> toSearch = _suggestions.first;
                setState(() => _suggestions = []);
                _fetchCityWeather(toSearch);
                _removeFocus();
              }
            },
            textInputAction: .go,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.gps_fixed),
              onPressed: () {
                _textEditingController.clear();
                _fetchCurrentLocation();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            TabBarView(
              children: tabs.entries
                  .map(
                    (entry) => Center(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Text(
                              _currentPosition != null
                                  ? '${entry.value}\n${_currentPosition!.latitude},${_currentPosition!.longitude}'
                                        .trim()
                                  : "Geolocation is not enabled, please enable it in your App settings.",
                              textAlign: .center,
                              style: TextStyle(
                                fontSize: 30,
                                color: _currentPosition != null
                                    ? Colors.black
                                    : Colors.red,

                                fontWeight: .bold,
                              ),
                            ),
                    ),
                  )
                  .toList(),
            ),
            if (_suggestions.isNotEmpty)
              Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${_suggestions[index]["name"]} ',
                            style: const TextStyle(fontWeight: .bold),
                          ),
                          if (_suggestions[index]["admin1"] != null &&
                              _suggestions[index]["admin1"]
                                  .toString()
                                  .isNotEmpty)
                            TextSpan(
                              text: "${_suggestions[index]["admin1"]}, ",
                            ),
                          TextSpan(text: "${_suggestions[index]["country"]}"),
                        ],
                      ),
                    ),
                    onTap: () {
                      debugPrint("Selected => ${_suggestions[index]['name']}");
                      _removeFocus();
                      _fetchCityWeather(_suggestions[index]);
                      setState(() => _suggestions = []);
                    },
                  ),
                  itemCount: _suggestions.length,
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: .zero,
          child: TabBar(
            tabs: tabs.entries
                .map((entry) => Tab(icon: Icon(entry.key), text: entry.value))
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _searchCities(String query) async {
    if (query.trim().length < 2 || query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query)}&count=5&language=en&format=json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _suggestions = data['results'] ?? [];
        });
      }
    } catch (e) {}
  }

  Future<void> _fetchCityWeather(Map<dynamic, dynamic> city) async {
    final url = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '${city['latitude']}',
      'longitude': '${city['longitude']}',
      'current': 'temperature_2m,weather_code,wind_speed_10m',
      'hourly': 'temperature_2m,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'timezone': 'auto',
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      debugPrint('Weather data: ${response.body}');
    }
  }

  void _removeFocus() => FocusScope.of(context).unfocus();
}
