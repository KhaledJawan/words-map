import Shared
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // A tap on the daily reminder opens the app on the daily words.
        ReminderTapsKt.installReminderTaps()
        return true
    }
}
