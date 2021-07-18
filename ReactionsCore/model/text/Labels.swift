//
// Reactions App
//

import Foundation

public struct Labels {
    public static let openParen = "open parenthesis"
    public static let closedParen = "closed parenthesis"
}

struct SpeechLabelling {

    static func labelledLine(_ line: String) -> TextLine {
        TextLine(line, label: stringToLabel(line))
    }

    static func stringToLabel(_ content: String) -> String {
        let replaced = content.replacingOccurrences(of: replacements)
        return Labelling.stringToLabel(replaced)
    }

    private static let replacements: [(String, String)] = [
        ("[A_0_]", "(A0)"),
        ("[A_t_]", "(A T)")
    ]
}

public struct Labelling {

    /// Returns a string where parts of the string are mapped to a more accessible format
    ///
    /// For example, the symbol `Δ` is mapped to `delta`, and superscripts may be prefixed with `to the power of`, or
    /// returned as a more common string, such as `squared` for powers of 2.
    public static func stringToLabel(_ content: String) -> String {
        let preParsing = content.replacingOccurrences(of: preParseReplacements)
        let parsed = TextLine(preParsing, label: "")
        return parsed.content.reduce("") { (acc, next) in
            acc + labelSegment(next)
        }
    }

    private static func labelSegment(_ segment: TextSegment) -> String {
        if segment.scriptType == .superScript {
            return labelSuperscript(segment)
        } else if segment.scriptType == .subScript {
            return labelSubscript(segment)
        }
        return labelContent(segment.content)
    }

    private static func labelSuperscript(_ segment: TextSegment) -> String {
        switch segment.content {
        case "2": return " squared"
        case "3": return " cubed"
        default:
            return " to the power of \(labelContent(segment.content)),"
        }
    }

    private static func labelSubscript(_ segment: TextSegment) -> String {
        switch segment.content {
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
        ("A ➝ B", "A to B"),
        ("D ➝ E", "D, to E"),
        ("➝", ";"),
        ("half-life", "half life"),
        ("Half-life", " half life "),
        ("multi-step", "multi step"),
        ("rate-determining", "rate determining"),
        ("vice-versa", "vice versa"),
        ("Sodium-24", "Sodium 24"),
        ("Bismuth-212", "Bismuth 212"),
        ("Cobalt-60", "Cobalt 60"),
        ("sodium-24", "sodium 24"),
        ("bismuth-212", "bismuth 212"),
        ("cobalt-60", "cobalt 60"),
        ("non-spontaneous", "non spontaneous"),
        ("get-go", "get go"),
        ("-", " minus "),
        ("k[A][B][C]", "k times 'A' times B times C"),
        ("k[A][B]", "k[A], [B]"),
        ("k[A]", "K times 'A'"),
        ("k[B]", "K times 'B'"),
        ("k[C]", "K times 'C'"),
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
        ("reactants/products", "reactants slash products"),
        ("/", " divide by "),
        ("ln(2)", "ln 2,"),
        ("0.034667", "0 point 034667"),
        ("0.02", "0 dot 0 2"),
        (" which is the same as", ", which is the same as"),
        (" where n is the order", ", where n is the order"),
        ("⇌", "double sided arrow,"),
        ("⇄", "double sided arrow,"),
        ("0.5X", "0.5 x"),
        (")(", " times "),
        ("pOH", "POH")
    ]

    private static let preParseReplacements: [(String, String)] = [
        ("➝ 2NO", "yields, 2NO"),
        ("➝ H_2_O", "yields H_2_O"),
        ("➝ Products", "yields products"),
        ("2C ➝ AC", "2C, yields, AC"),
        ("CaCl_2_", "C 'A' 'C' 'L' TWO"),
        ("(aq)", "(AQ)"),
        ("2AgNO_3_", "TWO 'A' G N O THREE"),
        ("AgNO_3_", "'A' G N O THREE"),
        ("Ca(NO_3_)_2_", "C 'A' N O THREE, TWO"),
        ("2AgCl", "TWO 'A' G C L"),
        ("N_2_O_2_", "N2O2"),
        ("2NO", "2 N O"),
        ("NO_2_", "N O '2'"),
        ("NO", "N O"),
        ("O_2_", "O '2'"),
        ("k[AB]^m^[C]^n^", "k, times A B ^m^, times C ^n^"),
        ("k[AB]^m^", "k, times A B ^m^"),
        ("k[AB][C]", "k, times A B, times C"),
        ("S_2_O_8_^-2^", "S2O8 (charge -2) "),
        ("SO", "S O"),
        ("ClO", "C L O"),
        ("k[X][Y][Z]", "k, times X, times Y, times Z"),
        ("k[XY][Z]", "k, times XY, times Z"),
        ("k[X][Y][XY]", "k, times X, times Y, times XY"),
        ("E_a_", "EA"),
        ("OH", "O H"),
        ("A_2_", "'A'2"),
        ("rate_r_", "rate r"),
        ("rate_f_","rate f"),
        ("^+^", "+"),
        ("^-^", " minus")
    ]
}

fileprivate extension String {
    func replacingOccurrences(of replacements: [(String, String)]) -> String {
        replacements.reduce(self) { (acc, next) in
            acc.replacingOccurrences(of: next.0, with: next.1)
        }
    }
}
