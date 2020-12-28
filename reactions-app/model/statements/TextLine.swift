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
struct TextLine: ExpressibleByStringLiteral, Equatable {

    /// The content of the line
    /// - Note: The content will be concatenated as is, without adding
    ///         any whitespace between segments.
    let content: [TextSegment]

    init(content: [TextSegment]) {
        self.content = content
    }

    /// Creates a new `TextLine` from the literal String `value`, after parsing the String.
    init(stringLiteral value: String) {
        self.init(content: TextLineGenerator.makeLine(value).content)
    }
}

/// An individual segment of a line, including whether the content should
/// appear emphasised.
struct TextSegment: Equatable {
    let content: String
    let emphasised: Bool
    let scriptType: ScriptType?
    let allowBreaks: Bool

    init(
        content: String,
        emphasised: Bool,
        scriptType: ScriptType? = nil,
        allowBreaks: Bool = true
    ) {
        self.content = content
        self.emphasised = emphasised
        self.scriptType = scriptType
        self.allowBreaks = allowBreaks
    }
}

enum ScriptType {
    case superScript, subScript
}

struct TextLineGenerator {

    private static let emphasis = Character("*")
    private static let sub = Character("_")
    private static let superScript = Character("^")
    private static let noBreaks = Character("$")

    /// Creates a `TextLine` by parsing the provided String.
    ///
    /// - Parameter str: The string value to parse
    ///
    /// Usage
    /// =====
    /// The provided string is parsed by surrounding text with control characters
    /// The following control characters are supported
    /// - Emphasis: `*`
    ///     Adds emphasis to the text
    /// - Subscript: `_`
    ///     Makes the text a subscript
    /// - Superscript: `^`
    ///     Makes the text a superscript
    /// - No-breaks: `$`
    ///     Ensures the text cannot be broken to fit into a new line
    ///
    /// An example using each of these control characters is,
    ///
    /// `makeLine("This equation for *Half Life* is incorrect: $t_1/2_ = [A_0_]^Order^$")`
    ///
    /// Note that it is possible to nest control characters - with the exception of subscript and superscript.
    /// It is generally a good idea to wrap mathematical expressions with the `$` to avoid the term wrapping over multiple line.
    static func makeLine(_ str: String) -> TextLine {
        var segments = [TextSegment]()
        var builder: String = ""
        var buildingEmphasis: Bool = false
        var scriptType: ScriptType? = nil
        var allowBreaks: Bool = true

        func addIfNonEmpty() {
            if (!builder.isEmpty) {
                segments.append(
                    TextSegment(
                        content: builder,
                        emphasised: buildingEmphasis,
                        scriptType: scriptType,
                        allowBreaks: allowBreaks
                    )
                )
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
            } else if (char == noBreaks) {
                addIfNonEmpty()
                builder = ""
                allowBreaks.toggle()
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
