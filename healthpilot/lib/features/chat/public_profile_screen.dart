import 'dart:io';

import 'package:flutter/material.dart';
import 'package:healthpilot/core/widgets/user_avatar.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/profile/profile_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  XFile? _pickedImage;
  late final TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    _aboutController = TextEditingController(text: publicProfileAboutMe);
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() => _pickedImage = image);
    }
  }

  void _updateProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Public profile updated.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: double.infinity,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Components.customeAppBar(
              Icons.arrow_back, 'Public Profile', context),
        ),
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add some info you want people to see',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),

                  // ── profile picture ─────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // avatar
                            SizedBox(
                              height: size.height * 0.12,
                              width: size.height * 0.12,
                              child: ClipOval(
                                child: _pickedImage != null
                                    ? Image.file(
                                        File(_pickedImage!.path),
                                        fit: BoxFit.cover,
                                      )
                                    : UserAvatar(
                                        url: context
                                            .watch<ProfileProvider>()
                                            .profile
                                            .profilePictureUrl,
                                        radius: size.height * 0.06,
                                      ),
                              ),
                            ),
                            // edit badge — bottom-right of circle
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: cs.surface,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    LineIcons.edit,
                                    size: 13,
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.015),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Text(
                            'Upload Image',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // ── about me ────────────────────────────────────────────────
                  Text(
                    'About me',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: size.height * 0.008),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.04),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.circular(size.width * 0.02)),
                      gradient: LinearGradient(
                        colors: [
                          cs.primary.withValues(alpha: 0.10),
                          cs.surface.withValues(alpha: 0.25),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: cs.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _aboutController,
                      minLines: 6,
                      maxLines: 12,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        letterSpacing: -0.17,
                        fontSize: 13,
                        color: cs.onSurface,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Tell people about yourself…',
                        hintStyle: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.06),

                  // ── update button ────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * 0.03),
                        ),
                      ),
                      child: Text(
                        'Update Public Profile',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Components {
  static Widget customeAppBar(
      IconData icon, String title, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: size.height * 0.1,
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: size.height * 0.06,
              width: size.height * 0.06,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: cs.onPrimaryContainer),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  static Widget headerText(String text) {
    return Builder(
      builder: (context) => SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}
