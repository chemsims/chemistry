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
    let image: ImageType
    let selectedImage: ImageType
    let label: String

    public init(
        screen: Screen,
        image: ImageType,
        selectedImage: ImageType,
        label: String
    ) {
        self.screen = screen
        self.image = image
        self.selectedImage = selectedImage
        self.label = label
    }
}
