//
// Reactions App
//
  

import Foundation

struct Labels {
    static let openParen = "open parenthesis"
    static let closedParen = "closed parenthesis"
}


struct Labelling {

    /// Returns a string where parts of the string are mapped to a more accessible format
    ///
    /// For example, the symbol `Δ` is mapped to `delta`, and superscripts may be prefixed with `to the power of`, or
    /// returned as a more common string, such as `squared` for powers of 2.
    static func stringToLabel(_ content: String) -> String {
        let parsed = TextLine(stringLiteral: content)
        return parsed.content.reduce("") { (acc, next) in
            acc + labelSegment(next)
        }
    }

    private static func labelSegment(_ segment: TextSegment) -> String {
        if (segment.scriptType == .superScript) {
            return labelSuperscript(segment)
        } else if (segment.scriptType == .subScript && segment.content == "1/2") {
            return " one half"
        }
        return labelContent(segment.content)
    }

    private static func labelSuperscript(_ segment: TextSegment) -> String {
        if (segment.content == "2") {
            return " squared"
        }
        return " to the power of \(labelContent(segment.content)),"
    }

    private static func labelContent(_ content: String) -> String {
        replacements.reduce(content) { (acc, next) in
            acc.replacingOccurrences(of: next.0, with: next.1)
        }
    }

    private static let replacements: [(String, String)] = [
        ("➝", ";"),
        ("half-life", "half life"),
        ("Half-life", " half life "),
        ("-", " minus "),
        ("k[A]", "K times 'A'"),
        ("5[A", "5 times 'A'"),
        ("[A]", "'A'"),
        ("[", ""),
        ("]", ""),
        ("Δ", " delta "),
        ("M/s", "M slash s"),
        ("mol/s", "mol slash s"),
        ("g/s", "g slash s"),
        ("M/min", "M slash min"),
        ("M/h", "M slash h"),
        ("molarity/seconds", "molarity slash seconds"),
        ("A currently has", "'A' currently has"),
        ("to: ", "to "),
        ("*", "times"),
        ("/", " divide by "),
        ("ln(2)", "natural log of 2,")
    ]
}
