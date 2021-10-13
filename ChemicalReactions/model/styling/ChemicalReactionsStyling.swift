//
// Reactions App
//

import ReactionsCore

extension RGB {
    static let carbon = RGB(r: 85, g: 151, b: 190)
    static let hydrogen = RGB(r: 143, g: 234, b: 228)
    static let nitrogen = RGB(r: 123, g: 127, b: 220)
    static let oxygen = RGB(r: 218, g: 105, b: 136)
}

extension Styling {
    struct Precipitation {
        static let knownReactant1 = RGB(r: 254, g: 193, b: 113).color
        static let unknownReactant1 = RGB(r: 61, g: 71, b: 81).color
        static let product1 = RGB(r: 205, g: 121, b: 163).color
        
        static let knownReactant2 = RGB(r: 76, g: 72, b: 67).color
        static let unknownReactant2 = RGB(r: 225, g: 64, b: 61).color
        static let product2 = RGB(r: 87, g: 167, b: 115).color
    }
}
