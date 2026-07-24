import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/providers.dart';
import '../../../providers/theme_provider.dart';
import '../../../models/user_identity_model.dart';

/// Custom AppBar for the chat screen: back button, "Room #CODE" + member count,
/// and a right-side avatar circle showing user's initial.
class RoomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String roomCode;
  final UserIdentityModel identity;

  const RoomAppBar({
    super.key,
    required this.roomCode,
    required this.identity,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberCount =
        ref.watch(memberCountStreamProvider(roomCode));
    final textSec = AppColors.textSecondary(context);

    return AppBar(
      backgroundColor: AppColors.bg(context),
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => context.go('/'),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.iconBg(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textPrimary(context),
              size: 26,
            ),
          ),
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Room #$roomCode',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary(context),
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          memberCount.when(
            data: (count) => Text(
              '$count ${count == 1 ? 'member' : 'members'}',
              style: GoogleFonts.inter(
                color: textSec,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            loading: () => Text(
              '— members',
              style: GoogleFonts.inter(color: textSec, fontSize: 12),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => ref.read(themeProvider.notifier).toggle(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.iconBg(context),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  identity.initial,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
