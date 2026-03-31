import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:acadex/core/widgets/acadex_skeleton.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import 'package:acadex/features/auth/providers/auth_provider.dart';
import 'package:acadex/features/main_shell/providers/shell_provider.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  const ProfileHeader({super.key});

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  final ImagePicker _picker = ImagePicker();
  String? _localImagePath; // For "Optimistic UI" preview
  String? _localBannerPath; // For "Optimistic UI" banner preview

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Safe default
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  /// The professional industry-standard flow: Pick -> Crop (3:1) -> Upload
  Future<void> _pickAndUploadBanner() async {
    final c = context.colors;
    
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Banner',
            toolbarColor: c.surface,
            toolbarWidgetColor: c.textPrimary,
            activeControlsWidgetColor: c.primary,
            aspectRatioPresets: [CropAspectRatioPreset.ratio3x2],
            initAspectRatio: CropAspectRatioPreset.ratio3x2,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Edit Banner',
            aspectRatioPresets: [CropAspectRatioPreset.ratio3x2],
          ),
        ],
      );

      if (croppedFile == null) return;

      setState(() {
        _localBannerPath = croppedFile.path;
      });

      await ref.read(authNotifierProvider.notifier).updateBanner(croppedFile.path);
      
    } catch (e) {
      debugPrint("BANNER FLOW ERROR: $e");
    }
  }

  /// The professional industry-standard flow: Pick -> Crop (1:1) -> Upload
  Future<void> _pickAndUploadAvatar() async {
    final c = context.colors;
    
    try {
      // 1. Pick Image
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile == null) return;

      // 2. Crop Image (Circular)
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Profile Picture',
            toolbarColor: c.surface,
            toolbarWidgetColor: c.textPrimary,
            activeControlsWidgetColor: c.primary,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Edit Profile Picture',
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );

      if (croppedFile == null) return;

      // 3. Optimistic UI: Update preview immediately
      setState(() {
        _localImagePath = croppedFile.path;
      });

      // 4. Background Upload
      await ref.read(authNotifierProvider.notifier).updateAvatar(croppedFile.path);
      
    } catch (e) {
      debugPrint("AVATAR FLOW ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;
    final user = ref.watch(authNotifierProvider).value;
    final fullName = user?.name ?? 'Student';

    // Replay animation each time user navigates to the Profile tab
    ref.listen<int>(shellProvider, (prev, next) {
      if (next == 4 && _lottieController.duration != null) {
        _lottieController.reset();
        _lottieController.forward();
      }
    });

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // ── Modern Cinematic Banner ──
        ClipPath(
          clipper: _WaveBannerClipper(),
          child: Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        c.surfaceHighlight.withValues(alpha: 0.4),
                        c.surfaceHighlight.withValues(alpha: 0.15),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF007D5F),
                        Color(0xFF00553D),
                      ],
                    ),
            ),
            child: Stack(
              children: [
                // The actual Banner Image
                Positioned.fill(
                  child: _localBannerPath != null
                      ? Image.file(
                          File(_localBannerPath!),
                          fit: BoxFit.cover,
                        )
                      : user?.fullBannerUrl != null
                          ? CachedNetworkImage(
                              imageUrl: user!.fullBannerUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => AcadexSkeleton(
                                height: 260,
                                width: double.infinity,
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
                // Smooth Dark Aesthetic Overlay (Top and Bottom Weighted)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5), // Top shadow for status bar
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.9), // Deep, intentional bottom fade
                        ],
                        stops: const [0.0, 0.3, 0.82], // Starts fading deep early to beat the wave clip
                      ),
                    ),
                  ),
                ),
                // Decorative Overlay Content (Lottie) - Only shown if NO banner exists
                if (_localBannerPath == null && user?.fullBannerUrl == null)
                  Center(
                    child: Opacity(
                      opacity: 0.15,
                      child: Lottie.asset(
                        'assets/lottie/profilepic.json',
                        controller: _lottieController,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                // Edit banner button
                SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: IconButton(
                        onPressed: _pickAndUploadBanner,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Profile Details ──
        Column(
          children: [
            const SizedBox(height: 170),
            // Profile Avatar with Add button overlay
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? c.background : const Color(0xFF00664F),
                    border: Border.all(
                      color: isDark
                          ? c.primary.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.4),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: _localImagePath != null
                        ? Image.file(
                            File(_localImagePath!),
                            fit: BoxFit.cover,
                          )
                        : user?.fullAvatarUrl != null
                            ? CachedNetworkImage(
                                imageUrl: user!.fullAvatarUrl!,
                                fit: BoxFit.cover,
                                fadeInDuration: const Duration(milliseconds: 500),
                                placeholder: (context, url) => AcadexSkeleton.circle(size: 100),
                                errorWidget: (context, url, error) => Lottie.asset(
                                  'assets/lottie/profilepic.json',
                                  controller: _lottieController,
                                  onLoaded: (composition) {
                                    _lottieController.duration = composition.duration;
                                    _lottieController.forward();
                                  },
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Lottie.asset(
                                'assets/lottie/profilepic.json',
                                controller: _lottieController,
                                onLoaded: (composition) {
                                  _lottieController.duration = composition.duration;
                                  _lottieController.forward();
                                },
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                // The sleek '+' button overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickAndUploadAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: c.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? c.surface : Colors.white,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              fullName,
              style: AppTextStyles.h2.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isDark ? c.textPrimary : Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom clipper that draws a sleek wave at the bottom of the banner
class _WaveBannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.72);

    path.cubicTo(
      size.width * 0.25, size.height * 0.95,
      size.width * 0.45, size.height * 0.55,
      size.width * 0.7, size.height * 0.78,
    );

    path.cubicTo(
      size.width * 0.85, size.height * 0.90,
      size.width * 0.95, size.height * 0.65,
      size.width, size.height * 0.70,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
