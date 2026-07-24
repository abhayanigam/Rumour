import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/providers.dart';

class IdentityRevealScreen extends ConsumerWidget {
  final String roomCode;

  const IdentityRevealScreen({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity =
        ref.read(identityStorageServiceProvider).getIdentity(roomCode);
    final name = identity?.name ?? 'Anonymous';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              // ── Identity card ─────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 40),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // "For this room, you are"
                    Text(
                      'For this room, you are',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 16),

                    // ── Big name (lime green, bold) ────────────
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.accent,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -1,
                      ),
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),

                    const SizedBox(height: 20),

                    // ── Description ───────────────────────────
                    Text(
                      'This is your anonymous identifier, visible only\nto others in this room.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    )
                        .animate(delay: 350.ms)
                        .fadeIn(duration: 400.ms),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 28),

              // ── CTA button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pushReplacementNamed(
                    'chat',
                    pathParameters: {'roomCode': roomCode},
                  ),
                  child: const Text('Acknowledge and continue'),
                ),
              )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
