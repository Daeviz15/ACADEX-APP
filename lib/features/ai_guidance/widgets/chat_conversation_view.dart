import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../providers/ai_chat_provider.dart';

class ChatConversationView extends StatefulWidget {
  final ChatSession session;
  final bool isLoading;
  final Function(String) onSendMessage;

  const ChatConversationView({
    super.key,
    required this.session,
    required this.isLoading,
    required this.onSendMessage,
  });

  @override
  State<ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  AnimationController? _loadingController;
  bool _isVisible = true;
  bool _isLoadingLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(vsync: this);
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    final visibleFraction = info.visibleFraction;

    if (visibleFraction > 0.5 && !_isVisible) {
      setState(() => _isVisible = true);
      if (_isLoadingLoaded) _loadingController?.repeat();
    } else if (visibleFraction <= 0.5 && _isVisible) {
      setState(() => _isVisible = false);
      _loadingController?.stop();
    }
  }

  @override
  void dispose() {
    _loadingController?.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.removeListener(_onFocusChange);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll to bottom when new messages arrive
    if (widget.session.messages.length != oldWidget.session.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _focusNode.hasFocus || _controller.text.isNotEmpty;

    return VisibilityDetector(
      key: const Key('ai_conversation_view'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              physics: const BouncingScrollPhysics(),
              itemCount: widget.session.messages.length + (widget.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Typing indicator
                if (index == widget.session.messages.length && widget.isLoading) {
                  return _buildTypingIndicator(isActive);
                }
                final msg = widget.session.messages[index];
                return _buildMessageBubble(msg, isActive);
              },
            ),
          ),

          // Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isActive) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // AI avatar
            Container(
              margin: const EdgeInsets.only(right: 10, top: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Lottie.asset(
                'assets/lottie/load.json',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                animate: false,
              ),
            ),
          ],

          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: AppColors.surfaceHighlight.withOpacity(0.3),
                        width: 1,
                      ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontFamily: AppTextStyles.hostGrotesk,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isUser ? Colors.black : AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),

          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10, top: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Lottie.asset(
              'assets/lottie/load.json',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              animate: false,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: AppColors.surfaceHighlight.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: SizedBox(
              height: 80,
              width: 120,
              child: Lottie.asset(
                'assets/lottie/load.json',
                controller: _loadingController,
                onLoaded: (composition) {
                  _loadingController?.duration = composition.duration;
                  _isLoadingLoaded = true;
                  if (_isVisible) {
                    _loadingController?.repeat();
                  }
                },
                fit: BoxFit.contain,
                addRepaintBoundary: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final isActive = _focusNode.hasFocus || _controller.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.surfaceHighlight.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
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
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(
                  fontFamily: AppTextStyles.urbanist,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(
                    fontFamily: AppTextStyles.urbanist,
                    fontSize: 15,
                    color: AppColors.textHint.withOpacity(0.5),
                  ),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
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
                      animate: isActive && _isVisible,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.arrow_upward_rounded,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary.withOpacity(0.5),
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
    );
  }
}
