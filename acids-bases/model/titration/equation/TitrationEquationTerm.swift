 //
 // Reactions App
 //

 import CoreGraphics
 import ReactionsCore

 protocol TitrationEquationTermLabel {
     func label(forData data: TitrationEquationData) -> TextLine
 }

 protocol TitrationEquationTermValue {
    func value(forData data: TitrationEquationData) -> CGFloat
 }

 protocol TitrationEquationTermEquation {
    func equation(forData data: TitrationEquationData) -> Equation
 }

 struct TitrationEquationTerm {
    private init() { }

    struct Placeholder<Term> {

       init(_ term: Term, isFilled: Bool) {
           self.term = term
           self.isFilled = isFilled
       }

       let term: Term
       let isFilled: Bool
    }

    enum Volume: String, CaseIterable {
        case hydrogen,
             substance,
             initialSubstance,
             titrant,
             initialSecondary,
             equivalencePoint
    }

    enum Molarity: String, CaseIterable {
        case hydrogen,
             substance,
             titrant
    }

    enum Moles: String, CaseIterable {
        case hydrogen
        case substance
        case initialSubstance
        case secondary
        case initialSecondary
        case titrant
    }

    enum Concentration: String, CaseIterable {
        case hydrogen,
             hydroxide,
             substance,
             initialSubstance,
             secondary,
             initialSecondary
    }

    enum PValue: String, CaseIterable {
        case hydrogen,
             hydroxide,
             kA,
             kB
    }

    enum KValue: String, CaseIterable {
        case kA, kB
    }
 }

 extension TitrationEquationTerm.Moles: TitrationEquationTermLabel, TitrationEquationTermValue {
    func label(forData data: TitrationEquationData) -> TextLine {
        let field = AnyField.fromMoles(self)
        return "n_\(field.fullSymbol(data: data))_"
    }

    func value(forData data: TitrationEquationData) -> CGFloat {
        data.moles.value(for: self)
    }
 }

 extension TitrationEquationTerm.Volume: TitrationEquationTermLabel, TitrationEquationTermValue {
    func label(forData data: TitrationEquationData) -> TextLine {
        let field = AnyField.fromVolume(self)
        return "V_\(field.fullSymbol(data: data))_"
    }

    func value(forData data: TitrationEquationData) -> CGFloat {
        data.volume.value(for: self)
    }
 }

 extension TitrationEquationTerm.Molarity: TitrationEquationTermLabel, TitrationEquationTermValue {
    func label(forData data: TitrationEquationData) -> TextLine {
        let field = AnyField.fromMolarity(self)
        return "M_\(field.fullSymbol(data: data))_"
    }

    func value(forData data: TitrationEquationData) -> CGFloat {
        data.molarity.value(for: self)
    }
 }

 extension TitrationEquationTerm.Concentration: TitrationEquationTermLabel, TitrationEquationTermValue, TitrationEquationTermEquation {
    func label(forData data: TitrationEquationData) -> TextLine {
        let field = AnyField.fromConcentration(self)
        let plain = field.plainSymbol(data: data)
        let charge = field.charge(data: data)
        let suffix = field.symbolSuffix

        return "[\(plain)^\(charge)^]_\(suffix)_"
    }

    func value(forData data: TitrationEquationData) -> CGFloat {
        data.concentration.value(for: self)
    }

    func equation(forData data: TitrationEquationData) -> Equation {
        IdentityEquation()
    }
 }

 extension TitrationEquationTerm.PValue: TitrationEquationTermLabel, TitrationEquationTermValue {
    func label(forData data: TitrationEquationData) -> TextLine {
        let field = AnyField.fromPValue(self)
        let plain = field.plainSymbol(data: data)
        return "p\(plain)"
    }

    func value(forData data: TitrationEquationData) -> CGFloat {
        data.pValues.value(for: self)
    }
 }

 extension TitrationEquationTerm.KValue: TitrationEquationTermLabel, TitrationEquationTermValue {
    func label(forData data: TitrationEquationData) -> TextLine {
        let plainSymbol = AnyField.fromKValue(self).plainSymbol(data: data)
        return TextLine(plainSymbol)
    }

    func value(forData data: TitrationEquationData) -> CGFloat {
        data.kValues.value(for: self)
    }
 }

 /// Represents any field used in the equation, for the purpose of a common way to map specific fields
 /// into a string or text line.
 private enum AnyField {

    case hydrogen,
         hydroxide,
         substance,
         initialSubstance,
         secondary,
         initialSecondary,
         titrant,
         equivalencePoint,
         kA,
         kB

    func fullSymbol(data: TitrationEquationData) -> String {
        let plain = plainSymbol(data: data)
        let charge = charge(data: data)
        return "\(plain)\(charge)\(symbolSuffix)"
    }

    var symbolSuffix: String {
        switch self {
        case .initialSubstance, .initialSecondary: return "i"
        default: return ""
        }
    }

    func charge(data: TitrationEquationData) -> String {
        switch self {
        case .hydrogen: return "+"
        case .hydroxide: return "-"
        case .secondary, .initialSecondary:
            return data.substance.chargedSymbol(ofPart: .secondaryIon).charge?.rawValue ?? ""
        case .substance, .initialSubstance:
            return data.substance.chargedSymbol(ofPart: .substance).charge?.rawValue ?? ""
        default: return ""
        }
    }

    func plainSymbol(data: TitrationEquationData) -> String {
        switch self {
        case .hydrogen: return "H"
        case .hydroxide: return "OH"
        case .secondary, .initialSecondary:
            return data.substance.chargedSymbol(ofPart: .secondaryIon).symbol
        case .substance, .initialSubstance:
            return data.substance.chargedSymbol(ofPart: .substance).symbol
        case .titrant: return data.titrant
        case .equivalencePoint: return "E"
        case .kA: return "Ka"
        case .kB: return "Kb"
        }
    }

    static func fromMoles(_ mole: TitrationEquationTerm.Moles) -> AnyField {
        switch mole {
        case .hydrogen: return .hydrogen
        case .initialSecondary: return .initialSecondary
        case .initialSubstance: return .initialSubstance
        case .secondary: return .secondary
        case .substance: return .substance
        case .titrant: return .titrant
        }
    }

    static func fromVolume(_ volume: TitrationEquationTerm.Volume) -> AnyField {
        switch volume {
        case .equivalencePoint: return .equivalencePoint
        case .hydrogen: return .hydrogen
        case .initialSecondary: return .initialSecondary
        case .initialSubstance: return .initialSubstance
        case .substance: return .substance
        case .titrant: return .titrant
        }
    }

    static func fromMolarity(_ molarity: TitrationEquationTerm.Molarity) -> AnyField {
        switch molarity {
        case .hydrogen: return .hydrogen
        case .substance: return .substance
        case .titrant: return .titrant
        }
    }

    static func fromConcentration(_ concentration: TitrationEquationTerm.Concentration) -> AnyField {
        switch concentration {
        case .hydrogen: return .hydrogen
        case .hydroxide: return .hydroxide
        case .initialSecondary: return .initialSecondary
        case .initialSubstance: return .initialSubstance
        case .secondary: return .secondary
        case .substance: return .substance
        }
    }

    static func fromPValue(_ pValue: TitrationEquationTerm.PValue) -> AnyField {
        switch pValue {
        case .hydrogen: return .hydrogen
        case .hydroxide: return .hydroxide
        case .kA: return .kA
        case .kB: return .kB
        }
    }

    static func fromKValue(_ kValue: TitrationEquationTerm.KValue) -> AnyField {
        switch kValue {
        case .kA: return .kA
        case .kB: return .kB
        }
    }
 }
