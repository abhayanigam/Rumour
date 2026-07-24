import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/room_provider.dart';
import 'widgets/pin_input_widget.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // Fire-and-forget: Riverpod handles async state, no manual _isSubmitting needed
  void _submit(String code) {
    if (code.trim().length < 4) return;
    ref.read(joinRoomProvider.notifier).joinRoom(code.toUpperCase());
  }

  void _createRandomRoom() {
    final code = (100000 + Random().nextInt(900000)).toString();
    _pinController.text = code;
    setState(() {}); // Refresh pin display
    ref.read(joinRoomProvider.notifier).joinRoom(code);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── KEY FIX: ref.watch keeps the provider alive for the full async op ──
    final joinState = ref.watch(joinRoomProvider);
    final isLoading = joinState.status == JoinStatus.loading;

    // ── Side-effects: navigate on success, show snackbar on error ──────────
    ref.listen<JoinRoomState>(joinRoomProvider, (prev, next) {
      if (next.status == JoinStatus.success) {
        final roomCode = next.identity!.roomCode;
        if (next.isNewIdentity) {
          context.pushNamed(
            'identity',
            pathParameters: {'roomCode': roomCode},
          );
        } else {
          context.pushNamed(
            'chat',
            pathParameters: {'roomCode': roomCode},
          );
        }
        // Reset after navigating so the provider is clean on back-navigation
        Future.microtask(() {
          if (mounted) ref.read(joinRoomProvider.notifier).reset();
        });
      } else if (next.status == JoinStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error ?? 'Something went wrong'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.read(joinRoomProvider.notifier).reset();
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 64),

                // ── Key icon ─────────────────────────────────────────
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.iconBg(context),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.vpn_key_rounded,
                      color: AppColors.accent,
                      size: 32,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 48),

                // ── Title ────────────────────────────────────────────
                Text(
                  'Join A Room',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary(context),
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 12),

                // ── Subtitle ─────────────────────────────────────────
                Text(
                  'Enter the code to join the anon chat room',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                )
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 36),

                // ── PIN input ────────────────────────────────────────
                PinInputWidget(
                  controller: _pinController,
                  length: 6,
                  onCompleted: _submit,
                  onChanged: (_) => setState(() {}),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 24),

                // ── Enter room button (appears after 4 chars) ────────
                AnimatedOpacity(
                  opacity:
                      _pinController.text.length >= 4 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedSlide(
                    offset: _pinController.text.length >= 4
                        ? Offset.zero
                        : const Offset(0, 0.3),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => _submit(_pinController.text),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          AppColors.sentBubbleText),
                                ),
                              )
                            : const Text('Enter Room'),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // ── Create room link ─────────────────────────────────
                TextButton(
                  onPressed: isLoading ? null : _createRandomRoom,
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have a code? ",
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary(context),
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Create a room',
                          style: GoogleFonts.inter(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
