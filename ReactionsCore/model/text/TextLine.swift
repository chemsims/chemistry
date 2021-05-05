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
public struct TextLine: ExpressibleByStringLiteral, ExpressibleByStringInterpolation, Equatable {

    /// The content of the line
    /// - Note: The content will be concatenated as is, without adding
    ///         any whitespace between segments.
    public let content: [TextSegment]
    public let customLabel: String?

    public init(content: [TextSegment], customLabel: String? = nil) {
        self.content = content
        self.customLabel = customLabel
    }

    /// Creates a new `TextLine` from the literal String `value`, after parsing the String, and applying mapping the string to a
    /// more accessible label
    public init(stringLiteral value: String) {
        self.init(value, label: Labelling.stringToLabel(value))
    }

    /// Creates a new `TextLine` from the provided `value`, after parsing the String, and applying mapping the string to a
    /// more accessible label
    public init(_ rawString: String) {
        self.init(stringLiteral: rawString)
    }

    public init(_ rawString: String, label: String) {
        self.init(
            content: TextLineGenerator.makeLine(rawString).content,
            customLabel: label
        )
    }

    public static func +(lhs: TextLine, rhs: TextLine) -> TextLine {
        TextLine(content: lhs.content + rhs.content)
    }
}

extension TextLine {
    /// Character count, based on the semantics of `String.count`
    public var length: Int {
        content.reduce(0) { (acc, next) in
            acc + next.content.count
        }
    }

    /// Content as a String
    public var asString: String {
        content.reduce("") { (acc, next) in
            acc + next.content
        }
    }

    /// Accessibility label for the content
    public var label: String {
        customLabel ?? asString
    }
}

extension TextLine {
    public func italic() -> TextLine {
        TextLine(content: content.map { c in c.setItalic(true) })
    }

    public func emphasised() -> TextLine {
        TextLine(content: content.map { $0.setEmphasised(true) })
    }

    public func prepending(_ other: TextSegment) -> TextLine {
        TextLine(content: [other] + content)
    }

}

extension Array where Element == TextLine {
    public var label: String {
        if let firstLine = first {
            return dropFirst().reduce(firstLine.label) { acc, next in
                acc + "\n" + next.label
            }
        }
        return ""
    }
}

/// An individual segment of a line, including whether the content should
/// appear emphasised.
public struct TextSegment: Equatable {
    public let content: String
    public let emphasised: Bool
    public let scriptType: ScriptType?
    public let allowBreaks: Bool
    public let italic: Bool

    public init(
        content: String,
        emphasised: Bool = false,
        scriptType: ScriptType? = nil,
        allowBreaks: Bool = true,
        italic: Bool = false
    ) {
        self.content = content
        self.emphasised = emphasised
        self.scriptType = scriptType
        self.allowBreaks = allowBreaks
        self.italic = italic
    }
}

extension TextSegment {
    func setItalic(_ newValue: Bool) -> TextSegment {
        TextSegment(
            content: content,
            emphasised: emphasised,
            scriptType: scriptType,
            allowBreaks: allowBreaks,
            italic: newValue
        )
    }

    func setEmphasised(_ newValue: Bool) -> TextSegment {
        TextSegment(
            content: content,
            emphasised: newValue,
            scriptType: scriptType,
            allowBreaks: allowBreaks,
            italic: italic
        )
    }
}

public enum ScriptType {
    case superScript, subScript
}

public struct TextLineGenerator {

    private static let emphasis = Character("*")
    private static let sub = Character("_")
    private static let superScript = Character("^")
    private static let noBreaks = Character("$")
    private static let escape = Character("\\")

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
    /// `makeLine("This equation for *Half-Life* is incorrect: $t_1/2_ = [A_0_]^Order^$")`
    ///
    /// Note that it is possible to nest control characters - with the exception of subscript and superscript.
    /// It is generally a good idea to wrap mathematical expressions with the `$` to avoid the term wrapping over multiple line.
    public static func makeLine(_ str: String) -> TextLine {
        var segments = [TextSegment]()
        var builder: String = ""
        var buildingEmphasis: Bool = false
        var scriptType: ScriptType?
        var allowBreaks: Bool = true

        func addIfNonEmpty() {
            if !builder.isEmpty {
                segments.append(
                    TextSegment(
                        content: builder,
                        emphasised: buildingEmphasis,
                        scriptType: scriptType,
                        allowBreaks: allowBreaks,
                        italic: false
                    )
                )
            }
        }

        for index in str.indices {
            let char = str[index]
            if char == escape {
                continue
            }

            let charScript = charToScript(char)
            let hasPrev = str.indices.first! < index
            let prevIsEscape = hasPrev && str[str.index(before: index)] == escape
            if char == emphasis && !prevIsEscape {
                addIfNonEmpty()
                builder = ""
                buildingEmphasis.toggle()
            } else if charScript != nil && !prevIsEscape {
                addIfNonEmpty()
                builder = ""
                scriptType = scriptType == nil ? charScript : nil
            } else if char == noBreaks && !prevIsEscape {
                addIfNonEmpty()
                builder = ""
                allowBreaks.toggle()
            } else {
                builder.append(char)
            }
        }
        addIfNonEmpty()

        assert(allowBreaks && !buildingEmphasis && scriptType == .none,
               "String '\(str)' did not close all control characters")
        return TextLine(content: segments)
    }

    private static func charToScript(_ c: Character) -> ScriptType? {
        if c == sub {
            return .subScript
        } else if c == superScript {
            return .superScript
        }
        return nil
    }
}
