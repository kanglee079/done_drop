import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// DoneDrop Create Circle Screen
class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  final _nameController = TextEditingController();
  String _selectedType = 'close_friends';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: const Text('Create Circle'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CIRCLE NAME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.outline,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Sunday Collective',
                filled: true,
                fillColor: AppColors.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: AppSizes.borderRadiusMd,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.space24),
            const Text(
              'CIRCLE TYPE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.outline,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSizes.space12),
            Wrap(
              spacing: AppSizes.space8,
              children: [
                _TypeChip(
                  label: 'Partner',
                  icon: Icons.favorite,
                  isSelected: _selectedType == 'partner',
                  onTap: () => setState(() => _selectedType = 'partner'),
                ),
                _TypeChip(
                  label: 'Close Friends',
                  icon: Icons.groups,
                  isSelected: _selectedType == 'close_friends',
                  onTap: () => setState(() => _selectedType = 'close_friends'),
                ),
                _TypeChip(
                  label: 'Squad',
                  icon: Icons.celebration,
                  isSelected: _selectedType == 'squad',
                  onTap: () => setState(() => _selectedType = 'squad'),
                ),
              ],
            ),
            const Spacer(),
            DDPrimaryButton(
              label: 'Create Circle',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.space16,
          vertical: AppSizes.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryFixed : AppColors.surfaceContainerLow,
          borderRadius: AppSizes.borderRadiusFull,
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
