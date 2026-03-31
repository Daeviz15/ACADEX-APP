import 'dart:async';
import 'package:acadex/core/widgets/acadex_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

class ServiceRequestSheet extends ConsumerStatefulWidget {
  final String serviceId;
  final String serviceTitle;
  final List<String> placeholders;
  final IconData icon;

  const ServiceRequestSheet({
    super.key,
    required this.serviceId,
    required this.serviceTitle,
    required this.placeholders,
    required this.icon,
  });

  /// Helper to show this bottom sheet
  static void show(
    BuildContext context, {
    required String serviceId,
    required String serviceTitle,
    required List<String> placeholders,
    required IconData icon,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceRequestSheet(
        serviceId: serviceId,
        serviceTitle: serviceTitle,
        placeholders: placeholders,
        icon: icon,
      ),
    );
  }

  @override
  ConsumerState<ServiceRequestSheet> createState() => _ServiceRequestSheetState();
}

class _ServiceRequestSheetState extends ConsumerState<ServiceRequestSheet> {
  final _descriptionController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showError = false;
  bool _isPriority = false;
  bool _isSubmitting = false;

  // TODO: Replace with real support number
  final String _supportNumber = '+2347044114163'; 

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      if (!mounted) return;
      setState(() => _showError = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showError = false);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide details for your request')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final message = '''
📋 *New Service Request*
👤 *Student:* David
🎓 *Service:* ${widget.serviceTitle.replaceAll('\n', ' ')}
⚡ *Priority:* ${_isPriority ? 'High (Priority)' : 'Standard'}

📝 *Details:* 
$description
''';

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse('https://wa.me/$_supportNumber?text=$encodedMessage');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        if (mounted) Navigator.pop(context);
      } else {
        _showFallbackError();
      }
    } catch (e) {
      _showFallbackError();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showFallbackError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Could not open WhatsApp. Do you have it installed?'),
        action: SnackBarAction(
          label: 'Email Instead',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;
    final primaryColor = isDark ? c.primary : const Color(0xFF00664F);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: bottomInset > 0 ? bottomInset + 24 : 48,
      ),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.surfaceHighlight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Service',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 20,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.serviceTitle.replaceAll('\n', ' '),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                color: c.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Read-only Student Info Field
          _buildFieldLabel('Name', c),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.surfaceHighlight.withValues(alpha: 0.5)),
            ),
            child: Text(
              'David',
              style: AppTextStyles.bodyLarge.copyWith(
                color: c.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Description Field
          _buildFieldLabel('Details', c),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Stack(
              children: [
                TextField(
                  controller: _descriptionController,
                  focusNode: _focusNode,
                  maxLines: 4,
                  minLines: 3,
                  style: AppTextStyles.bodyLarge.copyWith(color: c.textPrimary),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  onChanged: (val) {
                    if (_showError && val.trim().isNotEmpty) {
                      setState(() => _showError = false);
                    } else {
                      setState(() {});
                    }
                  },
                ),
                if (_descriptionController.text.isEmpty)
                  Positioned(
                    left: 16,
                    top: 16,
                    right: 16,
                    child: IgnorePointer(
                      child: _TypewriterHint(
                        hints: widget.placeholders,
                        isFocused: _focusNode.hasFocus,
                      ),
                    ),
                  ),
              ],
            ),
          ).animate(
            target: _showError ? 1 : 0,
          ).shake(
            hz: 6,
            curve: Curves.easeInOutCubic,
            duration: const Duration(milliseconds: 400),
          ),

          const SizedBox(height: 24),

          // Priority Toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High Priority',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Need this done urgently?',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isPriority,
                onChanged: (val) => setState(() => _isPriority = val),
                activeThumbColor: c.background,
                activeTrackColor: primaryColor,
                inactiveTrackColor: c.surfaceHighlight,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
                  child: _isSubmitting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: AcadexLoader(size: 24),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Send Request',
                          style: AppTextStyles.button,
                        ),
                      ],
                    ),
            ),
          ).animate().slideY(begin: 0.5, end: 0, duration: 400.ms, curve: Curves.easeOutCubic).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, AppColorScheme c) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: c.textSecondary,
        ),
      ),
    );
  }
}

/// A widget that cycles through a list of strings with a typewriter effect.
class _TypewriterHint extends StatefulWidget {
  final List<String> hints;
  final bool isFocused;

  const _TypewriterHint({
    required this.hints,
    required this.isFocused,
  });

  @override
  State<_TypewriterHint> createState() => _TypewriterHintState();
}

class _TypewriterHintState extends State<_TypewriterHint> {
  int _currentHintIndex = 0;
  int _charIndex = 0;
  String _displayedHint = '';
  bool _isTyping = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.hints.isNotEmpty) {
      _startTypewriter();
    }
  }

  @override
  void didUpdateWidget(covariant _TypewriterHint oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTypewriter() {
    _timer?.cancel();
    _charIndex = 0;
    _displayedHint = '';
    _isTyping = true;

    _timer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final currentHint = widget.hints[_currentHintIndex];

      if (_isTyping) {
        if (_charIndex < currentHint.length) {
          setState(() {
            _charIndex++;
            _displayedHint = currentHint.substring(0, _charIndex);
          });
        } else {
          timer.cancel();
          _timer = Timer(const Duration(milliseconds: 2500), () {
            if (mounted) {
              _isTyping = false;
              _startErasing();
            }
          });
        }
      }
    });
  }

  void _startErasing() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_charIndex > 0) {
        setState(() {
          _charIndex--;
          _displayedHint = widget.hints[_currentHintIndex].substring(0, _charIndex);
        });
      } else {
        timer.cancel();
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % widget.hints.length;
        });
        _timer = Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            _startTypewriter();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hints.isEmpty) return const SizedBox.shrink();
    final c = context.colors;
    
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodyLarge.copyWith(
          color: widget.isFocused 
            ? c.textHint 
            : c.textHint.withValues(alpha: 0.7),
        ),
        children: [
          TextSpan(text: _displayedHint),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: widget.isFocused && _isTyping
                ? _CursorAnimate()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CursorAnimate extends StatefulWidget {
  @override
  State<_CursorAnimate> createState() => _CursorAnimateState();
}

class _CursorAnimateState extends State<_CursorAnimate>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 18,
        color: isDark ? c.primary : const Color(0xFF00664F),
        margin: const EdgeInsets.only(left: 2, bottom: 2),
      ),
    );
  }
}
