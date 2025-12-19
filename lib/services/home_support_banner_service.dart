class HomeSupportBannerService {
  static bool _shownThisSession = false;

  Future<bool> shouldShow() async {
    if (_shownThisSession) return false;
    return true;
  }

  Future<void> markShown() async {
    _shownThisSession = true;
  }
}
