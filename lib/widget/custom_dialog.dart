import 'package:flutter/material.dart';

/// A premium, highly customizable, and reusable dialog widget matching the app's design language.
class CustomDialogWidget extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? icon;
  final Widget? content;
  final List<Widget>? actions;
  final Color titleColor;
  final Color messageColor;
  final Color backgroundColor;

  const CustomDialogWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.content,
    this.actions,
    this.titleColor = const Color(0xFF1B3C21),
    this.messageColor = const Color(0xFF5A7561),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(height: 16),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: content ?? (message != null && message!.isNotEmpty
          ? Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: messageColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.5,
              ),
            )
          : null),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      actions: actions,
    );
  }
}

/// A static helper class to easily trigger various types of polished dialogs with scale transitions.
class CustomDialog {
  // Theme Colors
  static const Color primaryColor = Color(0xFF0D631B);
  static const Color textDark = Color(0xFF1B3C21);
  static const Color textMid = Color(0xFF5A7561);
  static const Color textLight = Color(0xFF6B8B72);
  static const Color errorColor = Colors.redAccent;
  static const Color warningColor = Colors.amber;
  static const Color infoColor = Colors.blueAccent;

  /// Internal helper to present dialogs with a premium scale-and-fade animation.
  static Future<T?> _showBaseDialog<T>({
    required BuildContext context,
    required Widget dialog,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => dialog,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curveValue = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: curveValue,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Shows a beautiful success modal dialog.
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return _showBaseDialog<void>(
      context: context,
      dialog: CustomDialogWidget(
        title: title,
        message: message,
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: primaryColor,
            size: 40,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                if (onPressed != null) onPressed();
              },
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a beautiful error modal dialog.
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return _showBaseDialog<void>(
      context: context,
      dialog: CustomDialogWidget(
        title: title,
        message: message,
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFFFEBEE),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: errorColor,
            size: 40,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                if (onPressed != null) onPressed();
              },
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog (Yes / No).
  /// Returns `true` if confirm pressed, `false` if cancel pressed, or `null` if dismissed.
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String cancelLabel = 'Batal',
    String confirmLabel = 'Ya, Lanjutkan',
    bool isDestructive = false,
  }) {
    return _showBaseDialog<bool>(
      context: context,
      dialog: CustomDialogWidget(
        title: title,
        message: message,
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDestructive ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDestructive ? Icons.delete_outline_rounded : Icons.help_outline_rounded,
            color: isDestructive ? errorColor : primaryColor,
            size: 40,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textLight,
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    cancelLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDestructive ? errorColor : primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    confirmLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shows a completely custom dialog with any layout, such as forms/inputs.
  static Future<T?> showCustom<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return _showBaseDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      dialog: CustomDialogWidget(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }
}
