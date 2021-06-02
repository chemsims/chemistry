//
// Reactions App
//

import CoreGraphics

public struct BeakyGeometrySettings {
    public let beakyVSpacing: CGFloat

    /// Total width of the speech bubble, including the stem
    public let bubbleWidth: CGFloat
    public let bubbleHeight: CGFloat
    public let beakyHeight: CGFloat
    public let bubbleFontSize: CGFloat
    public let navButtonSize: CGFloat

    /// Width of the stem
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

    /// Returns default geometry for the given width and height of the enclosing box
    public init(
        width: CGFloat,
        height: CGFloat
    ) {
        let beakyWidthToBubbleWidth = Beaky.widthToHeight * Defaults.beakyHeightToBubbleWidth
        let bubbleWidth = width / (1 + beakyWidthToBubbleWidth)
        let bubbleHeight = (height - Defaults.vSpacing) / (1 + Defaults.navSizeToBubbleHeight)
        self.init(bubbleWidth: bubbleWidth, bubbleHeight: bubbleHeight)
    }

    /// Returns default geometry settings for the given screen width
    public init(
        screenWidth: CGFloat,
        screenHeight: CGFloat
    ) {
        self.init(
            bubbleWidth: Defaults.bubbleWidthToScreenWidth * screenWidth,
            bubbleHeight: Defaults.bubbleHeightToScreenHeight * screenHeight
        )
    }

    /// Returns default geometry for the given bubble width and height
    private init(
        bubbleWidth: CGFloat,
        bubbleHeight: CGFloat
    ) {
        self.init(
            beakyVSpacing: Defaults.vSpacing,
            bubbleWidth: bubbleWidth,
            bubbleHeight: bubbleHeight,
            beakyHeight: Defaults.beakyHeightToBubbleWidth * bubbleWidth,
            bubbleFontSize: Defaults.fontSizeToBubbleWidth * bubbleWidth,
            navButtonSize: Defaults.navSizeToBubbleHeight * bubbleHeight,
            bubbleStemWidth: SpeechBubbleSettings.getStemWidth(bubbleWidth: bubbleWidth)
        )
    }

    private struct Defaults {
        static let vSpacing: CGFloat = 2
        static let bubbleWidthToScreenWidth: CGFloat = 0.3
        static let bubbleHeightToScreenHeight: CGFloat = 0.38

        static let fontSizeToBubbleWidth: CGFloat = 0.06

        static let navSizeToBubbleHeight: CGFloat = 0.2

        static let beakyHeightToBubbleWidth: CGFloat = 0.4
    }
}
