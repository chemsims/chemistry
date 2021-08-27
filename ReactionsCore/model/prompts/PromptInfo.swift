//
// Reactions App
//

import Foundation

/// Records info to track when a user has been prompted about something
public struct PromptInfo: Codable {

    private init(count: Int, lastPrompt: Date) {
        self.count = count
        self.date = lastPrompt
    }
    
    let count: Int
    let date: Date

    /// Returns a new instance with a count of 1 set to the current date.
    static func firstPrompt(dateProvider: DateProvider = CurrentDateProvider()) -> PromptInfo {
        PromptInfo(count: 1, lastPrompt: dateProvider.now())
    }

    /// Returns an instance with an incremented count set to the current date.
    func increment(dateProvider: DateProvider = CurrentDateProvider()) -> PromptInfo {
        PromptInfo(count: count + 1, lastPrompt: dateProvider.now())
    }
}
