import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              border: .none,
              focusedBorder: .none,
              hint: Text(
                'Search location...',
                maxLines: 1,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            onSubmitted: (text) {},
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
        body: TabBarView(
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
}
