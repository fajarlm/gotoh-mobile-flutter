import 'package:flutter/material.dart';

/// A premium, highly customizable bottom sheet layout that handles keyboard/screen resize padding automatically.
class CustomBottomSheetWidget extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool showCloseButton;
  final Color titleColor;
  final Color backgroundColor;

  const CustomBottomSheetWidget({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.showCloseButton = true,
    this.titleColor = const Color(0xFF1B3C21),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24, // Prevents keyboard overlap
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle/indicator
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              if (showCloseButton)
                IconButton(
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF6B8B72),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: content,
            ),
          ),
          // Action Buttons
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...actions!,
          ],
        ],
      ),
    );
  }
}

/// A static helper class to display a modal bottom sheet.
class CustomBottomSheet {
  /// Opens a polished modal bottom sheet.
  /// If [isScrollControlled] is true (default), the sheet can occupy more than half the screen height,
  /// which is recommended for forms or scrolls.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool showCloseButton = true,
    bool isScrollControlled = true,
    bool isDismissible = true,
    Color backgroundColor = Colors.white,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) {
        return CustomBottomSheetWidget(
          title: title,
          content: content,
          actions: actions,
          showCloseButton: showCloseButton,
          backgroundColor: backgroundColor,
        );
      },
    );
  }
}
