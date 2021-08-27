//
// Reactions App
//

import Foundation

/// Records info to track when a user has been prompted about something
public struct PromptInfo: Codable {

    private init(count: Int, lastPrompt: Date) {
        self.count = count
        self.lastPrompt = lastPrompt
    }
    
    let count: Int
    let lastPrompt: Date

    /// Returns a new instance with a count of 1 set to the current date.
    static func firstPrompt() -> PromptInfo {
        PromptInfo(count: 1, lastPrompt: Date())
    }

    /// Returns an instance with an incremented count set to the current date.
    func increment() -> PromptInfo {
        PromptInfo(count: count + 1, lastPrompt: Date())
    }
}
