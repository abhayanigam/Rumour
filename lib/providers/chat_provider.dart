import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';
import 'providers.dart';

// ── Chat items ────────────────────────────────────────────────────

/// A sealed union of items that can appear in the chat list.
sealed class ChatItem {
  const ChatItem();
}

class MessageItem extends ChatItem {
  final MessageModel message;
  const MessageItem(this.message);
}

class DateSeparatorItem extends ChatItem {
  final DateTime date;
  const DateSeparatorItem(this.date);
}

// ── State ─────────────────────────────────────────────────────────

class ChatState {
  final List<ChatItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ChatState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  ChatState copyWith({
    List<ChatItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) =>
      ChatState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: error ?? this.error,
      );
}

// ── Notifier ──────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<ChatState> {
  final FirestoreService _firestore;
  final String roomCode;

  // Pagination cursor (oldest loaded doc)
  QueryDocumentSnapshot<Map<String, dynamic>>? _oldestDoc;
  // Realtime subscription start point
  DateTime _latestTimestamp = DateTime.fromMillisecondsSinceEpoch(0);
  StreamSubscription<List<MessageModel>>? _realtimeSub;
  // In-memory ordered message list (chronological, oldest first)
  final List<MessageModel> _messages = [];

  ChatNotifier({
    required FirestoreService firestore,
    required this.roomCode,
  })  : _firestore = firestore,
        super(const ChatState(isLoading: true));

  Future<void> initialize() async {
    try {
      final docs = await _firestore.loadInitialDocs(roomCode, limit: 20);

      _messages.clear();
      if (docs.isNotEmpty) {
        // docs are newest→oldest; reverse for chronological order
        final reversed = docs.reversed.toList();
        _messages.addAll(reversed.map(MessageModel.fromDoc));
        _oldestDoc = docs.last; // oldest doc (last in desc-ordered list)
        _latestTimestamp = _messages.last.timestamp;
      }

      state = state.copyWith(
        isLoading: false,
        hasMore: docs.length >= 20,
        items: _buildItems(),
      );

      _subscribeToNewMessages();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load messages.',
      );
    }
  }

  void _subscribeToNewMessages() {
    _realtimeSub?.cancel();
    _realtimeSub = _firestore
        .watchNewMessages(roomCode, _latestTimestamp)
        .listen((newMsgs) {
      for (final msg in newMsgs) {
        if (!_messages.any((m) => m.id == msg.id)) {
          _messages.add(msg);
          if (msg.timestamp.isAfter(_latestTimestamp)) {
            _latestTimestamp = msg.timestamp;
          }
        }
      }
      state = state.copyWith(items: _buildItems());
    });
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || _oldestDoc == null) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final docs = await _firestore.loadMoreDocs(
        roomCode,
        _oldestDoc!,
        limit: 20,
      );

      if (docs.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
        return;
      }

      // docs are newest→oldest; reverse for chronological prepend
      final older = docs.reversed.map(MessageModel.fromDoc).toList();
      _messages.insertAll(0, older);
      _oldestDoc = docs.last;

      state = state.copyWith(
        isLoadingMore: false,
        hasMore: docs.length >= 20,
        items: _buildItems(),
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    final msg = MessageModel(
      id: '', // Firestore assigns ID
      senderId: senderId,
      senderName: senderName,
      text: text.trim(),
      timestamp: DateTime.now(), // Optimistic; server timestamp used in DB
    );
    await _firestore.sendMessage(roomCode, msg);
  }

  // ── Date-separator injection ──────────────────────────────────

  List<ChatItem> _buildItems() {
    final items = <ChatItem>[];
    DateTime? lastDate;

    for (final msg in _messages) {
      final day = _dateOnly(msg.timestamp);
      if (lastDate == null || !day.isAtSameMomentAs(lastDate)) {
        items.add(DateSeparatorItem(day));
        lastDate = day;
      }
      items.add(MessageItem(msg));
    }
    return items;
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  void dispose() {
    _realtimeSub?.cancel();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────

final chatProvider = StateNotifierProvider.autoDispose
    .family<ChatNotifier, ChatState, String>((ref, roomCode) {
  final notifier = ChatNotifier(
    firestore: ref.read(firestoreServiceProvider),
    roomCode: roomCode,
  );
  notifier.initialize();
  return notifier;
});
