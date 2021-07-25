//
// Reactions App
//


import Foundation

enum AqueousReactionInputState {
    case none, selectReactionType, setLiquidLevel, addReactants, addProducts
}

enum GaseousReactionInputState {
    case none, selectReactionType, addReactants, setBeakerVolume, setTemperature
}
