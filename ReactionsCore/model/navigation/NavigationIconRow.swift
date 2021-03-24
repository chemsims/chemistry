//
// Reactions App
//

import Foundation

public struct NavigationIconRow<Screen> {
    let primaryIcon: NavigationIcon<Screen>
    let firstSecondaryIcon: NavigationIcon<Screen>?
    let secondSecondaryIcon: NavigationIcon<Screen>?

    public init(
        primaryIcon: NavigationIcon<Screen>,
        firstSecondaryIcon: NavigationIcon<Screen>?,
        secondSecondaryIcon: NavigationIcon<Screen>?
    ) {
        self.primaryIcon = primaryIcon
        self.firstSecondaryIcon = firstSecondaryIcon
        self.secondSecondaryIcon = secondSecondaryIcon
    }
}

public struct NavigationIcon<Screen> {
    let screen: Screen
    let image: String
    let pressedImage: String
    let isSystemImage: Bool
    let label: String

    public init(
        screen: Screen,
        image: String,
        pressedImage: String,
        isSystemImage: Bool,
        label: String
    ) {
        self.screen = screen
        self.image = image
        self.pressedImage = pressedImage
        self.isSystemImage = isSystemImage
        self.label = label
    }
}
