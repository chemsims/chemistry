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
struct TextLine: Identifiable, ExpressibleByStringLiteral {
    let id = UUID()

    /// The content of the line
    /// - Note: The content will be concatenated as is, without adding
    ///         any whitespace between segments.
    let content: [TextSegment]

    init(content: [TextSegment]) {
        self.content = content
    }

    /// Creates a new TextLine from the literal string `value`
    init(stringLiteral value: String) {
        self.init(content: [TextSegment(content: value, emphasised: false)])
    }
}

/// An individual segment of a line, including whether the content should
/// appear emphasised.
struct TextSegment: Equatable {
    let content: String
    let emphasised: Bool
    let scriptType: ScriptType?

    init(
        content: String,
        emphasised: Bool,
        scriptType: ScriptType? = nil
    ) {
        self.content = content
        self.emphasised = emphasised
        self.scriptType = scriptType
    }
}

enum ScriptType {
    case superScript, subScript
}

struct TextLineGenerator {

    private static let emphasis = Character("*")
    private static let sub = Character("_")
    private static let superScript = Character("^")

    static func makeLine(_ str: String) -> TextLine {
        var segments = [TextSegment]()
        var builder: String = ""
        var buildingEmphasis: Bool = false
        var scriptType: ScriptType? = nil

        func addIfNonEmpty() {
            if (!builder.isEmpty) {
                segments.append(TextSegment(content: builder, emphasised: buildingEmphasis, scriptType: scriptType))
            }
        }

        for char in str {
            let charScript = charToScript(char)
            if (char == emphasis) {
                addIfNonEmpty()
                builder = ""
                buildingEmphasis.toggle()
            } else if (charScript != nil) {
                addIfNonEmpty()
                builder = ""
                scriptType = scriptType == nil ? charScript : nil
            } else {
                builder.append(char)
            }
        }
        addIfNonEmpty()
        return TextLine(content: segments)
    }

    private static func charToScript(_ c: Character) -> ScriptType? {
        if (c == sub) {
            return .subScript
        } else if (c == superScript) {
            return .superScript
        }
        return nil
    }
}
