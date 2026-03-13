import 'dart:async';
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
    final hasCompletedOnboarding = ref.watch(aiOnboardingProvider);

    if (!hasCompletedOnboarding) {
      return AiOnboardingScreen(onComplete: () {});
    }

    final chatState = ref.watch(aiChatProvider);
    final hasActiveSession = chatState.activeSessionId != null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const ChatHistorySidebar(),
      appBar: _buildAppBar(hasActiveSession),
      body: hasActiveSession
          ? _buildConversationView(chatState)
          : _ChatHomeView(
              onSend: (text) {
                ref.read(aiChatProvider.notifier).sendMessage(text);
              },
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool hasActiveSession) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceHighlight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.menu_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ),
      title: hasActiveSession
          ? Text(
              'AI Chat',
              style: const TextStyle(
                fontFamily: AppTextStyles.montserrat,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
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
    setState(() {}); // trigger rebuild for active border color
  }

  void _onTextChange() {
    setState(() {}); // trigger rebuild for active border color
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    final visibleFraction = info.visibleFraction;

    if (visibleFraction > 0.5 && !_isVisible) {
      setState(() => _isVisible = true);
      print('>>> AI Chat: Screen is VISIBLE. Resuming Typewriter and Lottie.');
      // Resume the typewriter loop from its current state
      if (_isTyping) {
        _startTypewriter();
      } else {
        _startErasing();
      }
      if (_isLottieLoaded) _lottieController?.repeat();
    } else if (visibleFraction <= 0.5 && _isVisible) {
      setState(() => _isVisible = false);
      print('>>> AI Chat: Screen is HIDDEN. Pausing Typewriter and Lottie.');
      _typewriterTimer?.cancel();
      _lottieController?.stop();
    }
  }

  void _startTypewriter() {
    // If we're resuming, don't reset strings if they already have data
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
        // Typing forward
        if (_charIndex < currentHint.length) {
          setState(() {
            _charIndex++;
            _displayedHint = currentHint.substring(0, _charIndex);
          });
        } else {
          // Pause at end of word
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
        // Move to next hint
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
    final isActive = _focusNode.hasFocus || _inputController.text.isNotEmpty;

    return VisibilityDetector(
      key: const Key('ai_chat_home_view'),
      onVisibilityChanged: _onVisibilityChanged,
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Bot Lottie hero
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
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 16),

            // Tagline — Typewriter text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                height:
                    60, // Fixed height to prevent shifting layout when text wraps
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: AppTextStyles.outfit,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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

            // Input box — active green border covers the entire box safely
            Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.surfaceHighlight.withOpacity(0.4),
                        width: isActive ? 1.5 : 1.0,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            focusNode: _focusNode,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.urbanist,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              hintText: 'Ask me anything...',
                              hintStyle: TextStyle(
                                fontFamily: AppTextStyles.urbanist,
                                fontSize: 15,
                                color: AppColors.textHint.withOpacity(0.5),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
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
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary.withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Lottie.asset(
                                  'assets/lottie/ai/fire.json',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                  animate: isActive,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.arrow_upward_rounded,
                                      color: isActive
                                          ? AppColors.primary
                                          : AppColors.textSecondary.withOpacity(
                                              0.5,
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
                  ),
                  _suggestionChip(
                    Icons.help_outline_rounded,
                    'Quick Question',
                    'I have a general academic question',
                  ),
                  _suggestionChip(
                    Icons.menu_book_rounded,
                    'Past Questions',
                    'Help me study past exam questions',
                  ),
                  _suggestionChip(
                    Icons.code_rounded,
                    'Debug Code',
                    'I need help debugging my code',
                  ),
                  _suggestionChip(
                    Icons.description_rounded,
                    'Assignment',
                    'Help me with my assignment',
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

  Widget _suggestionChip(IconData icon, String label, String prompt) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => widget.onSend(prompt),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.surfaceHighlight.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTextStyles.urbanist,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 22,
        margin: const EdgeInsets.only(left: 2, bottom: 2),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
