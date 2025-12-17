import Flutter
import UIKit
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let nativeFactoryId = "wordDetailsFooter"
  private let wordDetailsNativeAdFactory = WordDetailsNativeAdFactory()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self,
      factoryId: nativeFactoryId,
      nativeAdFactory: wordDetailsNativeAdFactory
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    FLTGoogleMobileAdsPlugin.unregisterNativeAdFactory(self, factoryId: nativeFactoryId)
    super.applicationWillTerminate(application)
  }
}
