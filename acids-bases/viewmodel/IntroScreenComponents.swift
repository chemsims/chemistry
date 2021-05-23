//
// Reactions App
//

import CoreGraphics
import ReactionsCore

protocol IntroScreenComponents {
    func increment(substance: Substance, count: Int)

    func concentration(ofIon ion: PrimaryIon) -> PrimaryIonConcentration

    var fractionSubstanceAdded: CGFloat { get }

    var coords: [BeakerMolecules] { get }

    var barChart: [BarChartData] { get }
}

struct PrimaryIonConcentration {
    let concentration: CGFloat
    let p: CGFloat
}

struct Substance: Equatable {
    let name: String
    let primary: PrimaryIon
    let secondary: SecondaryIon
}

enum PrimaryIon {
    case hydrogen
    case hydroxide
}

enum SecondaryIon {
    case A
    case Cl
}
