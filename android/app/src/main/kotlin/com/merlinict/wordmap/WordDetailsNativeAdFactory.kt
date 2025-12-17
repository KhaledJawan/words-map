package com.merlinict.wordmap

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import com.google.android.gms.ads.nativead.AdChoicesView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class WordDetailsNativeAdFactory(private val context: Context) :
  GoogleMobileAdsPlugin.NativeAdFactory {
  override fun createNativeAd(
    nativeAd: NativeAd,
    customOptions: MutableMap<String, Any>?
  ): NativeAdView {
    val adView = LayoutInflater.from(context)
      .inflate(R.layout.word_details_native_ad, null) as NativeAdView

    val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
    val bodyView = adView.findViewById<TextView>(R.id.ad_body)
    val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)
    val ctaView = adView.findViewById<Button>(R.id.ad_call_to_action)
    val adChoicesView = adView.findViewById<AdChoicesView>(R.id.ad_choices)

    adView.headlineView = headlineView
    adView.bodyView = bodyView
    adView.iconView = iconView
    adView.callToActionView = ctaView
    adView.adChoicesView = adChoicesView

    headlineView.text = nativeAd.headline

    val body = nativeAd.body
    if (body.isNullOrBlank()) {
      bodyView.visibility = View.GONE
    } else {
      bodyView.visibility = View.VISIBLE
      bodyView.text = body
    }

    val iconDrawable = nativeAd.icon?.drawable
    if (iconDrawable == null) {
      iconView.visibility = View.GONE
    } else {
      iconView.visibility = View.VISIBLE
      iconView.setImageDrawable(iconDrawable)
    }

    val cta = nativeAd.callToAction
    if (cta.isNullOrBlank()) {
      ctaView.visibility = View.GONE
    } else {
      ctaView.visibility = View.VISIBLE
      ctaView.text = cta
    }

    adView.setNativeAd(nativeAd)
    return adView
  }
}
