import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// A segmented PIN-style input widget.
/// Renders N character slots (dashes when empty) inside a single
/// dark rounded-rect container, matching the Figma design.
class PinInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const PinInputWidget({
    super.key,
    required this.controller,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _focusNode.addListener(_rebuild);
    // Open keyboard immediately on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focusNode.removeListener(_rebuild);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final value = widget.controller.text;
    final activeIndex = value.length; // slot currently being typed into

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Transparent TextField fills the entire container ────────────
          // Positioned.fill → full tap area.
          // Opacity(0) → invisible but still fully functional for hit-testing
          // and keyboard input. IgnorePointer on the Row above lets taps
          // fall through to this TextField.
          Positioned.fill(
            child: Opacity(
              opacity: 0.0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                maxLength: widget.length,
                autofocus: true,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  UpperCaseTextFormatter(),
                ],
                style: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 16,
                ),
                cursorColor: Colors.transparent,
                cursorWidth: 0,
                // Suppress ALL border variants so the theme's green line
                // never shows on the outer container
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  counterText: '',
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) {
                  widget.onChanged?.call(v);
                  if (v.length == widget.length) {
                    widget.onCompleted(v);
                  }
                },
              ),
            ),
          ),

          // ── Visual PIN slots ────────────────────────────────────────────
          // IgnorePointer lets taps pass through to the TextField below.
          IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(widget.length, (i) {
                final hasChar = i < value.length;
                final char = hasChar ? value[i] : null;
                // Active = the next empty slot while field has focus
                final isActive = _focusNode.hasFocus &&
                    i == activeIndex &&
                    i < widget.length;
                return _Slot(
                  char: char,
                  isDark: isDark,
                  isActive: isActive,
                  index: i,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slot widget ─────────────────────────────────────────────────────────────

class _Slot extends StatelessWidget {
  final String? char;
  final bool isDark;
  final bool isActive;
  final int index;

  const _Slot({
    required this.char,
    required this.isDark,
    required this.isActive,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final hasChar = char != null;

    // Filled → primary text | Active → lime accent | Inactive → secondary grey
    final Color color;
    if (hasChar) {
      color = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    } else if (isActive) {
      color = AppColors.accent;
    } else {
      color = isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight;
    }

    return AnimatedSwitcher(
      duration: 180.ms,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Text(
        hasChar ? char! : '—',
        key: ValueKey(
          hasChar
              ? 'filled_${char}_$index'
              : isActive
                  ? 'active_$index'
                  : 'empty_$index',
        ),
        style: GoogleFonts.inter(
          color: color,
          fontSize: 22,
          fontWeight: hasChar ? FontWeight.w700 : FontWeight.w400,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

// ── Formatter ───────────────────────────────────────────────────────────────

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
