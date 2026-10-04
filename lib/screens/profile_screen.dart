import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../services/theme_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ============================================================
  // Persona Colors
  // ============================================================

  static const Color olive = Color(0xFF808000);
  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color darkOlive = Color(0xFF3F4A16);
  static const Color lightCream = Color(0xFFF4F5E9);
  static const Color darkBackground = Color(0xFF1E2412);
  static const Color darkCard = Color(0xFF2B321B);

  // ============================================================
  // Controllers
  // ============================================================

  final TextEditingController _nameController =
  TextEditingController();

  bool _isSaving = false;
  String? _profileImagePath;

  // ============================================================
  // Load Current User
  // ============================================================

  @override
  void initState() {
    super.initState();

    final User? user =
        FirebaseAuth.instance.currentUser;

    _nameController.text =
        user?.displayName ?? '';

    _loadProfileImage();
  }

  // ============================================================
  // Load Saved Profile Photo
  // ============================================================

  Future<void> _loadProfileImage() async {
    try {
      final Directory appDirectory =
      await getApplicationDocumentsDirectory();

      final String savedPath =
          '${appDirectory.path}/persona_profile_photo.jpg';

      final File imageFile =
      File(savedPath);

      if (await imageFile.exists()) {
        if (!mounted) {
          return;
        }

        setState(() {
          _profileImagePath = savedPath;
        });
      }
    } catch (e) {
      debugPrint(
        'Could not load profile photo: $e',
      );
    }
  }

  // ============================================================
  // Pick Profile Photo
  // ============================================================

  Future<void> _pickProfilePhoto() async {
    try {
      final PlatformFile? selectedFile =
      await FilePicker.pickFile(
        type: FileType.image,
      );

      if (selectedFile == null ||
          selectedFile.path == null) {
        return;
      }

      final Directory appDirectory =
      await getApplicationDocumentsDirectory();

      final String savedPath =
          '${appDirectory.path}/persona_profile_photo.jpg';

      final File sourceFile =
      File(selectedFile.path!);

      await sourceFile.copy(savedPath);

      if (!mounted) {
        return;
      }

      setState(() {
        _profileImagePath = savedPath;
      });

      _showMessage(
        'Profile photo updated.',
      );
    } catch (e) {
      debugPrint(
        'Could not select profile photo: $e',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not upload the photo. Please try again.',
      );
    }
  }

  // ============================================================
  // Remove Profile Photo
  // ============================================================

  Future<void> _removeProfilePhoto() async {
    try {
      if (_profileImagePath != null) {
        final File imageFile =
        File(_profileImagePath!);

        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _profileImagePath = null;
      });

      _showMessage(
        'Profile photo removed.',
      );
    } catch (e) {
      debugPrint(
        'Could not remove profile photo: $e',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not remove the photo. Please try again.',
      );
    }
  }

  // ============================================================
  // Profile Photo Options
  // ============================================================

  void _showPhotoOptions(
      bool isDarkMode,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? darkCard.withValues(
              alpha: 0.96,
            )
                : lightCream.withValues(
              alpha: 0.96,
            ),
            borderRadius:
            const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white24
                          : darkOlive.withValues(
                        alpha: 0.25,
                      ),
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    'Profile Photo',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white
                          : darkOlive,
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ==================================================
                  // Upload Photo
                  // ==================================================

                  ListTile(
                    leading:
                    const CircleAvatar(
                      backgroundColor:
                      oliveDrab,
                      child: Icon(
                        Icons
                            .photo_library_outlined,
                        color:
                        Colors.white,
                      ),
                    ),
                    title: Text(
                      'Upload Photo',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white
                            : darkOlive,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Choose a photo from your device',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white60
                            : darkOlive.withValues(
                          alpha: 0.60,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                      );

                      _pickProfilePhoto();
                    },
                  ),

                  // ==================================================
                  // Remove Photo
                  // ==================================================

                  if (_profileImagePath != null)
                    ListTile(
                      leading:
                      const CircleAvatar(
                        backgroundColor:
                        Colors.redAccent,
                        child: Icon(
                          Icons.delete_outline,
                          color:
                          Colors.white,
                        ),
                      ),
                      title: Text(
                        'Remove Photo',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : darkOlive,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(
                          context,
                        );

                        _removeProfilePhoto();
                      },
                    ),

                  const SizedBox(
                    height: 8,
                  ),

                  // ==================================================
                  // Cancel
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white70
                              : darkOlive,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ============================================================
  // Save Profile
  // ============================================================

  Future<void> _saveProfile() async {
    final String name =
    _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage(
        'Please enter your name.',
      );

      return;
    }

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'No logged-in user found.',
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await user.updateDisplayName(name);

      await user.reload();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Profile updated successfully.',
      );

      Navigator.pop(
        context,
        true,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.message ??
            'Could not update your profile.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // Message
  // ============================================================

  void _showMessage(
      String message,
      ) {
    final bool isDarkMode =
        Theme.of(context).brightness ==
            Brightness.dark;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isDarkMode
            ? darkOlive
            : oliveDrab,
        behavior:
        SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // Glass Card
  // ============================================================

  Widget _glassCard({
    required Widget child,
    required bool isDarkMode,
    EdgeInsetsGeometry padding =
    const EdgeInsets.all(20),
  }) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.black.withValues(
              alpha: 0.25,
            )
                : Colors.white.withValues(
              alpha: 0.16,
            ),
            borderRadius:
            BorderRadius.circular(24),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(
                alpha: 0.15,
              )
                  : Colors.white.withValues(
                alpha: 0.28,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ============================================================
  // Name Text Field
  // ============================================================

  Widget _buildNameField(
      bool isDarkMode,
      ) {
    return TextField(
      controller: _nameController,
      textCapitalization:
      TextCapitalization.words,
      style: TextStyle(
        color: isDarkMode
            ? Colors.white
            : darkOlive,
        fontSize: 16,
      ),
      decoration:
      InputDecoration(
        labelText: 'Name',
        labelStyle: TextStyle(
          color: isDarkMode
              ? Colors.white70
              : darkOlive.withValues(
            alpha: 0.75,
          ),
        ),
        hintText: 'Enter your name',
        hintStyle: TextStyle(
          color: isDarkMode
              ? Colors.white38
              : darkOlive.withValues(
            alpha: 0.45,
          ),
        ),
        prefixIcon:
        const Icon(
          Icons.person_outline,
          color: oliveDrab,
        ),
        filled: true,
        fillColor: isDarkMode
            ? Colors.black.withValues(
          alpha: 0.20,
        )
            : Colors.white.withValues(
          alpha: 0.20,
        ),
        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            18,
          ),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(
              alpha: 0.15,
            )
                : Colors.white.withValues(
              alpha: 0.30,
            ),
          ),
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            18,
          ),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(
              alpha: 0.15,
            )
                : Colors.white.withValues(
              alpha: 0.30,
            ),
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            18,
          ),
          borderSide:
          const BorderSide(
            color: oliveDrab,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Profile Photo
  // ============================================================

  Widget _buildProfilePhoto(
      bool isDarkMode,
      ) {
    return GestureDetector(
      onTap: () =>
          _showPhotoOptions(
            isDarkMode,
          ),
      child: Stack(
        clipBehavior:
        Clip.none,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration:
            BoxDecoration(
              shape:
              BoxShape.circle,
              color: isDarkMode
                  ? oliveDrab.withValues(
                alpha: 0.25,
              )
                  : Colors.white
                  .withValues(
                alpha: 0.20,
              ),
              border:
              Border.all(
                color: isDarkMode
                    ? oliveDrab.withValues(
                  alpha: 0.60,
                )
                    : Colors.white
                    .withValues(
                  alpha: 0.50,
                ),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(
                    alpha: 0.15,
                  ),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child:
            ClipOval(
              child:
              _profileImagePath !=
                  null
                  ? Image.file(
                File(
                  _profileImagePath!,
                ),
                width: 112,
                height: 112,
                fit: BoxFit.cover,
              )
                  : const Icon(
                Icons.person,
                color:
                Colors.white,
                size: 58,
              ),
            ),
          ),

          // ==================================================
          // Camera Button
          // ==================================================

          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 38,
              height: 38,
              decoration:
              BoxDecoration(
                color: oliveDrab,
                shape:
                BoxShape.circle,
                border:
                Border.all(
                  color: isDarkMode
                      ? darkCard
                      : Colors.white,
                  width: 3,
                ),
              ),
              child:
              const Icon(
                Icons
                    .camera_alt_outlined,
                color:
                Colors.white,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final ThemeService
    themeService =
    ThemeProvider.of(
      context,
    );

    final bool isDarkMode =
        themeService.isDarkMode;

    final User? user =
        FirebaseAuth.instance
            .currentUser;

    return Scaffold(
      extendBodyBehindAppBar:
      true,
      body: Container(
        decoration:
        BoxDecoration(
          gradient:
          LinearGradient(
            begin:
            Alignment.topLeft,
            end: Alignment
                .bottomRight,
            colors: isDarkMode
                ? const [
              Color(0xFF252B17),
              Color(0xFF3F4A16),
              Color(0xFF1E2412),
            ]
                : const [
              oliveDrab,
              olive,
              darkOlive,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ==================================================
              // App Bar
              // ==================================================

              Padding(
                padding:
                const EdgeInsets
                    .fromLTRB(
                  16,
                  12,
                  16,
                  8,
                ),
                child:
                ClipRRect(
                  borderRadius:
                  BorderRadius
                      .circular(
                    20,
                  ),
                  child:
                  BackdropFilter(
                    filter:
                    ImageFilter.blur(
                      sigmaX: 12,
                      sigmaY: 12,
                    ),
                    child:
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration:
                      BoxDecoration(
                        color: isDarkMode
                            ? Colors
                            .black
                            .withValues(
                          alpha:
                          0.25,
                        )
                            : Colors
                            .white
                            .withValues(
                          alpha:
                          0.14,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                        border:
                        Border.all(
                          color: isDarkMode
                              ? Colors
                              .white
                              .withValues(
                            alpha:
                            0.15,
                          )
                              : Colors
                              .white
                              .withValues(
                            alpha:
                            0.22,
                          ),
                        ),
                      ),
                      child:
                      Row(
                        children: [
                          IconButton(
                            icon:
                            const Icon(
                              Icons
                                  .arrow_back_ios_new,
                              color:
                              Colors.white,
                            ),
                            onPressed:
                                () {
                              Navigator
                                  .pop(
                                context,
                              );
                            },
                          ),

                          const Expanded(
                            child:
                            Text(
                              'Profile',
                              style:
                              TextStyle(
                                color:
                                Colors.white,
                                fontSize:
                                22,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons
                                .person_outline,
                            color:
                            Colors.white,
                            size: 26,
                          ),

                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // Content
              // ==================================================

              Expanded(
                child:
                SingleChildScrollView(
                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    20,
                    20,
                    20,
                    30,
                  ),
                  child:
                  Column(
                    children: [
                      // ==================================================
                      // Profile Header
                      // ==================================================

                      _glassCard(
                        isDarkMode:
                        isDarkMode,
                        child:
                        Column(
                          children: [
                            _buildProfilePhoto(
                              isDarkMode,
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            Text(
                              _nameController
                                  .text
                                  .isNotEmpty
                                  ? _nameController
                                  .text
                                  : 'Persona User',
                              textAlign:
                              TextAlign
                                  .center,
                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontSize:
                                22,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              user?.email ??
                                  'No email available',
                              textAlign:
                              TextAlign
                                  .center,
                              style:
                              TextStyle(
                                color:
                                Colors.white
                                    .withValues(
                                  alpha:
                                  0.70,
                                ),
                                fontSize:
                                14,
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            GestureDetector(
                              onTap:
                                  () =>
                                  _showPhotoOptions(
                                    isDarkMode,
                                  ),
                              child:
                              Row(
                                mainAxisSize:
                                MainAxisSize
                                    .min,
                                children: [
                                  const Icon(
                                    Icons
                                        .camera_alt_outlined,
                                    color:
                                    Colors.white70,
                                    size:
                                    17,
                                  ),

                                  const SizedBox(
                                    width: 6,
                                  ),

                                  Text(
                                    _profileImagePath ==
                                        null
                                        ? 'Add profile photo'
                                        : 'Change profile photo',
                                    style:
                                    const TextStyle(
                                      color:
                                      Colors.white70,
                                      fontSize:
                                      13,
                                      fontWeight:
                                      FontWeight
                                          .w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // ==================================================
                      // Edit Profile
                      // ==================================================

                      Align(
                        alignment:
                        Alignment
                            .centerLeft,
                        child:
                        Text(
                          'EDIT PROFILE',
                          style:
                          TextStyle(
                            color:
                            Colors.white
                                .withValues(
                              alpha:
                              0.75,
                            ),
                            fontSize:
                            12,
                            fontWeight:
                            FontWeight
                                .bold,
                            letterSpacing:
                            1.5,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _glassCard(
                        isDarkMode:
                        isDarkMode,
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            _buildNameField(
                              isDarkMode,
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // ==================================================
                            // Email
                            // ==================================================

                            TextField(
                              enabled:
                              false,
                              controller:
                              TextEditingController(
                                text:
                                user?.email ??
                                    '',
                              ),
                              style:
                              TextStyle(
                                color: isDarkMode
                                    ? Colors
                                    .white54
                                    : darkOlive
                                    .withValues(
                                  alpha:
                                  0.55,
                                ),
                              ),
                              decoration:
                              InputDecoration(
                                labelText:
                                'Email',
                                labelStyle:
                                TextStyle(
                                  color: isDarkMode
                                      ? Colors
                                      .white54
                                      : darkOlive
                                      .withValues(
                                    alpha:
                                    0.55,
                                  ),
                                ),
                                prefixIcon:
                                const Icon(
                                  Icons
                                      .email_outlined,
                                  color:
                                  oliveDrab,
                                ),
                                filled:
                                true,
                                fillColor:
                                isDarkMode
                                    ? Colors
                                    .black
                                    .withValues(
                                  alpha:
                                  0.15,
                                )
                                    : Colors
                                    .white
                                    .withValues(
                                  alpha:
                                  0.12,
                                ),
                                border:
                                OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    18,
                                  ),
                                  borderSide:
                                  BorderSide
                                      .none,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 22,
                            ),

                            // ==================================================
                            // Save Button
                            // ==================================================

                            SizedBox(
                              width:
                              double.infinity,
                              height: 55,
                              child:
                              ElevatedButton
                                  .icon(
                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  isDarkMode
                                      ? oliveDrab
                                      : Colors
                                      .white,
                                  foregroundColor:
                                  isDarkMode
                                      ? Colors
                                      .white
                                      : darkOlive,
                                  elevation:
                                  0,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      18,
                                    ),
                                  ),
                                ),
                                icon: _isSaving
                                    ? SizedBox(
                                  width:
                                  20,
                                  height:
                                  20,
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth:
                                    2,
                                    color: isDarkMode
                                        ? Colors
                                        .white
                                        : oliveDrab,
                                  ),
                                )
                                    : const Icon(
                                  Icons
                                      .save_outlined,
                                ),
                                label:
                                Text(
                                  _isSaving
                                      ? 'SAVING...'
                                      : 'SAVE CHANGES',
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    letterSpacing:
                                    1,
                                  ),
                                ),
                                onPressed:
                                _isSaving
                                    ? null
                                    : _saveProfile,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // ==================================================
                      // Account Information
                      // ==================================================

                      _glassCard(
                        isDarkMode:
                        isDarkMode,
                        child:
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Icon(
                              Icons
                                  .info_outline,
                              color: Colors
                                  .white
                                  .withValues(
                                alpha:
                                0.80,
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Expanded(
                              child:
                              Text(
                                'Your email is linked to your '
                                    'Persona account. You can change '
                                    'your display name and profile photo here.',
                                style:
                                TextStyle(
                                  color: Colors
                                      .white
                                      .withValues(
                                    alpha:
                                    0.75,
                                  ),
                                  fontSize:
                                  13,
                                  height:
                                  1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}