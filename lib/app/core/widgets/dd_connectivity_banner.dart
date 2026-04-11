import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:done_drop/core/services/connectivity_service.dart';
import 'package:done_drop/core/theme/theme.dart';

/// A slim banner shown at the top of screens when offline.
/// Put this inside your Scaffold's body as the first child.
class DDConnectivityBanner extends StatelessWidget {
  const DDConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final svc = Get.find<ConnectivityService>();
    return Column(
      children: [
        Obx(() {
          if (svc.isOnline.value) return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: AppColors.error.withValues(alpha: 0.9),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'No internet connection',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          );
        }),
        Expanded(child: child),
      ],
    );
  }
}
