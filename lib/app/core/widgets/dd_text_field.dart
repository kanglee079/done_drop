import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class DDTextField extends StatelessWidget {
  const DDTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.autocorrect,
    this.enableSuggestions,
    this.textCapitalization,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;
  final bool? autocorrect;
  final bool? enableSuggestions;
  final TextCapitalization? textCapitalization;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.space8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          autofocus: autofocus,
          autocorrect: autocorrect ?? true,
          enableSuggestions: enableSuggestions ?? true,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          autofillHints: autofillHints,
          style: const TextStyle(fontSize: 15, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 15,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.onSurfaceVariant, size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled
                ? AppColors.surfaceContainerLow
                : AppColors.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.space16,
              vertical: AppSizes.space16,
            ),
            border: OutlineInputBorder(
              borderRadius: AppSizes.borderRadiusMd,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSizes.borderRadiusMd,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSizes.borderRadiusMd,
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppSizes.borderRadiusMd,
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppSizes.borderRadiusMd,
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
