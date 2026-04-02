import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/core/network/api_endpoints.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/core/widgets/acadex_loader.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import 'package:screen_protector/screen_protector.dart';
import '../data/models/past_question.dart';

class PqViewerScreen extends StatefulWidget {
  final PastQuestion question;

  const PqViewerScreen({super.key, required this.question});

  @override
  State<PqViewerScreen> createState() => _PqViewerScreenState();
}

class _PqViewerScreenState extends State<PqViewerScreen> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initScreenProtection();
  }

  Future<void> _initScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      debugPrint('Screen protection init failed: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _removeScreenProtection();
    super.dispose();
  }

  Future<void> _removeScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (e) {
      debugPrint('Screen protection remove failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.question.fileUrls.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.question.courseCode),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            'No images available for this question.',
            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black, // Dark background for viewing images
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.courseCode,
              style: AppTextStyles.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              '${widget.question.displayYear}${widget.question.semester != null ? ' • ${widget.question.semester} Semester' : ''}',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1} / ${widget.question.fileUrls.length}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.question.fileUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final imageUrl = widget.question.fileUrls[index];
          final fullUrl = imageUrl.startsWith('http')
              ? imageUrl
              : '${ApiEndpoints.baseHost}$imageUrl';

          return InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 1.0,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: fullUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => const AcadexLoader(size: 60),
                errorWidget: (context, url, error) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.broken_image_rounded,
                      size: 48,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load image.\nPlease check your connection.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
