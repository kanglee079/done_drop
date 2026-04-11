import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/theme.dart';

/// DoneDrop Avatar — User profile image
class DDAvatar extends StatelessWidget {
  const DDAvatar({
    super.key,
    this.imageUrl,
    this.size = AppSizes.avatarMd,
    this.onTap,
    this.showBorder = false,
  });

  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: Colors.white, width: 2)
            : null,
        color: AppColors.surfaceContainerHigh,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _placeholder(),
                errorWidget: (context, url, error) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
    return onTap != null
        ? GestureDetector(onTap: onTap, child: avatar)
        : avatar;
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: Icon(
        Icons.person,
        color: AppColors.outline,
        size: size * 0.5,
      ),
    );
  }
}

/// DoneDrop Member Stack — overlapping avatars for circle members
class DDMemberStack extends StatelessWidget {
  const DDMemberStack({
    super.key,
    required this.avatars,
    this.maxVisible = 4,
    this.avatarSize = 40,
    this.onMoreTap,
  });

  final List<String?> avatars;
  final int maxVisible;
  final double avatarSize;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final visible = avatars.take(maxVisible).toList();
    final remaining = avatars.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < visible.length; i++)
          Transform.translate(
            offset: Offset(-i * (avatarSize * 0.4), 0),
            child: DDAvatar(
              imageUrl: visible[i],
              size: avatarSize,
              showBorder: true,
            ),
          ),
        if (remaining > 0)
          Transform.translate(
            offset: Offset(-visible.length * (avatarSize * 0.4), 0),
            child: GestureDetector(
              onTap: onMoreTap,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryContainer,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSecondaryContainer,
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
