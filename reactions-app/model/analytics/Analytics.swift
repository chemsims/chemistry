//
// Reactions App
//

import FirebaseAnalytics
import ReactionsCore

struct AnalyticsClient: GoogleAnalyticsClient {
    func setAnalyticsCollectionEnabled(_ enabled: Bool) {
        Analytics.setAnalyticsCollectionEnabled(enabled)
    }

    func logEvent(_ name: String, parameters: [String : Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }

    var eventScreenView: String {
        AnalyticsEventScreenView
    }

    var parameterScreenName: String {
        AnalyticsParameterScreenName
    }
}
