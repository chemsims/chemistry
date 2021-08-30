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
    
    public let count: Int
    public let date: Date

    /// Returns a new instance with a count of 1 set to the current date.
    public static func firstPrompt(dateProvider: DateProvider = CurrentDateProvider()) -> PromptInfo {
        PromptInfo(count: 1, lastPrompt: dateProvider.now())
    }

    /// Returns an instance with an incremented count set to the current date.
    public func increment(dateProvider: DateProvider = CurrentDateProvider()) -> PromptInfo {
        PromptInfo(count: count + 1, lastPrompt: dateProvider.now())
    }
}
