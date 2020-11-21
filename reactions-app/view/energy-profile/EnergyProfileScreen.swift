//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileScreen: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            makeView(
                settings: OrderedReactionLayoutSettings(
                    geometry: geometry,
                    horizontalSize: horizontalSizeClass,
                    verticalSize: verticalSizeClass
                )
            )
        }
    }

    private func makeView(settings: OrderedReactionLayoutSettings) -> some View {
        Text("foo")
    }
}

struct EnergyProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileScreen()
            .previewLayout(.fixed(width: 500, height: 300))
    }
}
