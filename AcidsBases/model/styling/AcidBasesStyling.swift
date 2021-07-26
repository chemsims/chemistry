//
// Reactions App
//

import ReactionsCore

extension RGB {
    static let hydrogen = RGB(r: 240, g: 149, b: 137)
    static let hydroxide = RGB(r: 170, g: 176, b: 243)

    static let hydrogenDarker = RGB(r: 191, g: 44, b: 25)
    static let hydroxideDarker = RGB(r: 119, g: 128, b: 236)

    static let placeholderContainer = RGB.gray(base: 220)

    static let indicator = RGB(r: 125, g: 122, b: 188)

    static let maxIndicator = RGB(r: 125, g: 122, b: 188)
    static let maxIndicatorName = "purple"

    static let equivalencePointLiquid = RGB(r: 244, g: 164, b: 167)
    static let equivalencePointName = "pink"

    // MARK: Strong acids
    static let chlorine = RGB(r: 91, g: 55, b: 88)
    static let hydrogenChloride = RGB(r: 88, g: 129, b: 87)

    static let iodine = RGB(r: 97, g: 97, b: 99)
    static let hydrogenIodide = RGB(r: 204, g: 156, b: 0)

    static let bromine = RGB(r: 141, g: 59, b: 114)
    static let hydrogenBromide = RGB(r: 87, g: 136, b: 108)

    // MARK: Strong bases
    static let potassium = RGB(r: 95, g: 26, b: 55)
    static let potassiumHydroxide = RGB(r: 208, g: 150, b: 17)

    static let lithium = RGB(r: 0, g: 36, b: 0)
    static let lithiumHydroxide = RGB(r: 140, g: 72, b: 67)

    static let sodium = RGB(r: 129, g: 52, b: 5)
    static let sodiumHydroxide = RGB(r: 255, g: 59, b: 10)

    // MARK: Weak acids
    static let ionA = RGB(r: 178, g: 13, b: 48)
    static let weakAcidHA = RGB(r: 43, g: 65, b: 80)

    static let ionF = RGB(r: 8, g: 97, b: 72)
    static let weakAcidHF = RGB(r: 125, g: 30, b: 71)

    static let cyanide = RGB(r: 114, g: 172, b: 121)
    static let hydrogenCyanide = RGB(r: 1, g: 22, b: 39)

    // MARK: Weak bases
    static let ionB =  RGB(r: 49, g: 47, b: 47)
    static let weakBaseB = RGB(r: 234, g: 196, b: 53)

    static let weakBaseF = RGB(r: 92, g: 67, b: 96)

    static let ionHS = RGB(r: 57, g: 61, b: 63)
    static let weakBaseHS = RGB(r: 175, g: 150, b: 8)
}


struct MoleculeColor {
    let substance: RGB
    let secondaryIon: RGB
}
