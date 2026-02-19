import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralized ad policy for store-compliance switches.
class AdPolicy {
  /// Keep this `true` for Google Play Families / mixed-audience compliance.
  /// To disable at build time: `--dart-define=FAMILIES_SAFE_MODE=false`
  static const bool familiesSafeMode = bool.fromEnvironment(
    'FAMILIES_SAFE_MODE',
    defaultValue: true,
  );

  /// Rewarded flow is disabled in Families-safe mode.
  static bool get enableRewardedFlow => !familiesSafeMode;

  /// Native ads can stay on in Families-safe mode when request config is child-safe.
  static const bool enableNativeAds = true;

  static RequestConfiguration requestConfiguration() {
    if (!familiesSafeMode) {
      return RequestConfiguration();
    }
    return RequestConfiguration(
      maxAdContentRating: MaxAdContentRating.g,
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
    );
  }
}
