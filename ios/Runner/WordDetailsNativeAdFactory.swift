import Foundation
import GoogleMobileAds
import google_mobile_ads
import UIKit

final class WordDetailsNativeAdFactory: NSObject, FLTNativeAdFactory {
  func createNativeAd(
    _ nativeAd: GADNativeAd,
    customOptions: [AnyHashable: Any]?
  ) -> GADNativeAdView {
    let nativeAdView = GADNativeAdView()
    nativeAdView.layer.cornerRadius = 14
    nativeAdView.clipsToBounds = true
    nativeAdView.backgroundColor = .white

    let iconView = UIImageView()
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconView.contentMode = .scaleAspectFill
    iconView.clipsToBounds = true
    iconView.layer.cornerRadius = 8

    let headlineLabel = UILabel()
    headlineLabel.translatesAutoresizingMaskIntoConstraints = false
    headlineLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    headlineLabel.textColor = .black
    headlineLabel.numberOfLines = 1

    let bodyLabel = UILabel()
    bodyLabel.translatesAutoresizingMaskIntoConstraints = false
    bodyLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    bodyLabel.textColor = UIColor(white: 0.4, alpha: 1)
    bodyLabel.numberOfLines = 2

    let ctaButton = UIButton(type: .system)
    ctaButton.translatesAutoresizingMaskIntoConstraints = false
    ctaButton.backgroundColor = .black
    ctaButton.setTitleColor(.white, for: .normal)
    ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    ctaButton.layer.cornerRadius = 8
    ctaButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12)
    ctaButton.setContentCompressionResistancePriority(.required, for: .horizontal)

    let textStack = UIStackView(arrangedSubviews: [headlineLabel, bodyLabel])
    textStack.translatesAutoresizingMaskIntoConstraints = false
    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = 2

    let row = UIStackView(arrangedSubviews: [iconView, textStack, ctaButton])
    row.translatesAutoresizingMaskIntoConstraints = false
    row.axis = .horizontal
    row.alignment = .center
    row.spacing = 10

    let adChoicesView = GADAdChoicesView()
    adChoicesView.translatesAutoresizingMaskIntoConstraints = false

    nativeAdView.addSubview(row)
    nativeAdView.addSubview(adChoicesView)

    NSLayoutConstraint.activate([
      row.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 10),
      row.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -10),
      row.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 10),
      row.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -10),

      adChoicesView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 6),
      adChoicesView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -6),

      iconView.widthAnchor.constraint(equalToConstant: 40),
      iconView.heightAnchor.constraint(equalToConstant: 40),

      ctaButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
    ])

    nativeAdView.headlineView = headlineLabel
    nativeAdView.bodyView = bodyLabel
    nativeAdView.iconView = iconView
    nativeAdView.callToActionView = ctaButton
    nativeAdView.adChoicesView = adChoicesView

    headlineLabel.text = nativeAd.headline

    if let body = nativeAd.body, !body.isEmpty {
      bodyLabel.text = body
      bodyLabel.isHidden = false
    } else {
      bodyLabel.isHidden = true
    }

    if let icon = nativeAd.icon?.image {
      iconView.image = icon
      iconView.isHidden = false
    } else {
      iconView.isHidden = true
    }

    if let cta = nativeAd.callToAction, !cta.isEmpty {
      ctaButton.setTitle(cta, for: .normal)
      ctaButton.isHidden = false
    } else {
      ctaButton.isHidden = true
    }

    nativeAdView.nativeAd = nativeAd
    return nativeAdView
  }
}
