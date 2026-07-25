import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startNavigationTimer();
  }

  void _startNavigationTimer() {
    _timer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        context.go('/join');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.splashBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.splashBackground,
        body: SafeArea(
          child: Stack(
            children: [
              // ── Center Content: Logo & App Title ─────────────────────
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Logo with entrance animation
                    Image.asset(
                      'assets/rumour.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 24),

                    // App Name
                    Text(
                      'Rumour',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'Anonymous Room Chat',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        ),
                  ],
                ),
              ),

              // ── Bottom Progress Indicator ────────────────────────────
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Center(
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 400.ms),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
