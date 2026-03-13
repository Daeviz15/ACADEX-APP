import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  const ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    this.messages = const [],
  });

  ChatSession copyWith({
    String? title,
    List<ChatMessage>? messages,
  }) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      messages: messages ?? this.messages,
    );
  }
}

class AiChatState {
  final List<ChatSession> sessions;
  final String? activeSessionId;
  final bool isLoading;

  const AiChatState({
    this.sessions = const [],
    this.activeSessionId,
    this.isLoading = false,
  });

  ChatSession? get activeSession {
    if (activeSessionId == null) return null;
    try {
      return sessions.firstWhere((s) => s.id == activeSessionId);
    } catch (_) {
      return null;
    }
  }

  AiChatState copyWith({
    List<ChatSession>? sessions,
    String? activeSessionId,
    bool? isLoading,
    bool clearActiveSession = false,
  }) {
    return AiChatState(
      sessions: sessions ?? this.sessions,
      activeSessionId: clearActiveSession ? null : (activeSessionId ?? this.activeSessionId),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class AiChatNotifier extends StateNotifier<AiChatState> {
  AiChatNotifier() : super(AiChatState(
    sessions: [
      // Mock history for demo
      ChatSession(
        id: 'demo-1',
        title: 'Thesis Structure Tips',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        messages: [
          ChatMessage(
            id: 'm1',
            content: 'How do I structure my thesis on renewable energy?',
            isUser: true,
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          ChatMessage(
            id: 'm2',
            content: 'A strong thesis typically follows this structure:\n\n1. **Introduction** — State your research question\n2. **Literature Review** — Survey existing research\n3. **Methodology** — Explain your approach\n4. **Results** — Present findings\n5. **Discussion** — Analyze implications\n6. **Conclusion** — Summarize key takeaways',
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          ),
        ],
      ),
      ChatSession(
        id: 'demo-2',
        title: 'Python Sorting Algorithms',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ChatSession(
        id: 'demo-3',
        title: 'Photosynthesis Explained',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ],
  ));

  /// Start a brand new chat session
  void startNewSession() {
    state = state.copyWith(clearActiveSession: true);
  }

  /// Open an existing session from history
  void openSession(String sessionId) {
    state = state.copyWith(activeSessionId: sessionId);
  }

  /// Send a message (mock AI response for now)
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final userMsg = ChatMessage(
      id: 'msg-${now.millisecondsSinceEpoch}',
      content: text.trim(),
      isUser: true,
      timestamp: now,
    );

    // If no active session, create one
    if (state.activeSessionId == null) {
      final sessionId = 'session-${now.millisecondsSinceEpoch}';
      final newSession = ChatSession(
        id: sessionId,
        title: text.trim().length > 30 ? '${text.trim().substring(0, 30)}...' : text.trim(),
        createdAt: now,
        messages: [userMsg],
      );
      state = state.copyWith(
        sessions: [newSession, ...state.sessions],
        activeSessionId: sessionId,
        isLoading: true,
      );
    } else {
      // Append to existing session
      final updatedSessions = state.sessions.map((s) {
        if (s.id == state.activeSessionId) {
          return s.copyWith(messages: [...s.messages, userMsg]);
        }
        return s;
      }).toList();
      state = state.copyWith(sessions: updatedSessions, isLoading: true);
    }

    // Simulate AI response delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final aiMsg = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      content: _getMockResponse(text),
      isUser: false,
      timestamp: DateTime.now(),
    );

    final updatedSessions = state.sessions.map((s) {
      if (s.id == state.activeSessionId) {
        return s.copyWith(messages: [...s.messages, aiMsg]);
      }
      return s;
    }).toList();
    state = state.copyWith(sessions: updatedSessions, isLoading: false);
  }

  String _getMockResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('exam') || q.contains('study')) {
      return 'Great question! Here are some effective exam preparation strategies:\n\n📌 **Active Recall** — Test yourself instead of just re-reading\n📌 **Spaced Repetition** — Review material at increasing intervals\n📌 **Practice Papers** — Work through past questions under timed conditions\n📌 **Teach Someone** — Explaining concepts reinforces your understanding\n\nWould you like me to create a study plan for a specific subject?';
    } else if (q.contains('past question') || q.contains('pq')) {
      return 'I can help you study past questions effectively! Here\'s my approach:\n\n1. **Identify Patterns** — I\'ll analyze recurring topics across past papers\n2. **Explain Solutions** — Step-by-step breakdowns of each answer\n3. **Predict Topics** — Based on frequency analysis\n\nWhich course would you like to start with?';
    } else if (q.contains('code') || q.contains('programming')) {
      return 'I\'d love to help with your code! You can:\n\n💻 Share your code and I\'ll debug it\n💻 Ask me to explain any programming concept\n💻 Request code in any language\n\nWhat are you working on?';
    }
    return 'That\'s a great question! I\'m here to help you succeed academically. I can assist with assignments, explain concepts, help prepare for exams, and much more.\n\nCould you give me a bit more detail so I can provide the best guidance?';
  }

  /// Delete a session
  void deleteSession(String sessionId) {
    final updatedSessions = state.sessions.where((s) => s.id != sessionId).toList();
    state = state.copyWith(
      sessions: updatedSessions,
      clearActiveSession: state.activeSessionId == sessionId,
    );
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>(
  (ref) => AiChatNotifier(),
);
