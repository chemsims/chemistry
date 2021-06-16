//
// Reactions App
//

import ReactionsCore

// TODO - labels
struct AcidAppNavigationRows {
    private init() { }
    
    static let rows = NavigationRows<AcidAppScreen>(
        [
            NavigationRow(
                primaryIcon: NavigationIcon(
                    screen: .introduction,
                    image: .application("introduction"),
                    selectedImage: .application("introduction-pressed"),
                    label: ""
                ),
                firstSecondaryIcon: nil,
                secondSecondaryIcon: nil
            ),
            NavigationRow(
                primaryIcon: NavigationIcon(
                    screen: .buffer,
                    image: .application("buffer"),
                    selectedImage: .application("buffer-pressed"),
                    label: ""
                ),
                firstSecondaryIcon: nil,
                secondSecondaryIcon: nil
            )
        ]
    )
}
