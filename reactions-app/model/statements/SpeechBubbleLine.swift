//
// Reactions App
//
  

import Foundation

/// Represents a single speech bubble line
///
/// Note that this does not mean the content will appear on a single
/// line. If the text is too long for the available width, it will wrap on to the next line.
/// However, each line will be separated from each other.
///
struct SpeechBubbleLine: Identifiable {
    let id = UUID()

    /// The content of the line
    /// - Note: The content will be concatenated as is, without adding
    ///         any whitespace between segments.
    let content: [SpeechBubbleLineSegment]
}

/// An individual segment of a line, including whether the content should
/// appear emphasised.
struct SpeechBubbleLineSegment: Equatable {
    let content: String
    let emphasised: Bool
}

struct SpeechBubbleLineGenerator {

    static let emphasis = Character("*")

    static func makeLine(_ str: String) -> SpeechBubbleLine {
        var segments = [SpeechBubbleLineSegment]()
        var builder: String = ""
        var buildingEmphasis: Bool = false

        func addIfNonEmpty() {
            if (!builder.isEmpty) {
                segments.append(SpeechBubbleLineSegment(content: builder, emphasised: buildingEmphasis))
            }
        }

        for char in str {
            if (char == emphasis) {
                addIfNonEmpty()
                builder = ""
                buildingEmphasis.toggle()
            } else {
                builder.append(char)
            }
        }
        addIfNonEmpty()
        return SpeechBubbleLine(content: segments)
    }
}
