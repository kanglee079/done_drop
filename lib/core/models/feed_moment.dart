import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:done_drop/core/constants/app_constants.dart';
import 'package:done_drop/core/models/moment.dart';
import 'package:done_drop/core/models/feed_delivery.dart';

/// Extended moment with owner profile data for feed display.
class FeedMoment {
  const FeedMoment({
    required this.moment,
    required this.ownerName,
    required this.ownerAvatarUrl,
  });

  final Moment moment;
  final String ownerName;
  final String? ownerAvatarUrl;
}
