import 'package:flutter/material.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/l10n/l10n.dart';

/// A confirmation dialog that requires the user to type a specific phrase
/// before the action can be confirmed.
class ConfirmTypingDialog extends StatefulWidget {
  const ConfirmTypingDialog({
    super.key,
    required this.title,
    required this.message,
    required this.hint,
    required this.placeholder,
    required this.expectedPhrase,
    this.destructive = false,
  });

  final String title;
  final String message;
  final String hint;
  final String placeholder;
  final String expectedPhrase;
  final bool destructive;

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required String hint,
    required String placeholder,
    required String expectedPhrase,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmTypingDialog(
        title: title,
        message: message,
        hint: hint,
        placeholder: placeholder,
        expectedPhrase: expectedPhrase,
        destructive: destructive,
      ),
    );
  }

  @override
  State<ConfirmTypingDialog> createState() => _ConfirmTypingDialogState();
}

class _ConfirmTypingDialogState extends State<ConfirmTypingDialog> {
  final _controller = TextEditingController();
  bool _isValid = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
  }

  void _validateInput() {
    final input = _controller.text.trim().toLowerCase();
    final expected = widget.expectedPhrase.toLowerCase();
    setState(() {
      if (_controller.text.isEmpty) {
        _isValid = false;
        _errorText = null;
      } else if (input == expected) {
        _isValid = true;
        _errorText = null;
      } else {
        _isValid = false;
        _errorText = currentL10n.confirmFieldMismatch;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primaryColor = widget.destructive ? AppColors.error : AppColors.primary;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        widget.title,
        style: TextStyle(
          color: widget.destructive ? AppColors.error : AppColors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message,
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.hint,
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              filled: true,
              fillColor: AppColors.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: AppSizes.borderRadiusMd,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSizes.borderRadiusMd,
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              errorText: _errorText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            l10n.cancelAction,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ),
        TextButton(
          onPressed: _isValid ? () => Navigator.of(context).pop(true) : null,
          child: Text(
            l10n.verifyAction,
            style: TextStyle(
              color: _isValid ? primaryColor : AppColors.outline,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
