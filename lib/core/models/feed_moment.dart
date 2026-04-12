import 'package:done_drop/core/models/moment.dart';

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
