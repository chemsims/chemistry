//
// Reactions App
//

import ReactionsCore

extension FeedbackSettings {
    static var reactionsRate: FeedbackSettings {
        FeedbackSettings(
            toAddress: "cogsci7@gmail.com",
            subject: "Reactions Rate Feedback"
        )
    }
}

extension ShareSettings {
    static var reactionsRate: ShareSettings {
        ShareSettings(
            appStoreUrl: "https://apps.apple.com/us/app/reaction-rate-stem/id1531309001",
            appName: "Reactions Rate"
        )
    }
}
