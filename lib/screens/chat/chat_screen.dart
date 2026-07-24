import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_identity_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/providers.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/date_separator.dart';
import 'widgets/message_input.dart';
import 'widgets/room_app_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomCode;

  const ChatScreen({super.key, required this.roomCode});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  late UserIdentityModel _identity;
  bool _identityLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_identityLoaded) {
      final storage = ref.read(identityStorageServiceProvider);
      final id = storage.getIdentity(widget.roomCode);
      _identity = id ??
          UserIdentityModel(
            userId: '',
            name: 'You',
            roomCode: widget.roomCode,
          );
      _identityLoaded = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // When near the top → load older messages
    if (_scrollController.hasClients &&
        _scrollController.position.pixels <= 150) {
      ref.read(chatProvider(widget.roomCode).notifier).loadMore();
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (animate) {
      _scrollController.animateTo(
        max,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(max);
    }
  }

  Future<void> _sendMessage(String text) async {
    await ref.read(chatProvider(widget.roomCode).notifier).sendMessage(
          senderId: _identity.userId,
          senderName: _identity.name,
          text: text,
        );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.roomCode));

    // Auto-scroll to bottom when new messages arrive
    ref.listen(chatProvider(widget.roomCode), (prev, next) {
      final prevCount = prev?.items.length ?? 0;
      final nextCount = next.items.length;
      if (nextCount > prevCount && !next.isLoadingMore) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: RoomAppBar(roomCode: widget.roomCode, identity: _identity),
      body: Column(
        children: [
          // ── Message list ──────────────────────────────────────
          Expanded(
            child: _buildMessageList(chatState),
          ),

          // ── Divider ───────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.divider(context),
          ),

          // ── Input bar ─────────────────────────────────────────
          MessageInput(onSend: _sendMessage),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.error!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.textSecondaryDark,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.textSecondaryDark,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No messages yet.\nBe the first to say something!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textSecondaryDark,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          if (_scrollController.position.pixels <= 150 &&
              notification.scrollDelta != null &&
              notification.scrollDelta! < 0) {
            ref.read(chatProvider(widget.roomCode).notifier).loadMore();
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        itemCount: state.items.length +
            (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Load-more spinner at top
          if (state.isLoadingMore && index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accent.withValues(alpha: 0.7)),
                  ),
                ),
              ),
            );
          }

          final itemIndex = state.isLoadingMore ? index - 1 : index;
          final item = state.items[itemIndex];

          return switch (item) {
            DateSeparatorItem(:final date) => DateSeparator(date: date),
            MessageItem(:final message) => () {
                final isMine = message.senderId == _identity.userId;
                // Show sender label if prev item is not the same sender
                bool showSender = true;
                if (itemIndex > 0) {
                  final prev = state.items[itemIndex - 1];
                  if (prev is MessageItem &&
                      prev.message.senderId == message.senderId) {
                    showSender = false;
                  }
                }
                return ChatBubble(
                  message: message,
                  isMine: isMine,
                  showSender: showSender,
                  index: itemIndex,
                );
              }(),
          };
        },
      ),
    );
  }
}
