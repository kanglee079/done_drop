import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:done_drop/core/models/feed_delivery.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/services/local_cache_service.dart';

/// Local hydration + image prefetch for the Buddy feed.
///
/// This keeps the first pages warm so the vertical feed feels immediate even
/// before the remote stream finishes hydrating.
class BuddyFeedCacheService {
  BuddyFeedCacheService._();

  static final BuddyFeedCacheService instance = BuddyFeedCacheService._();

  final Set<String> _warmedUrls = <String>{};

  List<Moment> loadCachedMoments(String userId) {
    final cachedDeliveries = LocalCacheService.instance.loadCachedFeedDeliveries(
      userId,
    );
    return cachedDeliveries
        .map(FeedDelivery.fromFirestore)
        .map(Moment.fromFeedDelivery)
        .toList(growable: false);
  }

  Future<void> cacheDeliveries(
    String userId,
    List<FeedDelivery> deliveries,
  ) async {
    await LocalCacheService.instance.cacheFeedDeliveries(
      userId,
      deliveries.map((delivery) => delivery.toFirestore()).toList(),
    );
  }

  Future<void> precacheWindow({
    required BuildContext context,
    required List<Moment> moments,
    required int centerIndex,
    int lookAhead = 2,
    int lookBehind = 1,
  }) async {
    if (moments.isEmpty) return;

    final start = (centerIndex - lookBehind).clamp(0, moments.length - 1);
    final end = (centerIndex + lookAhead).clamp(0, moments.length - 1);
    final futures = <Future<void>>[];

    for (var index = start; index <= end; index++) {
      final moment = moments[index];
      // ignore: use_build_context_synchronously
      futures.add(_precacheIfNeeded(context, moment.media.bestThumbnailUrl));
      if ((moment.ownerAvatarUrl ?? '').isNotEmpty) {
        // ignore: use_build_context_synchronously
        futures.add(_precacheIfNeeded(context, moment.ownerAvatarUrl!));
      }
    }
    await Future.wait(futures);
  }

  void clearWarmRegistry() {
    _warmedUrls.clear();
  }

  Future<void> _precacheIfNeeded(BuildContext context, String url) {
    if (url.isEmpty || !_warmedUrls.add(url)) {
      return Future.value();
    }
    return precacheImage(CachedNetworkImageProvider(url), context).catchError((
      _,
    ) {
      _warmedUrls.remove(url);
    });
  }
}
