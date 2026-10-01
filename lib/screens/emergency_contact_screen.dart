import 'dart:ui';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
  // ============================================================
  // Persona Colors
  // ============================================================

  static const Color oliveDrab = Color(0xFF6B8E23);
  static const Color olive = Color(0xFF808000);
  static const Color darkOlive = Color(0xFF3F4A16);
  static const Color lightCream = Color(0xFFF4F5E9);

  // ============================================================
  // Database
  // ============================================================

  final DatabaseHelper databaseHelper = DatabaseHelper();

  List<Map<String, dynamic>> contacts = [];

  bool isLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  // ============================================================
  // LOAD CONTACTS
  // ============================================================

  Future<void> loadContacts() async {
    try {
      final List<Map<String, dynamic>> savedContacts =
      await databaseHelper.getEmergencyContacts();

      if (!mounted) {
        return;
      }

      setState(() {
        contacts = savedContacts;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: darkOlive,
          content: Text(
            'Could not load emergency contacts: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ADD CONTACT
  // ============================================================

  Future<void> addContact() async {
    final String? result = await showContactDialog();

    if (result == null) {
      return;
    }

    await loadContacts();
  }

  // ============================================================
  // EDIT CONTACT
  // ============================================================

  Future<void> editContact(
      Map<String, dynamic> contact,
      ) async {
    final int id = contact['id'] as int;

    final String currentName =
    contact['name'] as String;

    final String currentPhone =
    contact['phone_number'] as String;

    final bool? updated =
    await showEditContactDialog(
      id: id,
      currentName: currentName,
      currentPhone: currentPhone,
    );

    if (updated == true) {
      await loadContacts();
    }
  }

  // ============================================================
  // DELETE CONTACT
  // ============================================================

  Future<void> deleteContact(
      Map<String, dynamic> contact,
      ) async {
    final int id = contact['id'] as int;

    final String name =
    contact['name'] as String;

    final bool? confirmed =
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return _buildGlassDialog(
          title: 'Delete Contact?',
          icon: Icons.delete_outline,
          content: Text(
            'Are you sure you want to remove $name '
                'from your emergency contacts?',
            style: TextStyle(
              color: darkOlive.withOpacity(0.78),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: oliveDrab,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFB94A48),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await databaseHelper.deleteEmergencyContact(id);

      await loadContacts();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: darkOlive,
          content: const Text(
            'Emergency contact removed.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: darkOlive,
          content: Text(
            'Could not delete contact: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ADD CONTACT DIALOG
  // ============================================================

  Future<String?> showContactDialog() async {
    final TextEditingController nameController =
    TextEditingController();

    final TextEditingController phoneController =
    TextEditingController();

    final GlobalKey<FormState> formKey =
    GlobalKey<FormState>();

    final bool? saved =
    await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _buildGlassDialog(
          title: 'Add Emergency Contact',
          icon: Icons.person_add_alt_1,
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGlassTextField(
                  controller: nameController,
                  label: 'Name',
                  icon: Icons.person_outline,
                  textCapitalization:
                  TextCapitalization.words,
                  validator: (String? value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter a name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                _buildGlassTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType:
                  TextInputType.phone,
                  validator: (String? value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter a phone number';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: oliveDrab,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: oliveDrab,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                if (!formKey.currentState!
                    .validate()) {
                  return;
                }

                try {
                  await databaseHelper
                      .insertEmergencyContact(
                    name:
                    nameController.text.trim(),
                    phoneNumber:
                    phoneController.text.trim(),
                  );

                  if (!dialogContext.mounted) {
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                } catch (e) {
                  if (!dialogContext.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(
                    SnackBar(
                      backgroundColor: darkOlive,
                      content: Text(
                        'Could not save contact: $e',
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      return 'saved';
    }

    return null;
  }

  // ============================================================
  // EDIT CONTACT DIALOG
  // ============================================================

  Future<bool?> showEditContactDialog({
    required int id,
    required String currentName,
    required String currentPhone,
  }) async {
    final TextEditingController nameController =
    TextEditingController(
      text: currentName,
    );

    final TextEditingController phoneController =
    TextEditingController(
      text: currentPhone,
    );

    final GlobalKey<FormState> formKey =
    GlobalKey<FormState>();

    final bool? updated =
    await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _buildGlassDialog(
          title: 'Edit Emergency Contact',
          icon: Icons.edit_outlined,
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGlassTextField(
                  controller: nameController,
                  label: 'Name',
                  icon: Icons.person_outline,
                  textCapitalization:
                  TextCapitalization.words,
                  validator: (String? value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter a name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                _buildGlassTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType:
                  TextInputType.phone,
                  validator: (String? value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter a phone number';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: oliveDrab,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: oliveDrab,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                if (!formKey.currentState!
                    .validate()) {
                  return;
                }

                try {
                  await databaseHelper
                      .updateEmergencyContact(
                    id: id,
                    name:
                    nameController.text.trim(),
                    phoneNumber:
                    phoneController.text.trim(),
                  );

                  if (!dialogContext.mounted) {
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                } catch (e) {
                  if (!dialogContext.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(
                    SnackBar(
                      backgroundColor: darkOlive,
                      content: Text(
                        'Could not update contact: $e',
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    return updated;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      backgroundColor: darkOlive,

      appBar: _buildAppBar(),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF808000),
              Color(0xFF6B8E23),
              Color(0xFF556B2F),
              Color(0xFF3F4A16),
            ],
          ),
        ),

        child: SafeArea(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
              : contacts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
            onRefresh: loadContacts,
            color: oliveDrab,
            backgroundColor: lightCream,
            child: ListView.builder(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                100,
              ),
              physics:
              const AlwaysScrollableScrollPhysics(),
              itemCount: contacts.length,
              itemBuilder:
                  (
                  BuildContext context,
                  int index,
                  ) {
                final Map<String, dynamic>
                contact =
                contacts[index];

                return _buildContactCard(
                  contact,
                );
              },
            ),
          ),
        ),
      ),

      floatingActionButton:
      _buildGlassFloatingButton(),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor:
      Colors.white.withOpacity(0.08),
      elevation: 0,

      title: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                Colors.white.withOpacity(0.25),
              ),
            ),
            child: const Icon(
              Icons.contact_emergency_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            'Emergency Contacts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),

      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }

  // ============================================================
  // GLASS DIALOG
  // ============================================================

  Widget _buildGlassDialog({
    required String title,
    required IconData icon,
    required Widget content,
    required List<Widget> actions,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
      const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: Container(
            padding:
            const EdgeInsets.fromLTRB(
              22,
              22,
              22,
              14,
            ),
            decoration: BoxDecoration(
              color: lightCream.withOpacity(0.94),
              borderRadius:
              BorderRadius.circular(28),
              border: Border.all(
                color:
                Colors.white.withOpacity(0.80),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withOpacity(0.18),
                  blurRadius: 30,
                  offset:
                  const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: oliveDrab
                            .withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: oliveDrab,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: darkOlive,
                          fontSize: 19,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                content,

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.end,
                  children: actions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GLASS TEXT FIELD
  // ============================================================

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(
        color: darkOlive,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,

        labelStyle: TextStyle(
          color: darkOlive.withOpacity(0.65),
        ),

        prefixIcon: Icon(
          icon,
          color: oliveDrab,
        ),

        filled: true,

        fillColor:
        Colors.white.withOpacity(0.55),

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide(
            color:
            oliveDrab.withOpacity(0.20),
          ),
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide(
            color:
            oliveDrab.withOpacity(0.20),
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: oliveDrab,
            width: 1.5,
          ),
        ),

        errorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFB94A48),
          ),
        ),

        focusedErrorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFB94A48),
            width: 1.5,
          ),
        ),
      ),

      validator: validator,
    );
  }

  // ============================================================
  // GLASS FLOATING ACTION BUTTON
  // ============================================================

  Widget _buildGlassFloatingButton() {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: addContact,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color:
                Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                  Colors.white.withOpacity(0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black.withOpacity(0.18),
                    blurRadius: 15,
                    offset:
                    const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_add_alt_1,
                color: Colors.white,
                size: 27,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 30,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            // --------------------------------------------------
            // GLASS ICON
            // --------------------------------------------------

            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 12,
                  sigmaY: 12,
                ),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white
                          .withOpacity(0.28),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .contact_emergency_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'No Emergency Contacts',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Add someone you trust so Persona '
                  'can contact them during an emergency.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                Colors.white.withOpacity(0.76),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            // --------------------------------------------------
            // ADD BUTTON
            // --------------------------------------------------

            ClipRRect(
              borderRadius:
              BorderRadius.circular(17),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ),
                child: ElevatedButton.icon(
                  onPressed: addContact,
                  icon: const Icon(
                    Icons.person_add_alt_1,
                  ),
                  label: const Text(
                    'Add Emergency Contact',
                  ),
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.white
                        .withOpacity(0.90),
                    foregroundColor: darkOlive,
                    elevation: 0,
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONTACT CARD
  // ============================================================

  Widget _buildContactCard(
      Map<String, dynamic> contact,
      ) {
    final String name =
    contact['name'] as String;

    final String phone =
    contact['phone_number'] as String;

    return Container(
      margin:
      const EdgeInsets.only(bottom: 15),

      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(24),

        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),

          child: Container(
            padding:
            const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.17),

              borderRadius:
              BorderRadius.circular(24),

              border: Border.all(
                color: Colors.white
                    .withOpacity(0.27),
                width: 1,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.10),
                  blurRadius: 18,
                  offset:
                  const Offset(0, 7),
                ),
              ],
            ),

            child: Row(
              children: [
                // ------------------------------------------------
                // AVATAR
                // ------------------------------------------------

                Container(
                  height: 57,
                  width: 57,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.90),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white
                          .withOpacity(0.50),
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: oliveDrab,
                    size: 29,
                  ),
                ),

                const SizedBox(width: 14),

                // ------------------------------------------------
                // CONTACT INFORMATION
                // ------------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 15,
                            color: Colors.white
                                .withOpacity(0.75),
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              phone,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white
                                    .withOpacity(0.72),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ------------------------------------------------
                // EDIT BUTTON
                // ------------------------------------------------

                _buildCardActionButton(
                  icon: Icons.edit_outlined,
                  onTap: () {
                    editContact(contact);
                  },
                ),

                const SizedBox(width: 5),

                // ------------------------------------------------
                // DELETE BUTTON
                // ------------------------------------------------

                _buildCardActionButton(
                  icon: Icons.delete_outline,
                  iconColor:
                  const Color(0xFFE9A09D),
                  onTap: () {
                    deleteContact(contact);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CARD ACTION BUTTON
  // ============================================================

  Widget _buildCardActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ClipOval(
      child: Material(
        color:
        Colors.white.withOpacity(0.10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.15),
              ),
            ),
            child: Icon(
              icon,
              color: iconColor ??
                  Colors.white,
              size: 19,
            ),
          ),
        ),
      ),
    );
  }
}