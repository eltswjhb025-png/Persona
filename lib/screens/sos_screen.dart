import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/database_helper.dart';
import '../services/theme_service.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  // ------------------------------------------------------------
  // COLOURS
  // ------------------------------------------------------------

  static const Color darkOlive = Color(0xFF3F4A16);
  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color olive = Color(0xFF808000);
  static const Color lightCream = Color(0xFFF4F5E9);

  static const Color darkBackground = Color(0xFF1E2412);
  static const Color darkCard = Color(0xFF2B321B);

  // ------------------------------------------------------------
  // STATE
  // ------------------------------------------------------------

  Position? sosPosition;

  bool isLoading = false;

  String message =
      'Press the button to send an emergency message.';

  // ------------------------------------------------------------
  // DATABASE
  // ------------------------------------------------------------

  final DatabaseHelper databaseHelper = DatabaseHelper();

  // ------------------------------------------------------------
  // SEND SOS
  // ------------------------------------------------------------

  Future<void> sendSOSMessage() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      message = 'Preparing emergency message...';
    });

    try {
      // ----------------------------------------------------------
      // 1. GET EMERGENCY CONTACTS
      // ----------------------------------------------------------

      final List<Map<String, dynamic>> contacts =
      await databaseHelper.getEmergencyContacts();

      if (contacts.isEmpty) {
        if (!mounted) return;

        setState(() {
          message =
          'No emergency contacts found. Add emergency contacts first.';
          isLoading = false;
        });

        return;
      }

      // ----------------------------------------------------------
      // 2. CHECK LOCATION SERVICES
      // ----------------------------------------------------------

      final bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          message =
          'Location services are disabled. Please turn them on.';
          isLoading = false;
        });

        return;
      }

      // ----------------------------------------------------------
      // 3. CHECK LOCATION PERMISSION
      // ----------------------------------------------------------

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          if (!mounted) return;

          setState(() {
            message = 'Location permission was denied.';
            isLoading = false;
          });

          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          message =
          'Location permission is permanently denied. Please enable it in Settings.';
          isLoading = false;
        });

        return;
      }

      // ----------------------------------------------------------
      // 4. GET CURRENT LOCATION
      // ----------------------------------------------------------

      if (!mounted) return;

      setState(() {
        message = 'Getting your current location...';
      });

      final Position position =
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      sosPosition = position;

      // ----------------------------------------------------------
      // 5. SAVE LOCATION TO DATABASE
      // ----------------------------------------------------------

      await databaseHelper.insertLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );

      // ----------------------------------------------------------
      // 6. CREATE GOOGLE MAPS LOCATION LINK
      // ----------------------------------------------------------

      final String mapsLink =
          'https://www.google.com/maps/search/?api=1'
          '&query=${position.latitude},${position.longitude}';

      // ----------------------------------------------------------
      // 7. CREATE SOS MESSAGE
      // ----------------------------------------------------------

      final String helpMessage =
          'EMERGENCY! I need help.\n\n'
          'My current location is:\n'
          '$mapsLink\n\n'
          'Please contact me as soon as possible.\n'
          'Sent from Persona SOS.';

      // ----------------------------------------------------------
      // 8. GET PHONE NUMBERS
      // ----------------------------------------------------------

      final List<String> phoneNumbers = contacts
          .map((contact) {
        final dynamic phone =
        contact['phone_number'];

        return phone?.toString().trim() ?? '';
      })
          .where((phone) => phone.isNotEmpty)
          .toList();

      if (phoneNumbers.isEmpty) {
        if (!mounted) return;

        setState(() {
          message =
          'Your emergency contacts do not have valid phone numbers.';
          isLoading = false;
        });

        return;
      }

      // ----------------------------------------------------------
      // 9. COMBINE PHONE NUMBERS
      // ----------------------------------------------------------

      final String recipients =
      phoneNumbers.join(',');

      // ----------------------------------------------------------
      // 10. OPEN SMS
      //
      // NOTE:
      // url_launcher opens the SMS application with the
      // recipients and message already filled in.
      //
      // The user still needs to press SEND.
      // ----------------------------------------------------------

      final Uri smsUri = Uri(
        scheme: 'sms',
        path: recipients,
        queryParameters: {
          'body': helpMessage,
        },
      );

      final bool launched = await launchUrl(
        smsUri,
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) return;

      if (launched) {
        setState(() {
          message =
          'Emergency message prepared for your emergency contacts.';
          isLoading = false;
        });
      } else {
        setState(() {
          message =
          'Unable to open the SMS application.';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        message =
        'Something went wrong while preparing the SOS message.';
        isLoading = false;
      });
    }
  }

  // ------------------------------------------------------------
  // GLASS CONTAINER
  // ------------------------------------------------------------

  Widget _buildGlassContainer({
    required Widget child,
    required bool isDarkMode,
    EdgeInsetsGeometry padding =
    const EdgeInsets.all(18),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: isDarkMode ? 0.16 : 0.25,
              ),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LOCATION TEXT
  // ------------------------------------------------------------

  Widget _buildLocationText() {
    if (sosPosition == null) {
      return const Text(
        'Your location will be included in the emergency message.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      );
    }

    return Column(
      children: [
        const Icon(
          Icons.location_on,
          color: Colors.white,
          size: 28,
        ),

        const SizedBox(height: 8),

        const Text(
          'Current location found',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          '${sosPosition!.latitude.toStringAsFixed(6)}, '
              '${sosPosition!.longitude.toStringAsFixed(6)}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDarkMode =
        themeService.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,

        systemNavigationBarColor:
        Colors.transparent,
        systemNavigationBarIconBrightness:
        Brightness.light,

        systemNavigationBarContrastEnforced:
        false,
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,

        // Allows the background to continue underneath
        // the Android navigation area.
        extendBody: true,
        extendBodyBehindAppBar: true,

        body: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,

              colors: isDarkMode
                  ? const [
                Color(0xFF252B17),
                Color(0xFF3F4A16),
                Color(0xFF1E2412),
              ]
                  : const [
                darkOlive,
                oliveDrab,
                olive,
                lightCream,
              ],

              stops: isDarkMode
                  ? const [
                0.0,
                0.45,
                1.0,
              ]
                  : const [
                0.0,
                0.35,
                0.70,
                1.0,
              ],
            ),
          ),

          child: SafeArea(
            bottom: false,

            child: SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                40,
              ),

              child: Column(
                children: [
                  // ------------------------------------------------
                  // HEADER
                  // ------------------------------------------------

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),

                      const Expanded(
                        child: Text(
                          'Emergency SOS',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ------------------------------------------------
                  // INTRODUCTION
                  // ------------------------------------------------

                  _buildGlassContainer(
                    isDarkMode: isDarkMode,

                    child: const Column(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 42,
                        ),

                        SizedBox(height: 10),

                        Text(
                          'Need Help?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'Persona will prepare an emergency message '
                              'with your current location for your emergency contacts.',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ------------------------------------------------
                  // LOCATION CARD
                  // ------------------------------------------------

                  _buildGlassContainer(
                    isDarkMode: isDarkMode,

                    child: Column(
                      children: [
                        const Text(
                          'SOS Location',

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        _buildLocationText(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // SEND HELP BUTTON
                  // ------------------------------------------------

                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : sendSOSMessage,

                    child: AnimatedContainer(
                      duration:
                      const Duration(
                        milliseconds: 200,
                      ),

                      width: 205,
                      height: 205,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        color: isLoading
                            ? Colors.red.shade300
                            : Colors.red.shade700,

                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withValues(
                              alpha: isDarkMode
                                  ? 0.40
                                  : 0.25,
                            ),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),

                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 4,
                        )
                            : const Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,

                          children: [
                            Icon(
                              Icons.sos,
                              color: Colors.white,
                              size: 58,
                            ),

                            SizedBox(height: 8),

                            Text(
                              'SEND HELP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight:
                                FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // STATUS
                  // ------------------------------------------------

                  _buildGlassContainer(
                    isDarkMode: isDarkMode,

                    child: Column(
                      children: [
                        const Text(
                          'Status',

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          message,
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ------------------------------------------------
                  // PERSONA LOGO / TEXT
                  // ------------------------------------------------

                  const Text(
                    'PERSONA',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                  ),

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}