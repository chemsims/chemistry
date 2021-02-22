//
// Reactions App
//

import CoreGraphics

public struct BeakyGeometrySettings {
    let beakyVSpacing: CGFloat
    let bubbleWidth: CGFloat
    let bubbleHeight: CGFloat
    let beakyHeight: CGFloat
    let bubbleFontSize: CGFloat
    let navButtonSize: CGFloat
    let bubbleStemWidth: CGFloat

    public init(
        beakyVSpacing: CGFloat,
        bubbleWidth: CGFloat,
        bubbleHeight: CGFloat,
        beakyHeight: CGFloat,
        bubbleFontSize: CGFloat,
        navButtonSize: CGFloat,
        bubbleStemWidth: CGFloat
    ) {
        self.beakyVSpacing = beakyVSpacing
        self.bubbleWidth = bubbleWidth
        self.bubbleHeight = bubbleHeight
        self.beakyHeight = beakyHeight
        self.bubbleFontSize = bubbleFontSize
        self.navButtonSize = navButtonSize
        self.bubbleStemWidth = bubbleStemWidth
    }
}
