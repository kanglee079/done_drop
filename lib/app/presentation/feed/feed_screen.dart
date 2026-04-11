import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// DoneDrop Feed Screen — Circle feed view
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: AppColors.surfaceContainerHigh,
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
        ),
        title: Text(
          'DoneDrop',
          style: TextStyle(
            fontFamily: 'Newsreader',
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: DDEmptyState(
          title: 'Circle Feed',
          description: 'Shared moments from your inner circle will appear here.',
          icon: Icons.group_outlined,
        ),
      ),
    );
  }
}
