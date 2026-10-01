import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/theme_service.dart';

class LocatorScreen extends StatefulWidget {
  const LocatorScreen({super.key});

  @override
  State<LocatorScreen> createState() => _LocatorScreenState();
}

class _LocatorScreenState extends State<LocatorScreen> {
  Position? currentPosition;

  String locationMessage = 'Location not found yet.';

  bool isLoading = false;

  Timer? locationTimer;

  final List<Position> locationHistory = [];

  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color olive = Color(0xFF808000);
  static const Color darkOlive = Color(0xFF3F4A16);
  static const Color lightCream = Color(0xFFF4F5E9);

  static const Color darkBackground = Color(0xFF1E2412);
  static const Color darkCard = Color(0xFF2B321B);

  @override
  void initState() {
    super.initState();

    getCurrentLocation();

    locationTimer = Timer.periodic(
      const Duration(minutes: 2),
          (timer) {
        getCurrentLocation();
      },
    );
  }

  // ===========================================================
  // GET CURRENT LOCATION
  // ===========================================================

  Future<void> getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      locationMessage = 'Getting your location...';
    });

    final bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        locationMessage =
        'Please turn on location services.';
      });

      return;
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
      await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          locationMessage =
          'Location permission was denied.';
        });

        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
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
      final Position position =
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        currentPosition = position;

        locationHistory.insert(
          0,
          position,
        );

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

  // ===========================================================
  // GET LOCAL TIME
  //
  // The Position timestamp can come from the location provider
  // in UTC. Convert it to the device's local timezone before
  // displaying it.
  // ===========================================================

  DateTime _getLocalTimestamp(Position position) {
    final DateTime timestamp =
        position.timestamp ?? DateTime.now();

    return timestamp.isUtc
        ? timestamp.toLocal()
        : timestamp;
  }

  // ===========================================================
  // FORMAT TIME
  // ===========================================================

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }

  // ===========================================================
  // FORMAT DATE
  // ===========================================================

  String _formatDate(DateTime timestamp) {
    return '${timestamp.day.toString().padLeft(2, '0')}/'
        '${timestamp.month.toString().padLeft(2, '0')}/'
        '${timestamp.year}';
  }

  // ===========================================================
  // DISPOSE
  // ===========================================================

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDarkMode =
        themeService.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,

      backgroundColor: isDarkMode
          ? darkBackground
          : lightCream,

      appBar: _buildAppBar(isDarkMode),

      body: Container(
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
              Color(0xFF808000),
              Color(0xFF6B8E23),
              Color(0xFF556B2F),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            physics:
            const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            children: [
              _buildLocationHeader(),

              const SizedBox(height: 20),

              _buildStatusCard(isDarkMode),

              const SizedBox(height: 20),

              if (currentPosition != null)
                _buildCurrentLocationCard(isDarkMode),

              if (currentPosition != null)
                const SizedBox(height: 20),

              _buildUpdateButton(isDarkMode),

              const SizedBox(height: 10),

              _buildAutomaticUpdateText(),

              const SizedBox(height: 28),

              _buildHistoryHeader(),

              const SizedBox(height: 12),

              if (locationHistory.isEmpty)
                _buildEmptyHistory(isDarkMode)
              else
                ...locationHistory.asMap().entries.map(
                      (entry) {
                    return _buildHistoryCard(
                      entry.value,
                      entry.key,
                      isDarkMode,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // APP BAR
  // ===========================================================

  PreferredSizeWidget _buildAppBar(
      bool isDarkMode,
      ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,

      title: Row(
        children: [
          Container(
            height: 42,
            width: 42,

            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: isDarkMode ? 0.10 : 0.15,
              ),

              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.white.withValues(
                  alpha: isDarkMode ? 0.16 : 0.25,
                ),
              ),
            ),

            child: const Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            'Locator',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // LOCATION HEADER
  // ===========================================================

  Widget _buildLocationHeader() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        const Text(
          'Your Location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'Keep track of your current position.',
          style: TextStyle(
            color: Colors.white.withValues(
              alpha: 0.72,
            ),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // STATUS CARD
  // ===========================================================

  Widget _buildStatusCard(bool isDarkMode) {
    return _buildGlassContainer(
      isDarkMode: isDarkMode,

      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,

            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: isDarkMode ? 0.16 : 0.90,
              ),
              borderRadius:
              BorderRadius.circular(18),
            ),

            child: Icon(
              isLoading
                  ? Icons.location_searching
                  : Icons.location_on,
              color: isDarkMode
                  ? Colors.white
                  : oliveDrab,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                const Text(
                  'Location Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  locationMessage,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.70,
                    ),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          if (isLoading)
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================
  // CURRENT LOCATION CARD
  // ===========================================================

  Widget _buildCurrentLocationCard(
      bool isDarkMode,
      ) {
    final Position position =
    currentPosition!;

    return _buildGlassContainer(
      isDarkMode: isDarkMode,
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.my_location,
                color: Colors.white,
                size: 23,
              ),

              const SizedBox(width: 9),

              const Text(
                'Current Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildCoordinateRow(
            icon: Icons.north_outlined,
            title: 'Latitude',
            value:
            position.latitude.toStringAsFixed(6),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 14),

          _buildCoordinateRow(
            icon: Icons.east_outlined,
            title: 'Longitude',
            value:
            position.longitude.toStringAsFixed(6),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 14),

          _buildCoordinateRow(
            icon: Icons.gps_fixed,
            title: 'Accuracy',
            value:
            '${position.accuracy.toStringAsFixed(1)} m',
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 14),

          _buildCoordinateRow(
            icon: Icons.access_time,
            title: 'Updated',
            value: _formatTime(
              _getLocalTimestamp(position),
            ),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // COORDINATE ROW
  // ===========================================================

  Widget _buildCoordinateRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: isDarkMode ? 0.05 : 0.08,
        ),

        borderRadius:
        BorderRadius.circular(15),

        border: Border.all(
          color: Colors.white.withValues(
            alpha: isDarkMode ? 0.08 : 0.10,
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,

            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: isDarkMode ? 0.08 : 0.12,
              ),
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: Colors.white,
              size: 19,
            ),
          ),

          const SizedBox(width: 12),

          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.65,
              ),
              fontSize: 13,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // UPDATE BUTTON
  // ===========================================================

  Widget _buildUpdateButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 54,

      child: ElevatedButton.icon(
        onPressed:
        isLoading ? null : getCurrentLocation,

        icon: Icon(
          isLoading
              ? Icons.hourglass_top
              : Icons.my_location,
        ),

        label: Text(
          isLoading
              ? 'Updating Location...'
              : 'Update Location Now',
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,

          foregroundColor: darkOlive,

          disabledBackgroundColor:
          Colors.white.withValues(
            alpha: isDarkMode ? 0.30 : 0.55,
          ),

          disabledForegroundColor:
          darkOlive.withValues(alpha: 0.55),

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(17),
          ),

          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // AUTOMATIC UPDATE TEXT
  // ===========================================================

  Widget _buildAutomaticUpdateText() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,

      children: [
        Icon(
          Icons.sync,
          color: Colors.white.withValues(
            alpha: 0.55,
          ),
          size: 15,
        ),

        const SizedBox(width: 6),

        Text(
          'Automatically updates every 2 minutes',
          textAlign: TextAlign.center,

          style: TextStyle(
            color: Colors.white.withValues(
              alpha: 0.60,
            ),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // HISTORY HEADER
  // ===========================================================

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,

      children: [
        const Text(
          'Location History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),

        if (locationHistory.isNotEmpty)
          TextButton(
            onPressed: () {
              setState(() {
                locationHistory.clear();
              });
            },

            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 8,
              ),
            ),

            child: const Text(
              'Clear',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ===========================================================
  // EMPTY HISTORY
  // ===========================================================

  Widget _buildEmptyHistory(
      bool isDarkMode,
      ) {
    return _buildGlassContainer(
      isDarkMode: isDarkMode,
      padding: const EdgeInsets.all(25),

      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,

            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: isDarkMode ? 0.07 : 0.10,
              ),
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.location_searching,
              color: Colors.white.withValues(
                alpha: 0.60,
              ),
              size: 29,
            ),
          ),

          const SizedBox(height: 13),

          Text(
            'No location history yet.',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.68,
              ),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Your location updates will appear here.',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.45,
              ),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // HISTORY CARD
  // ===========================================================

  Widget _buildHistoryCard(
      Position position,
      int index,
      bool isDarkMode,
      ) {
    final DateTime timestamp =
    _getLocalTimestamp(position);

    final String time =
    _formatTime(timestamp);

    final String date =
    _formatDate(timestamp);

    return Container(
      margin:
      const EdgeInsets.only(bottom: 12),

      child: _buildGlassContainer(
        isDarkMode: isDarkMode,
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: isDarkMode ? 0.07 : 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.55,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  '#${index + 1}',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.35,
                    ),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            _buildHistoryInfo(
              'Latitude',
              position.latitude
                  .toStringAsFixed(6),
            ),

            const SizedBox(height: 6),

            _buildHistoryInfo(
              'Longitude',
              position.longitude
                  .toStringAsFixed(6),
            ),

            const SizedBox(height: 6),

            _buildHistoryInfo(
              'Accuracy',
              '${position.accuracy.toStringAsFixed(1)} m',
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // HISTORY INFO
  // ===========================================================

  Widget _buildHistoryInfo(
      String label,
      String value,
      ) {
    return Row(
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.white.withValues(
              alpha: 0.55,
            ),
            fontSize: 13,
          ),
        ),

        const Spacer(),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // GLASS CONTAINER
  // ===========================================================

  Widget _buildGlassContainer({
    required Widget child,
    required bool isDarkMode,
    EdgeInsetsGeometry padding =
    const EdgeInsets.all(17),
  }) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(24),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),

        child: Container(
          padding: padding,

          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: isDarkMode ? 0.07 : 0.14,
            ),

            borderRadius:
            BorderRadius.circular(24),

            border: Border.all(
              color: Colors.white.withValues(
                alpha: isDarkMode ? 0.12 : 0.20,
              ),
              width: 1,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDarkMode ? 0.22 : 0.10,
                ),
                blurRadius: 20,
                offset:
                const Offset(0, 8),
              ),
            ],
          ),

          child: child,
        ),
      ),
    );
  }
}