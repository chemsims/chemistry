//
// Reactions App
//


import Foundation

struct AqueousReactionSettings {
    static let minRows = 6
    static let maxRows = 14

    static let initialRows = (minRows + maxRows) / 2

    /// The number of molecules to increment when user is adding molecules
    static let moleculesToIncrement = 10
}
