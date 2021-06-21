 //
 // Reactions App
 //

 import CoreGraphics
 import ReactionsCore

 protocol TitrationEquationLabel {
     func label(forData data: TitrationEquationData) -> TextLine
 }

 protocol TitrationEquationValue {
    func value(forData data: TitrationEquationData) -> CGFloat
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

 private extension TitrationEquationData {

    var substanceSymbol: String {
        substance.chargedSymbol(ofPart: .substance).asString
    }

    var secondarySymbol: String {
        substance.chargedSymbol(ofPart: .secondaryIon).asString
    }

    var plainSubstanceSymbol: String {
        substance.chargedSymbol(ofPart: .substance).symbol
    }

    var plainSecondarySymbol: String {
        substance.chargedSymbol(ofPart: .secondaryIon).symbol
    }
 }

 let hydrogenSymbol = "H+"
 let hydroxideSymbol = "OH-"

 extension TitrationEquationTerm.Moles: TitrationEquationLabel, TitrationEquationValue {
    func label(forData data: TitrationEquationData) -> TextLine {
        let field = AnyField.fromMoles(self)
        return "n_\(field.chargedSymbol(data: data))_"
    }

    func value(forData data: TitrationEquationData) -> CGFloat {
        data.moles.value(for: self)
    }
 }

 extension TitrationEquationTerm.Volume: TitrationEquationLabel, TitrationEquationValue {
    func label(forData data: TitrationEquationData) -> TextLine {
        let field = AnyField.fromVolume(self)
        return "V_\(field.chargedSymbol(data: data))_"
    }

    func value(forData data: TitrationEquationData) -> CGFloat {
        data.volume.value(for: self)
    }
 }

 extension TitrationEquationTerm.Molarity: TitrationEquationLabel, TitrationEquationValue {
    func label(forData data: TitrationEquationData) -> TextLine {
        let field = AnyField.fromMolarity(self)
        return "M_\(field.chargedSymbol(data: data))_"
    }

    func value(forData data: TitrationEquationData) -> CGFloat {
        data.molarity.value(for: self)
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
         equivalencePoint

    func chargedSymbol(data: TitrationEquationData) -> String {
        switch self {
        case .hydrogen: return "H+"
        case .hydroxide: return "OH-"
        case .initialSecondary: return "\(data.secondarySymbol)i"
        case .initialSubstance: return "\(data.substanceSymbol)i"
        case .secondary: return data.secondarySymbol
        case .substance: return data.substanceSymbol
        case .titrant: return data.titrant
        case .equivalencePoint: return "E"
        }
    }

    func plainSymbol(data: TitrationEquationData) -> String {
        switch self {
        case .hydrogen: return "H"
        case .hydroxide: return "OH"
        case .initialSecondary: return "\(data.plainSecondarySymbol)i"
        case .initialSubstance: return "\(data.plainSubstanceSymbol)i"
        case .secondary: return data.plainSecondarySymbol
        case .substance: return data.plainSubstanceSymbol
        case .titrant: return data.titrant
        case .equivalencePoint: return "E"
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
 }
