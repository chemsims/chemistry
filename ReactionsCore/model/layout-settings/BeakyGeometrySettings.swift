//
// Reactions App
//

import CoreGraphics

public struct BeakyGeometrySettings {
    public let beakyVSpacing: CGFloat
    public let bubbleWidth: CGFloat
    public let bubbleHeight: CGFloat
    public let beakyHeight: CGFloat
    public let bubbleFontSize: CGFloat
    public let navButtonSize: CGFloat
    public let bubbleStemWidth: CGFloat

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

    /// Returns default geometry settings for the given screen width
    public init(
        screenWidth: CGFloat,
        screenHeight: CGFloat
    ) {
        let bubbleWidth = 0.3 * screenWidth
        self.init(
            beakyVSpacing: 2,
            bubbleWidth: bubbleWidth,
            bubbleHeight: 0.38 * screenHeight,
            beakyHeight: 0.12 * screenWidth,
            bubbleFontSize: 0.018 * screenWidth,
            navButtonSize: 0.076 * screenHeight,
            bubbleStemWidth: SpeechBubbleSettings.getStemWidth(bubbleWidth: bubbleWidth)
        )
    }
}
