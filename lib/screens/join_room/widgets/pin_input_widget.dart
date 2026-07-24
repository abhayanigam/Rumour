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
    // Listen for external controller changes (e.g. _createRandomRoom)
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTap() => _focusNode.requestFocus();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final value = widget.controller.text;

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Hidden TextField (captures keyboard input) ─────
            SizedBox(
              height: 0.1,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                maxLength: widget.length,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9]')),
                  UpperCaseTextFormatter(),
                ],
                style: const TextStyle(
                  fontSize: 0.1,
                  color: Colors.transparent,
                ),
                cursorColor: Colors.transparent,
                cursorWidth: 0,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) {
                  setState(() {});
                  widget.onChanged?.call(v);
                  if (v.length == widget.length) {
                    widget.onCompleted(v);
                  }
                },
              ),
            ),

            // ── Visual slots ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(widget.length, (i) {
                final hasChar = i < value.length;
                final char = hasChar ? value[i] : null;
                return _Slot(
                  char: char,
                  isDark: isDark,
                  index: i,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  final String? char;
  final bool isDark;
  final int index;

  const _Slot({
    required this.char,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final hasChar = char != null;
    return AnimatedSwitcher(
      duration: 180.ms,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Text(
        hasChar ? char! : '—',
        key: ValueKey(hasChar ? '${char}_$index' : 'empty_$index'),
        style: GoogleFonts.inter(
          color: hasChar
              ? (isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight)
              : (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
          fontSize: 22,
          fontWeight: hasChar ? FontWeight.w700 : FontWeight.w400,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
