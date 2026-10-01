import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

import '../services/google_auth_service.dart';
import '../services/theme_service.dart';
import 'home_screen.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() =>
      _GoogleSignInScreenState();
}

class _GoogleSignInScreenState
    extends State<GoogleSignInScreen> {
  bool isLoading = false;
  bool hasNavigated = false;

  @override
  void initState() {
    super.initState();

    GoogleAuthService.authenticationState.listen(
          (credentials) {
        if (!mounted ||
            credentials == null ||
            hasNavigated) {
          return;
        }

        hasNavigated = true;

        print(
          'GOOGLE UI: Authentication detected',
        );

        print(
          'GOOGLE UI: Navigating to HomeScreen',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const HomeScreen(),
          ),
        );
      },
    );
  }

  Future<void> signIn() async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    await GoogleAuthService.signIn();

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> signOut() async {
    await GoogleAuthService.signOut();

    if (!mounted) {
      return;
    }

    setState(() {
      hasNavigated = false;
    });
  }

  // =========================
  // GLASS CONTAINER
  // =========================

  Widget _buildGlassContainer({
    required Widget child,
    required bool isDarkMode,
    EdgeInsetsGeometry padding =
    const EdgeInsets.all(24),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.20)
                : Colors.white.withValues(alpha: 0.17),

            borderRadius:
            BorderRadius.circular(30),

            border: Border.all(
              color: Colors.white.withValues(
                alpha: isDarkMode ? 0.20 : 0.32,
              ),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color olive =
    Color(0xFF808000);

    const Color oliveDrab =
    Color(0xFF6B8E23);

    const Color darkOlive =
    Color(0xFF3F4A16);

    const Color lightCream =
    Color(0xFFF4F5E9);

    const Color darkBackground =
    Color(0xFF1E2412);

    const Color darkCard =
    Color(0xFF2B321B);

    // =========================
    // THEME
    // =========================

    final ThemeService themeService =
    ThemeProvider.of(context);

    final bool isDarkMode =
        themeService.isDarkMode;

    // =========================
    // THEME COLORS
    // =========================

    final List<Color> backgroundGradient =
    isDarkMode
        ? const [
      darkOlive,
      darkCard,
      darkBackground,
    ]
        : const [
      darkOlive,
      oliveDrab,
      olive,
      lightCream,
    ];

    final Color glassColor = isDarkMode
        ? Colors.black.withValues(alpha: 0.20)
        : Colors.white.withValues(alpha: 0.17);

    final Color glassBorderColor = Colors.white
        .withValues(
      alpha: isDarkMode ? 0.20 : 0.32,
    );

    final Color primaryText =
        Colors.white;

    final Color secondaryText =
    Colors.white.withValues(
      alpha: 0.70,
    );

    final Color subtleText =
    Colors.white.withValues(
      alpha: 0.60,
    );

    final Color verySubtleText =
    Colors.white.withValues(
      alpha: 0.54,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundGradient,
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 430,
                ),

                child: _buildGlassContainer(
                  isDarkMode: isDarkMode,

                  padding:
                  const EdgeInsets.fromLTRB(
                    28,
                    34,
                    28,
                    28,
                  ),

                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,

                    children: [

                      // =========================
                      // PERSONA ICON
                      // =========================

                      Container(
                        width: 90,
                        height: 90,

                        decoration:
                        BoxDecoration(
                          shape:
                          BoxShape.circle,

                          color: glassColor,

                          border:
                          Border.all(
                            color:
                            Colors.white
                                .withValues(
                              alpha: isDarkMode
                                  ? 0.25
                                  : 0.35,
                            ),
                            width: 1.5,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color:
                              darkOlive
                                  .withValues(
                                alpha:
                                isDarkMode
                                    ? 0.40
                                    : 0.25,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.spa_outlined,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // =========================
                      // TITLE
                      // =========================

                      Text(
                        'Google Account',

                        textAlign:
                        TextAlign.center,

                        style: TextStyle(
                          color: primaryText,
                          fontSize: 28,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        'Connect your Google account '
                            'to continue using Persona.',

                        textAlign:
                        TextAlign.center,

                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      // =========================
                      // GOOGLE INFORMATION CARD
                      // =========================

                      _buildGlassContainer(
                        isDarkMode:
                        isDarkMode,

                        padding:
                        const EdgeInsets.all(
                          18,
                        ),

                        child: Row(
                          children: [

                            Container(
                              width: 48,
                              height: 48,

                              decoration:
                              BoxDecoration(
                                color:
                                Colors.white,

                                borderRadius:
                                BorderRadius
                                    .circular(
                                  15,
                                ),
                              ),

                              child:
                              const Center(
                                child: Text(
                                  'G',

                                  style:
                                  TextStyle(
                                    fontSize:
                                    25,
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    color:
                                    Color(
                                      0xFF4285F4,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [

                                  Text(
                                    'Google Sign-In',

                                    style:
                                    TextStyle(
                                      color:
                                      primaryText,
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    'Securely authenticate '
                                        'with Google.',

                                    style:
                                    TextStyle(
                                      color:
                                      subtleText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =========================
                      // SIGN IN BUTTON
                      // =========================

                      SizedBox(
                        width:
                        double.infinity,
                        height: 54,

                        child:
                        ElevatedButton(
                          onPressed:
                          isLoading
                              ? null
                              : signIn,

                          style: ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            Colors.white,

                            foregroundColor:
                            darkOlive,

                            disabledBackgroundColor:
                            Colors.white54,

                            elevation: 0,

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                18,
                              ),
                            ),
                          ),

                          child: isLoading
                              ? const SizedBox(
                            width: 23,
                            height: 23,

                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2.5,
                              color:
                              darkOlive,
                            ),
                          )
                              : Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                            children: [

                              Container(
                                width: 26,
                                height: 26,

                                decoration:
                                BoxDecoration(
                                  color:
                                  Colors
                                      .grey
                                      .shade100,

                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    7,
                                  ),
                                ),

                                child:
                                const Center(
                                  child:
                                  Text(
                                    'G',

                                    style:
                                    TextStyle(
                                      fontSize:
                                      17,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      color:
                                      Color(
                                        0xFF4285F4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              const Text(
                                'Sign in with Google',

                                style:
                                TextStyle(
                                  fontSize:
                                  16,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // =========================
                      // SECURITY MESSAGE
                      // =========================

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                        children: [

                          Icon(
                            Icons.lock_outline,
                            color:
                            Colors.white
                                .withValues(
                              alpha: 0.55,
                            ),
                            size: 16,
                          ),

                          const SizedBox(
                            width: 7,
                          ),

                          Text(
                            'Secure Google authentication',

                            style: TextStyle(
                              color:
                              subtleText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      // =========================
                      // PERSONA BRANDING
                      // =========================

                      Text(
                        'PERSONA',

                        style: TextStyle(
                          color:
                          verySubtleText,
                          fontSize: 11,
                          fontWeight:
                          FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}