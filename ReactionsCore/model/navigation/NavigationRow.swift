//
// Reactions App
//

import Foundation

public struct NavigationRows<Screen> {
    let primary: [NavigationRow<Screen>]
    let secondary: [NavigationRow<Screen>]

    let maxSecondaryIconCount: Int

    public init(_ rows: [NavigationRow<Screen>], secondary: [NavigationRow<Screen>] = []) {
        self.primary = rows
        self.secondary = secondary

        self.maxSecondaryIconCount = (rows + secondary).map(\.secondaryIconCount).max() ?? 0
    }

}

public struct NavigationRow<Screen> {
    let primaryIcon: NavigationIcon<Screen>
    let firstSecondaryIcon: NavigationIcon<Screen>?
    let secondSecondaryIcon: NavigationIcon<Screen>?

    let secondaryIconCount: Int

    public init(
        primaryIcon: NavigationIcon<Screen>,
        firstSecondaryIcon: NavigationIcon<Screen>?,
        secondSecondaryIcon: NavigationIcon<Screen>?
    ) {
        self.primaryIcon = primaryIcon
        self.firstSecondaryIcon = firstSecondaryIcon
        self.secondSecondaryIcon = secondSecondaryIcon

        self.secondaryIconCount = [firstSecondaryIcon, secondSecondaryIcon].compactMap(identity).count
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
