import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/theme/theme.dart';
import 'package:done_drop/core/models/moment.dart';

/// Skeleton UI for Month Memory Film
/// Plays back recent proofs in a story-like format.
class MemoryFilmScreen extends StatelessWidget {
  const MemoryFilmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real implementation this would fetch from a MemoryFilmController
    final List<Moment> moments = []; // mock

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Centered Image
            Center(
              child: Container(
                color: Colors.grey[900], // Background while loading
                child: moments.isEmpty
                    ? const Center(
                        child: Text(
                          'No proofs captured this month.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : Image.network(
                        moments.first.media.original.downloadUrl,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            
            // Story Progress Indicators
            Positioned(
              top: AppSizes.space16,
              left: AppSizes.space16,
              right: AppSizes.space16,
              child: Row(
                children: List.generate(
                  moments.length > 0 ? moments.length : 1,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 3,
                      decoration: BoxDecoration(
                        color: index == 0 ? Colors.white : Colors.white24,
                        borderRadius: AppSizes.borderRadiusFull,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top Bar
            Positioned(
              top: AppSizes.space32,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                child: Row(
                  children: [
                    const Text(
                      'This Month',
                      style: TextStyle(
                        fontFamily: AppTypography.serifFamily,
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
