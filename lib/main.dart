import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          color: Colors.yellow,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[850], // Dark grey background color
            foregroundColor: Colors.white, // White text color
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Coordinates Generator'),
        ),
        body: const LocationScreen(),
      ),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? _latitude;
  String? _longitude;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _openMap() async {
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Geolocator Package Demo',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: _latitude == null || _longitude == null
                  ? const Text(
                'Press the button to get location coordinates',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LATITUDE: $_latitude',
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.yellow, // Yellow font color for coordinates
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'LONGITUDE: $_longitude',
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.yellow, // Yellow font color for coordinates
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: const Text('Get Current Location'),
          ),
          const SizedBox(height: 20),
          if (_currentPosition != null)
            Column(
              children: [
                const Text(
                  'URL Launcher Package Demo',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _openMap,
                  child: const Text('Show pin in Google Maps'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
