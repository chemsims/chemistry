//
// Reactions App
//

import Foundation

/// Records info to track when a user has been prompted about something
struct PromptInfo: Codable {
    let count: Int
    let lastPrompt: Date

    static func firstPrompt() -> PromptInfo {
        PromptInfo(count: 1, lastPrompt: Date())
    }

    func incrementPrompt() -> PromptInfo {
        PromptInfo(count: count + 1, lastPrompt: Date())
    }
}
