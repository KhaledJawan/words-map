package dev.nefrin.wordsmap.platform

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.useContents
import platform.CoreGraphics.CGRectMake
import platform.UIKit.UIStatusBarStyle
import platform.UIKit.UIStatusBarStyleDarkContent
import platform.UIKit.UIStatusBarStyleLightContent
import platform.UIKit.UIViewAutoresizingFlexibleHeight
import platform.UIKit.UIViewAutoresizingFlexibleWidth
import platform.UIKit.UIViewController
import platform.UIKit.addChildViewController
import platform.UIKit.didMoveToParentViewController

/** Lets the shared screens pick the color of the status bar icons, as they do on Android. */
internal object StatusBar {
    var controller: StatusBarController? = null

    var lightIcons: Boolean = false
        set(value) {
            if (field == value) return
            field = value
            controller?.setNeedsStatusBarAppearanceUpdate()
        }
}

/**
 * Hosts the Compose screens. iOS asks the root view controller for the status bar style,
 * so it has to be this one and not the Compose controller inside it.
 */
@OptIn(ExperimentalForeignApi::class)
class StatusBarController(private val content: UIViewController) : UIViewController(nibName = null, bundle = null) {

    override fun viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(content)
        view.bounds.useContents { content.view.setFrame(CGRectMake(0.0, 0.0, size.width, size.height)) }
        content.view.autoresizingMask = UIViewAutoresizingFlexibleWidth or UIViewAutoresizingFlexibleHeight
        view.addSubview(content.view)
        content.didMoveToParentViewController(this)
    }

    override fun preferredStatusBarStyle(): UIStatusBarStyle =
        if (StatusBar.lightIcons) UIStatusBarStyleLightContent else UIStatusBarStyleDarkContent
}
