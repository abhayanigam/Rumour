import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final bool showSender;
  final int index;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.showSender,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 64 : 16,
        right: isMine ? 16 : 64,
        top: showSender ? 12 : 2,
        bottom: 2,
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // ── Sender label ────────────────────────────────────
          if (showSender)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                isMine ? 'You' : '@${message.senderName.replaceAll(' ', '')}',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ),

          // ── Bubble ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMine
                  ? AppColors.sentBubble
                  : (isDark
                      ? AppColors.receivedBubbleDark
                      : AppColors.receivedBubbleLight),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMine
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: isMine
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Message text
                Flexible(
                  child: Text(
                    message.text,
                    style: GoogleFonts.inter(
                      color: isMine
                          ? AppColors.sentBubbleText
                          : AppColors.textPrimary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Timestamp
                Text(
                  timeStr,
                  style: GoogleFonts.inter(
                    color: isMine
                        ? AppColors.sentBubbleText.withValues(alpha: 0.6)
                        : AppColors.textSecondary(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms, delay: (index * 30).clamp(0, 200).ms)
        .slideX(
          begin: isMine ? 0.1 : -0.1,
          end: 0,
          duration: 250.ms,
          curve: Curves.easeOut,
        );
  }
}
