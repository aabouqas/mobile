import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

enum TabType {
  currently,
  today,
  weekly;

  String stringValue() {
    switch (this) {
      case TabType.currently:
        return "Currently";
      case TabType.today:
        return "Today";
      case TabType.weekly:
        return "Weekly";
    }
  }

  IconData getIcon() {
    switch (this) {
      case TabType.currently:
        return Icons.sunny;
      case TabType.today:
        return Icons.today_rounded;
      case TabType.weekly:
        return Icons.calendar_month_rounded;
    }
  }
}

enum ErrorType {
  location,
  weather,
  search;

  String message() {
    switch (this) {
      case ErrorType.location:
        return "Geolocation is not available, please enable it in your App settings.";
      case ErrorType.weather:
        return "The service connection is lost, please check your internet or try again later.";
      case ErrorType.search:
        return "Could not find any result for this supplied address or coordinates.";
    }
  }
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
  List _suggestions = [];
  Map<String, dynamic> _currentWeather = {};
  ErrorType? _errType;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    debugPrint("Fetching location...");
    setLoading(true);
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      setErrorType(.location);
      setLoading(false);
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == .deniedForever) {
      setLoading(false);
      setErrorType(.location);
      return;
    }

    if (permission == .denied) {
      permission = await Geolocator.requestPermission();
      if (permission == .denied || permission == .deniedForever) {
        setLoading(false);
        setErrorType(.location);
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
      final url = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${pos.latitude}&longitude=${pos.longitude}&localityLanguage=en',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> city = {
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'name': data['locality'],
          'admin1': data['principalSubdivision'],
          'country': data['countryName'],
        };
        setErrorType(null);
        await _fetchCityWeather(city);
      }
    } catch (e) {
      setErrorType(.weather);
      debugPrint("Location error: $e");
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool isLoading) => setState(() => _isLoading = isLoading);
  void setErrorType(ErrorType? errType) => setState(() => _errType = errType);

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
          title: Container(
            alignment: .center,
            padding: const .symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: TextField(
              textAlignVertical: .center,
              controller: _textEditingController,
              decoration: InputDecoration(
                icon: const Icon(Icons.search),
                border: .none,
                focusedBorder: .none,
                hint: const Text(
                  'Search location...',
                  maxLines: 1,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                suffixIcon: _textEditingController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _textEditingController.clear();
                          _removeFocus();
                          _fetchCurrentLocation();
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
                  await _fetchCityWeather(toSearch);
                }
                _removeFocus();
              },
              textInputAction: .go,
            ),
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
              children: TabType.values
                  .map(
                    (tab) => Center(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildCurrentTab(tab),
                    ),
                  )
                  .toList(),
            ),
            if (_suggestions.isNotEmpty)
              Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.location_city),
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
            tabs: TabType.values
                .map(
                  (tab) =>
                      Tab(icon: Icon(tab.getIcon()), text: tab.stringValue()),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _searchCities(String query) async {
    if (query.trim().length < 2 || query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _errType = null;
      });
      return;
    }
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query)}&count=5&language=en&format=json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log(" data['results'] => ${data['results']}");

        setState(() {
          if (data['results'] == null) {
            _errType = ErrorType.search;
            _suggestions = [];
          } else {
            _suggestions = data['results'] ?? [];
            _errType = null;
          }
        });
      }
    } catch (_) {
      setErrorType(.weather);
    }
  }

  Widget _buildCurrentTab(TabType tab) {
    if (_errType != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _errType!.message(),
            textAlign: .center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    if (_currentWeather.isEmpty) {
      return const SizedBox.shrink();
    }
    if (tab == .currently) {
      return Column(
        children: [
          Text(_currentWeather['name']),
          Text(_currentWeather['admin1']),
          Text(_currentWeather['country']),
          Text('${_currentWeather['current']?['temperature_2m']}°C'),
          Text(
            _getWetherDescription(_currentWeather['current']?['weather_code']),
          ),
          Text('${_currentWeather['current']?['wind_speed_10m']} km/h'),
        ],
      );
    }
    if (tab == .today) {
      return SingleChildScrollView(
        child: Column(
          spacing: 8,
          children: [
            Text(_currentWeather['name']),
            Text(_currentWeather['admin1']),
            Text(_currentWeather['country']),
            for (int n = 0; n < 24 && _currentWeather['hourly'] != null; n++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      _currentWeather['hourly']['time'][n].toString().split(
                        'T',
                      )[1],
                    ),
                    // _getWetherDescription
                    Text('${_currentWeather['hourly']['temperature_2m'][n]}°C'),
                    Text(
                      '${_currentWeather['hourly']['wind_speed_10m'][n]}km/h',
                    ),
                    Text(
                      _getWetherDescription(
                        _currentWeather['hourly']['weather_code'][n],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }
    if (tab == .weekly) {
      return SingleChildScrollView(
        child: Column(
          spacing: 8,
          children: [
            Text(_currentWeather['name']),
            Text(_currentWeather['admin1']),
            Text(_currentWeather['country']),
            for (int n = 0; n < 7 && _currentWeather['daily'] != null; n++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(_currentWeather['daily']['time'][n].toString()),
                    // _getWetherDescription
                    Text(
                      '${_currentWeather['daily']['temperature_2m_min'][n]}°C',
                    ),
                    Text(
                      '${_currentWeather['daily']['temperature_2m_max'][n]}°C',
                    ),
                    Text(
                      _getWetherDescription(
                        _currentWeather['daily']['weather_code'][n],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
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

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        debugPrint('Weather data: ${response.body}');
        setState(() {
          _currentWeather = {
            ...jsonDecode(response.body),
            'name': city['name'],
            'admin1': city['admin1'] ?? "",
            'country': city['country'],
          };
          _errType = null;
          debugPrint('Weather data: $_currentWeather');
        });
      }
    } catch (e) {
      setErrorType(.weather);
    }
  }

  void _removeFocus() => FocusScope.of(context).unfocus();

  String _getWetherDescription(int? code) {
    switch (code) {
      case 0:
        return "Clear sky";
      case 1:
      case 2:
      case 3:
        return "Mainly clear";
      case 45:
      case 48:
        return "Fog and freezing fog";
      case 51:
      case 53:
      case 55:
        return "Drizzle";
      case 56:
      case 57:
        return "Freezing drizzle";
      case 61:
      case 63:
      case 65:
        return "Rain";
      case 66:
      case 67:
        return "Freezing rain";
      case 71:
      case 73:
      case 75:
        return "Snow";
      case 77:
        return "Snow grains";
      case 80:
      case 81:
      case 82:
        return "Rain showers";
      case 85:
      case 86:
        return "Snow showers";
      case 95:
        return "Thunderstorm";
      case 96:
      case 99:
        return "Thunderstorm with hail";
      default:
        return "Unknown";
    }
  }
}
