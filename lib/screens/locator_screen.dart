import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocatorScreen extends StatefulWidget {
  const LocatorScreen({super.key});

  @override
  State<LocatorScreen> createState() => _LocatorScreenState();
}

class _LocatorScreenState extends State<LocatorScreen> {
  Position? currentPosition;
  String locationMessage = 'Location not found yet.';
  bool isLoading = false;

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoading = true;
      locationMessage = 'Getting your location...';
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() {
        isLoading = false;
        locationMessage = 'Please turn on location services.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        setState(() {
          isLoading = false;
          locationMessage = 'Location permission was denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        isLoading = false;
        locationMessage =
        'Location permission is permanently denied. '
            'Please enable it in Settings.';
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      currentPosition = position;
      isLoading = false;
      locationMessage =
      'Location found successfully!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      appBar: AppBar(
        title: const Text('Locator'),
        backgroundColor: const Color.fromRGBO(107, 142, 35, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.location_on,
              size: 80,
              color: Colors.white,
            ),

            const SizedBox(height: 20),

            Text(
              locationMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 30),

            if (currentPosition != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Latitude: ${currentPosition!.latitude}',
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Longitude: ${currentPosition!.longitude}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: isLoading ? null : getCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: Text(
                isLoading
                    ? 'Finding Location...'
                    : 'Find My Location',
              ),
            ),
          ],
        ),
      ),
    );
  }
}