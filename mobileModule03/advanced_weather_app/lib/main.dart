import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
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
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.blue, brightness: .dark),
      ),
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

  static const Map<int, String> _weatherDescriptions = {
    0: "Clear sky",
    1: "Mainly clear",
    2: "Partly cloudy",
    3: "Overcast",
    45: "Fog",
    48: "Rime fog",
    51: "Drizzle",
    53: "Drizzle",
    55: "Dense drizzle",
    56: "Freezing drizzle",
    57: "Freezing drizzle",
    61: "Light rain",
    63: "Rain",
    65: "Heavy rain",
    66: "Freezing rain",
    67: "Freezing rain",
    71: "Light snow",
    73: "Snow",
    75: "Heavy snow",
    77: "Snow grains",
    80: "Rain showers",
    81: "Rain showers",
    82: "Heavy showers",
    85: "Snow showers",
    86: "Snow showers",
    95: "Thunderstorm",
    96: "Hail storm",
    99: "Hail storm",
  };

  static const Map<int, IconData> _weatherIcons = {
    0: Icons.wb_sunny_rounded,
    1: Icons.wb_cloudy_rounded,
    2: Icons.wb_cloudy_rounded,
    3: Icons.cloud_rounded,
    45: Icons.foggy,
    48: Icons.foggy,
    51: Icons.grain_rounded,
    53: Icons.grain_rounded,
    55: Icons.grain_rounded,
    56: Icons.grain_rounded,
    57: Icons.grain_rounded,
    61: Icons.water_drop_rounded,
    63: Icons.water_drop_rounded,
    65: Icons.water_drop_rounded,
    66: Icons.water_drop_rounded,
    67: Icons.water_drop_rounded,
    71: Icons.ac_unit_rounded,
    73: Icons.ac_unit_rounded,
    75: Icons.ac_unit_rounded,
    77: Icons.ac_unit_rounded,
    80: Icons.water_drop_rounded,
    81: Icons.water_drop_rounded,
    82: Icons.water_drop_rounded,
    85: Icons.ac_unit_rounded,
    86: Icons.ac_unit_rounded,
    95: Icons.thunderstorm_rounded,
    96: Icons.thunderstorm_rounded,
    99: Icons.thunderstorm_rounded,
  };

  IconData _getIcon(int? code) =>
      _weatherIcons[code] ?? Icons.help_outline_rounded;

  String _getWetherDescription(int? code) =>
      _weatherDescriptions[code] ?? "Unknown";

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
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: .mode(
              Colors.black.withValues(alpha: .50),
              BlendMode.darken,
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Container(
                height: 44,
                alignment: .center,
                clipBehavior: .antiAlias,
                padding: const .symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TextField(
                  textAlignVertical: .center,
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: .none,
                    focusedBorder: .none,
                    hintText: 'Search location...',
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 22),
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
                              : LayoutBuilder(
                                  builder: (context, constraints) =>
                                      SingleChildScrollView(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight: constraints.maxHeight,
                                          ),
                                          child: _buildCurrentTab(tab),
                                        ),
                                      ),
                                ),
                        ),
                      )
                      .toList(),
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    padding: const .symmetric(horizontal: 20),
                    clipBehavior: .antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Material(
                        // clipBehavior: .antiAlias,
                        color: Colors.grey.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(12),
                        child: ListView.builder(
                          shrinkWrap: true,
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
                                      text:
                                          "${_suggestions[index]["admin1"]}, ",
                                    ),
                                  TextSpan(
                                    text: "${_suggestions[index]["country"]}",
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              debugPrint(
                                "Selected => ${_suggestions[index]['name']}",
                              );
                              _removeFocus();
                              _fetchCityWeather(_suggestions[index]);
                              setState(() => _suggestions = []);
                            },
                          ),
                          itemCount: _suggestions.length,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: BottomAppBar(
              color: Colors.transparent,
              padding: .zero,
              child: TabBar(
                tabs: TabType.values
                    .map(
                      (tab) => Tab(
                        icon: Icon(tab.getIcon()),
                        text: tab.stringValue(),
                      ),
                    )
                    .toList(),
              ),
            ),
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
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 42,
          mainAxisAlignment: .center,
          children: [
            _buildHeader(),

            Text(
              '${_currentWeather['current']?['temperature_2m']}°C',
              style: const TextStyle(color: Colors.amber, fontSize: 48),
            ),

            Column(
              spacing: 8,
              children: [
                Text(
                  _getWetherDescription(
                    _currentWeather['current']?['weather_code'],
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Icon(
                  _getIcon(_currentWeather['current']?['weather_code']),
                  size: 100,
                ),
              ],
            ),

            Row(
              spacing: 8,
              mainAxisAlignment: .center,
              children: [
                const Icon(Icons.air, color: Colors.blue),
                Text(
                  '${_currentWeather['current']?['wind_speed_10m']} km/h',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      );
    }
    if (tab == .today) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 24,
            children: [
              _buildHeader(),
              Container(
                padding: const .all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Today temperatures'),
                    ),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 3,
                                reservedSize: 34,
                                getTitlesWidget: (val, _) {
                                  if (val == 23) return const SizedBox.shrink();
                                  return Text(
                                    '${val.toInt().toString().padLeft(2, '0')}:00',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                // interval: 1,
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (val, meta) {
                                  if (val == meta.min || val == meta.max) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    '${val.toInt()}°',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                24,
                                (i) => FlSpot(
                                  i.toDouble(),
                                  (_currentWeather['hourly']['temperature_2m'][i]
                                          as num)
                                      .toDouble(),
                                ),
                              ),
                              isCurved: true,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 150,
                child: ListView.separated(
                  separatorBuilder: (context, n) => const SizedBox(width: 2),
                  itemCount: 24,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, n) {
                    return Container(
                      width: 100,
                      alignment: .center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        spacing: 8,
                        mainAxisSize: .min,
                        children: [
                          Text(
                            _currentWeather['hourly']['time'][n]
                                .toString()
                                .split('T')[1],
                          ),
                          Icon(
                            _getIcon(
                              _currentWeather['hourly']?['weather_code'][n],
                            ),
                          ),
                          Text(
                            '${_currentWeather['hourly']['temperature_2m'][n]}°C',
                          ),

                          Row(
                            mainAxisSize: .min,
                            mainAxisAlignment: .center,
                            spacing: 4,
                            children: [
                              const Icon(
                                Icons.air,
                                color: Colors.blue,
                                size: 14,
                              ),
                              Text(
                                '${_currentWeather['hourly']['wind_speed_10m'][n]}km/h',
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (tab == .weekly) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 24,
            children: [
              _buildHeader(),

              Container(
                padding: const .all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: .only(bottom: 16),
                      child: Text('Weekly temperatures'),
                    ),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                reservedSize: 34,
                                getTitlesWidget: (val, _) {
                                  if (val == 23) return const SizedBox.shrink();
                                  return Text(
                                    _getDayOfWeek(
                                      _currentWeather['daily']['time'][val
                                          .toInt()],
                                    ),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                interval: 5,
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (val, meta) {
                                  if (val == meta.min || val == meta.max) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    '${val.toInt()}°',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                7,
                                (i) => FlSpot(
                                  i.toDouble(),
                                  (_currentWeather['daily']['temperature_2m_max'][i]
                                          as num)
                                      .toDouble(),
                                ),
                              ),
                              isCurved: true,
                              color: Colors.red,
                            ),
                            // if (false)
                            LineChartBarData(
                              spots: List.generate(
                                7,
                                (i) => FlSpot(
                                  i.toDouble(),
                                  (_currentWeather['daily']['temperature_2m_min'][i]
                                          as num)
                                      .toDouble(),
                                ),
                              ),
                              isCurved: true,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Row(
                      mainAxisSize: .min,
                      children: [
                        Icon(
                          Icons.commit_rounded,
                          color: Colors.blue,
                          size: 18,
                        ),
                        Text('Min temperature', style: TextStyle(fontSize: 11)),
                        SizedBox(width: 12),
                        Icon(Icons.commit_rounded, color: Colors.red, size: 18),
                        Text('Max temperature', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 150,
                child: ListView.separated(
                  separatorBuilder: (context, n) => const SizedBox(width: 2),
                  itemCount: 6,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, n) {
                    return Container(
                      width: 100,
                      alignment: .center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        spacing: 8,
                        mainAxisSize: .min,
                        children: [
                          Text(
                            _getDayOfWeek(_currentWeather['daily']['time'][n]),
                          ),
                          Icon(
                            _getIcon(
                              _currentWeather['daily']?['weather_code'][n],
                            ),
                          ),
                          Text(
                            '${_currentWeather['daily']['temperature_2m_max'][n]}°C max',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${_currentWeather['daily']['temperature_2m_min'][n]}°C min',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          _currentWeather['name'],
          style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 32,
            fontWeight: .bold,
          ),
        ),
        Text.rich(
          TextSpan(
            text: '${_currentWeather['admin1']}, ',
            children: [TextSpan(text: _currentWeather['country'])],
          ),
        ),
      ],
    );
  }

  String _getDayOfWeek(String date) =>
      '${date.split('-')[1]}/${date.split('-')[2]}';
}
