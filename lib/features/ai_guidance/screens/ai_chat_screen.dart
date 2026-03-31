import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../providers/ai_onboarding_provider.dart';
import '../providers/ai_chat_provider.dart';
import '../widgets/chat_history_sidebar.dart';
import '../widgets/chat_conversation_view.dart';
import 'ai_onboarding_screen.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;
    final hasCompletedOnboarding = ref.watch(aiOnboardingProvider);

    if (!hasCompletedOnboarding) {
      return AiOnboardingScreen(onComplete: () {});
    }

    final chatState = ref.watch(aiChatProvider);
    final hasActiveSession = chatState.activeSessionId != null;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? c.background : const Color(0xFF00664F),
      drawer: const ChatHistorySidebar(),
      appBar: _buildAppBar(hasActiveSession, c),
      body: Stack(
        children: [
          
          hasActiveSession
              ? _buildConversationView(chatState)
              : _ChatHomeView(
                  onSend: (text) {
                    ref.read(aiChatProvider.notifier).sendMessage(text);
                  },
                ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool hasActiveSession, AppColorScheme c) {
    final isDark = context.isDarkMode;
    return AppBar(
      backgroundColor: isDark ? c.background.withValues(alpha: 0.8) : const Color(0xFF00664F).withValues(alpha: 0.9),
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leadingWidth: 72,
      leading: Center(
        child: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? c.surface.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: isDark ? Border.all(
                color: c.surfaceHighlight.withValues(alpha: 0.5),
                width: 1,
              ) : null,
            ),
            child: Icon(
              Icons.menu_rounded,
              color: isDark ? c.textPrimary : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      title: hasActiveSession
          ? Text(
              'AI Chat',
              style: TextStyle(
                fontFamily: AppTextStyles.montserrat,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? c.textPrimary : Colors.white,
              ),
            )
          : null,
      centerTitle: true,
      actions: [
        if (hasActiveSession)
          IconButton(
            onPressed: () {
              ref.read(aiChatProvider.notifier).startNewSession();
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? c.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add_rounded,
                color: isDark ? c.primary : Colors.white,
                size: 20,
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildConversationView(AiChatState chatState) {
    final session = chatState.activeSession;
    if (session == null) return const SizedBox.shrink();

    return ChatConversationView(
      session: session,
      isLoading: chatState.isLoading,
      onSendMessage: (text) {
        ref.read(aiChatProvider.notifier).sendMessage(text);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ChatHomeView extends StatefulWidget {
  final Function(String) onSend;
  const _ChatHomeView({required this.onSend});

  @override
  State<_ChatHomeView> createState() => _ChatHomeViewState();
}

class _ChatHomeViewState extends State<_ChatHomeView>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Resource Management State
  AnimationController? _lottieController;
  bool _isVisible = true;
  bool _isLottieLoaded = false;

  // Typewriter state
  static const List<String> _hints = [
    'Explain quantum physics simply...',
    'Help me prepare for my biology exam...',
    'Solve this calculus problem step by step...',
    'Summarize chapter 4 of my textbook...',
    'Write a study plan for finals week...',
    'Analyze this past exam question...',
    'Debug my Python sorting function...',
    'Explain the difference between mitosis and meiosis...',
    'Help me outline my research paper...',
    'Quiz me on organic chemistry reactions...',
  ];

  int _currentHintIndex = 0;
  String _displayedHint = '';
  int _charIndex = 0;
  bool _isTyping = true;
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _focusNode.addListener(_onFocusChange);
    _inputController.addListener(_onTextChange);
    _startTypewriter();
  }

  @override
  void dispose() {
    _lottieController?.dispose();
    _typewriterTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _inputController.removeListener(_onTextChange);
    _inputController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _onTextChange() {
    setState(() {});
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    final visibleFraction = info.visibleFraction;

    if (visibleFraction > 0.5 && !_isVisible) {
      setState(() => _isVisible = true);
      if (_isTyping) {
        _startTypewriter();
      } else {
        _startErasing();
      }
      if (_isLottieLoaded) _lottieController?.repeat();
    } else if (visibleFraction <= 0.5 && _isVisible) {
      setState(() => _isVisible = false);
      _typewriterTimer?.cancel();
      _lottieController?.stop();
    }
  }

  void _startTypewriter() {
    if (_displayedHint.isEmpty) {
      _charIndex = 0;
      _isTyping = true;
    }

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 60), (
      timer,
    ) {
      if (!mounted || !_isVisible) {
        timer.cancel();
        return;
      }

      final currentHint = _hints[_currentHintIndex];

      if (_isTyping) {
        if (_charIndex < currentHint.length) {
          setState(() {
            _charIndex++;
            _displayedHint = currentHint.substring(0, _charIndex);
          });
        } else {
          timer.cancel();
          _typewriterTimer = Timer(const Duration(milliseconds: 2000), () {
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
    _typewriterTimer?.cancel();
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 30), (
      timer,
    ) {
      if (!mounted || !_isVisible) {
        timer.cancel();
        return;
      }

      if (_charIndex > 0) {
        setState(() {
          _charIndex--;
          _displayedHint = _hints[_currentHintIndex].substring(0, _charIndex);
        });
      } else {
        timer.cancel();
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % _hints.length;
        });
        _typewriterTimer = Timer(const Duration(milliseconds: 300), () {
          if (mounted && _isVisible) {
            _startTypewriter();
          }
        });
      }
    });
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _inputController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;
    final isActive = _focusNode.hasFocus || _inputController.text.isNotEmpty;

    return VisibilityDetector(
      key: const Key('ai_chat_home_view'),
      onVisibilityChanged: _onVisibilityChanged,
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Bot Lottie hero with soft background glow
            Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox.shrink(),
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Lottie.asset(
                    'assets/lottie/ai/bot.json',
                    controller: _lottieController,
                    onLoaded: (composition) {
                      _lottieController?.duration = composition.duration;
                      _isLottieLoaded = true;
                      if (_isVisible) {
                        _lottieController?.repeat();
                      }
                    },
                    fit: BoxFit.contain,
                    frameRate: FrameRate.max,
                    addRepaintBoundary: true,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 16),

            // Tagline — Typewriter text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                height: 60,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: AppTextStyles.outfit,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? c.textPrimary : Colors.white,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(text: _displayedHint),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: _TypewriterCursor(),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

            const Spacer(flex: 2),

            // Input box
            Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isDark
                          ? c.surface.withValues(alpha: isActive ? 0.95 : 0.7)
                          : Colors.white.withValues(alpha: isActive ? 0.95 : 0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isActive
                            ? (isDark ? c.primary : Colors.white)
                            : (isDark ? c.surfaceHighlight.withValues(alpha: 0.5) : Colors.white),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? (isActive ? c.primary : Colors.black).withValues(alpha: isActive ? 0.12 : 0.03)
                              : Colors.black.withValues(alpha: isActive ? 0.1 : 0.03),
                          blurRadius: 24,
                          spreadRadius: -4,
                          offset: Offset(0, isActive ? 8 : 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            focusNode: _focusNode,
                            style: TextStyle(
                              fontFamily: AppTextStyles.urbanist,
                              fontSize: 15,
                              color: c.textPrimary,
                            ),
                            maxLines: 1,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              hintText: 'Ask me anything...',
                              hintStyle: TextStyle(
                                fontFamily: AppTextStyles.urbanist,
                                fontSize: 15,
                                color: isDark ? c.textHint.withValues(alpha: 0.5) : c.textSecondary.withValues(alpha: 0.8),
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                            ),
                            onSubmitted: (_) => _handleSend(),
                          ),
                        ),
                        // Send Action — Fire Lottie
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: _handleSend,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? c.primary.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isActive
                                      ? c.primary.withValues(alpha: 0.3)
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Lottie.asset(
                                  'assets/lottie/ai/fire.json',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                  animate: isActive,
                                  delegates: LottieDelegates(
                                    values: [
                                      ValueDelegate.color(
                                        const ['**'],
                                        value: isActive ? c.primary : c.textHint.withValues(alpha: 0.5),
                                      ),
                                    ],
                                  ),
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.arrow_upward_rounded,
                                      color: isActive
                                          ? Colors.white
                                          : c.textSecondary.withValues(
                                              alpha: 0.5,
                                            ),
                                      size: 20,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Suggestion CTAs
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _suggestionChip(
                    Icons.school_rounded,
                    'Exam Prep',
                    'Help me prepare for my upcoming exam',
                    c,
                  ),
                  _suggestionChip(
                    Icons.help_outline_rounded,
                    'Quick Question',
                    'I have a general academic question',
                    c,
                  ),
                  _suggestionChip(
                    Icons.menu_book_rounded,
                    'Past Questions',
                    'Help me study past exam questions',
                    c,
                  ),
                  _suggestionChip(
                    Icons.code_rounded,
                    'Debug Code',
                    'I need help debugging my code',
                    c,
                  ),
                  _suggestionChip(
                    Icons.description_rounded,
                    'Assignment',
                    'Help me with my assignment',
                    c,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(IconData icon, String label, String prompt, AppColorScheme c) {
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => widget.onSend(prompt),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? c.surface.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? c.surfaceHighlight.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isDark ? c.primary : Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.urbanist,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? c.textPrimary : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Blinking cursor widget ─────────────────────────────────────────────────

class _TypewriterCursor extends StatefulWidget {
  @override
  State<_TypewriterCursor> createState() => _TypewriterCursorState();
}

class _TypewriterCursorState extends State<_TypewriterCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 22,
        margin: const EdgeInsets.only(left: 2, bottom: 2),
        decoration: BoxDecoration(
          color: context.isDarkMode ? c.primary : Colors.white,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
