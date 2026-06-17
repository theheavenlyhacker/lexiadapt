import 'package:flutter/foundation.dart';

class FederatedLearningClient {
  Future<void> syncIfConnected() async {
    debugPrint('[FL] Sync deferred: offline mode — no weight deltas transmitted');
  }
}
