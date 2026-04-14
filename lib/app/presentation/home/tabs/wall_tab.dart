part of '../home_screen.dart';

// ── WALL TAB ─────────────────────────────────────────────────────────────────

class _WallTab extends StatelessWidget {
  const _WallTab();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final uid = authController.firebaseUser?.uid;

    if (uid == null) return _buildEmptyState();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
      child: _WallContent(userId: uid),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space24),
      child: DDEmptyState(
        title: 'Memory Wall',
        description: 'Your proof moments appear here.',
        icon: Icons.auto_awesome_mosaic_outlined,
        actionLabel: 'Capture your first moment',
        onAction: () => Get.toNamed(AppRoutes.capture),
      ),
    ),
  );
}

class _WallContent extends StatelessWidget {
  const _WallContent({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    final momentRepo = Get.find<MomentRepository>();

    return StreamBuilder<List<Moment>>(
      stream: momentRepo.watchPersonalMoments(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _WallShimmer();
        }

        final moments = snapshot.data ?? [];
        if (moments.isEmpty) return _WallEmptyState();

        return GridView.builder(
          padding: const EdgeInsets.only(top: AppSizes.space8, bottom: AppSizes.space8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSizes.space8,
            crossAxisSpacing: AppSizes.space8,
            childAspectRatio: 1,
          ),
          itemCount: moments.length,
          itemBuilder: (_, i) => _WallMomentTile(moment: moments[i]),
        );
      },
    );
  }
}

class _WallShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: AppSizes.space8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: AppSizes.space8, crossAxisSpacing: AppSizes.space8,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSizes.borderRadiusMd,
        )),
      ),
    );
  }
}

class _WallEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.auto_awesome_mosaic_outlined, size: 80, color: AppColors.outlineVariant),
        const SizedBox(height: AppSizes.space24),
        const Text(
          'No moments yet',
          style: TextStyle(fontFamily: AppTypography.serifFamily, fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your proof moments appear here.',
          style: TextStyle(fontFamily: AppTypography.serifFamily, fontSize: 16, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.space24),
        DDPrimaryButton(
          label: 'Capture your first moment',
          icon: Icons.camera_alt,
          onPressed: () => Get.toNamed(AppRoutes.capture),
          isExpanded: false,
        ),
      ],
    ),
  );
}

class _WallMomentTile extends StatelessWidget {
  const _WallMomentTile({required this.moment});
  final Moment moment;

  @override
  Widget build(BuildContext context) {
    return DDMomentTile(
      imageUrl: moment.media.thumbnail.downloadUrl,
      caption: moment.caption.isNotEmpty ? moment.caption : null,
      category: moment.category,
      onLongPress: () async {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Moment'),
            content: const Text('Are you sure you want to delete this moment?'),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          Get.find<MomentRepository>().deleteMoment(moment.id);
        }
      },
    );
  }
}
