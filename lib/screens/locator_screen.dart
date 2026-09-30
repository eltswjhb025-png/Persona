import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocatorScreen extends StatefulWidget {
  const LocatorScreen({super.key});

  @override
  State<LocatorScreen> createState() =>
      _LocatorScreenState();
}

class _LocatorScreenState
    extends State<LocatorScreen> {
  Position? currentPosition;

  String locationMessage =
      'Location not found yet.';

  bool isLoading = false;

  // Timer used to update the location
  // every 2 minutes.
  Timer? locationTimer;

  @override
  void initState() {
    super.initState();

    // Get the location when the screen
    // is opened.
    getCurrentLocation();

    // Then update the location every
    // 2 minutes.
    locationTimer = Timer.periodic(
      const Duration(minutes: 2),
          (timer) {
        getCurrentLocation();
      },
    );
  }

  Future<void> getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      locationMessage =
      'Getting your location...';
    });

    // Check whether location services
    // are turned on.
    bool serviceEnabled =
    await Geolocator
        .isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        locationMessage =
        'Please turn on location services.';
      });

      return;
    }

    // Check location permission.
    LocationPermission permission =
    await Geolocator.checkPermission();

    // Ask for permission if necessary.
    if (permission ==
        LocationPermission.denied) {
      permission =
      await Geolocator.requestPermission();

      if (permission ==
          LocationPermission.denied) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          locationMessage =
          'Location permission was denied.';
        });

        return;
      }
    }

    // The user permanently denied
    // location permission.
    if (permission ==
        LocationPermission.deniedForever) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        locationMessage =
        'Location permission is permanently denied. '
            'Please enable it in Settings.';
      });

      return;
    }

    try {
      // Get the current GPS position.
      Position position =
      await Geolocator
          .getCurrentPosition(
        locationSettings:
        const LocationSettings(
          accuracy:
          LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        currentPosition = position;
        isLoading = false;
        locationMessage =
        'Location updated successfully!';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        locationMessage =
        'Unable to get your location.';
      });
    }
  }

  @override
  void dispose() {
    // IMPORTANT:
    // Stop the timer when leaving
    // the Locator screen.
    locationTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check Dark Mode.
    final bool isDarkMode =
        Theme.of(context).brightness ==
            Brightness.dark;

    // Persona colours.
    const Color olive =
    Color(0xFF808000);

    const Color oliveDrab =
    Color(0xFF6B8E23);

    const Color darkBackground =
    Color(0xFF121510);

    const Color darkCard =
    Color(0xFF1E231B);

    // Screen background.
    final Color screenBackground =
    isDarkMode
        ? darkBackground
        : olive;

    // Location information card.
    final Color cardBackground =
    isDarkMode
        ? darkCard
        : Colors.white;

    // Text inside the card.
    final Color cardTextColor =
    isDarkMode
        ? Colors.white
        : Colors.black87;

    return Scaffold(
      backgroundColor:
      screenBackground,

      // ---------------- APP BAR ----------------

      appBar: AppBar(
        title: const Text(
          'Locator',
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      // ---------------- BODY ----------------

      body: Padding(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          children: [
            // ---------------- LOCATION ICON ----------------

            Container(
              width: 110,
              height: 110,

              decoration:
              BoxDecoration(
                color: isDarkMode
                    ? darkCard
                    : Colors.white
                    .withOpacity(0.15),

                shape:
                BoxShape.circle,
              ),

              child: const Icon(
                Icons.location_on,
                size: 80,
                color: Colors.white,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ---------------- STATUS ----------------

            Text(
              locationMessage,

              textAlign:
              TextAlign.center,

              style:
              const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // Show a small loading indicator
            // whenever the location is being
            // updated.
            if (isLoading)
              const SizedBox(
                width: 25,
                height: 25,
                child:
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),

            const SizedBox(
              height: 30,
            ),

            // ---------------- LOCATION CARD ----------------

            if (currentPosition != null)
              Card(
                color:
                cardBackground,

                elevation: 4,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),

                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    20,
                  ),

                  child: Column(
                    children: [
                      // Latitude

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .north_outlined,
                            color:
                            oliveDrab,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child: Text(
                              'Latitude: '
                                  '${currentPosition!.latitude}',

                              style:
                              TextStyle(
                                fontSize: 18,
                                color:
                                cardTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // Longitude

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .east_outlined,
                            color:
                            oliveDrab,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child: Text(
                              'Longitude: '
                                  '${currentPosition!.longitude}',

                              style:
                              TextStyle(
                                fontSize: 18,
                                color:
                                cardTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // Accuracy

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .gps_fixed,
                            color:
                            oliveDrab,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child: Text(
                              'Accuracy: '
                                  '${currentPosition!.accuracy.toStringAsFixed(1)} m',

                              style:
                              TextStyle(
                                fontSize: 18,
                                color:
                                cardTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(
              height: 30,
            ),

            // ---------------- MANUAL UPDATE BUTTON ----------------

            SizedBox(
              width: double.infinity,

              child:
              ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : getCurrentLocation,

                icon: const Icon(
                  Icons.my_location,
                ),

                label: Text(
                  isLoading
                      ? 'Updating Location...'
                      : 'Update Location Now',

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  olive,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 16,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // ---------------- LIVE UPDATE MESSAGE ----------------

            Text(
              'Location automatically updates every 2 minutes.',

              textAlign:
              TextAlign.center,

              style:
              TextStyle(
                color: isDarkMode
                    ? Colors.white70
                    : Colors.white70,

                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}