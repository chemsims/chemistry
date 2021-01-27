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
        let preParsing = content.replacingOccurrences(of: preParseReplacements)
        let parsed = TextLine(stringLiteral: preParsing)
        return parsed.content.reduce("") { (acc, next) in
            acc + labelSegment(next)
        }
    }

    private static func labelSegment(_ segment: TextSegment) -> String {
        if (segment.scriptType == .superScript) {
            return labelSuperscript(segment)
        } else if (segment.scriptType == .subScript) {
            return labelSubscript(segment)
        }
        return labelContent(segment.content)
    }

    private static func labelSuperscript(_ segment: TextSegment) -> String {
        switch (segment.content) {
        case "2": return " squared"
        default:
            return " to the power of \(labelContent(segment.content)),"
        }
    }

    private static func labelSubscript(_ segment: TextSegment) -> String {
        switch (segment.content) {
        case "1/2": return " one half"
        case "t": return "'T'"
        default:
            return labelContent(segment.content)
        }
    }

    private static func labelContent(_ content: String) -> String {
        content.replacingOccurrences(of: replacements)
    }

    private static let replacements: [(String, String)] = [
        ("➝", ";"),
        ("half-life", "half life"),
        ("Half-life", " half life "),
        ("vice-versa", "vice versa"),
        ("Sodium-24", "Sodium 24"), 
        ("-", " minus "),
        ("k[A][B]", "k[A], [B]"),
        ("k[A]", "K times 'A'"),
        ("k[B]", "K times 'B'"),
        ("5[A", "5 times 'A'"),
        ("6[A", "6 times 'A'"),
        ("]e", "] times e"),
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
        ("A is", "'A' is"),
        ("to: ", "to "),
        ("*", "times"),
        ("/", " divide by "),
        ("ln(2)", "ln 2,"),
        ("0.034667", "0 point 034667"),
        ("0.02", "0 dot 0 2"),
        (" which is the same as", ", which is the same as"),
        (" where n is the order", ", where n is the order")
    ]

    private static let preParseReplacements: [(String, String)] = [
        ("CaCl_2_", "C 'A' 'C' 'L' TWO"),
        ("(aq)", "(AQ)"),
        ("2AgNO_3_", "TWO 'A' G N O THREE"),
        ("AgNO_3_", "'A' G N O THREE"),
        ("Ca(NO_3_)_2_", "C 'A' N O THREE, TWO"),
        ("2AgCl", "TWO 'A' G C L"),
    ]
}

fileprivate extension String {
    func replacingOccurrences(of replacements: [(String, String)]) -> String {
        replacements.reduce(self) { (acc, next) in
            acc.replacingOccurrences(of: next.0, with: next.1)
        }
    }
}
