package com.merlinict.wordmap

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
  private val nativeFactoryId = "wordDetailsFooter"
  private var nativeAdFactory: WordDetailsNativeAdFactory? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    nativeAdFactory = WordDetailsNativeAdFactory(this)
    GoogleMobileAdsPlugin.registerNativeAdFactory(
      flutterEngine,
      nativeFactoryId,
      nativeAdFactory!!
    )
  }

  override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
    GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, nativeFactoryId)
    nativeAdFactory = null
    super.cleanUpFlutterEngine(flutterEngine)
  }
}
