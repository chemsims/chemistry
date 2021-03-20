//
// Reactions App
//


import SwiftUI

struct GaseousReactionScreen: View {

    @ObservedObject var model: GaseousReactionViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlightedElements.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geometry in
                GaseousReactionScreenWithSettings(
                    model: model,
                    settings: GaseousReactionScreenSettings(geometry: geometry)
                )
            }
            .padding(10)
        }
    }
}

private struct GaseousReactionScreenWithSettings: View {

    @ObservedObject var model: GaseousReactionViewModel
    let settings: GaseousReactionScreenSettings

    var body: some View {
        HStack(spacing: 0) {
            LeftStack(model: model, settings: settings)
        }
    }
}

private struct LeftStack: View {

    @ObservedObject var model: GaseousReactionViewModel
    let settings: GaseousReactionScreenSettings

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            PressureBeaker(
                model: model,
                settings: settings.pressureBeakerSettings
            )
        }

    }
}

struct GaseousReactionScreenSettings {
    let geometry: GeometryProxy
    var width: CGFloat {
        geometry.size.width
    }

    var pressureBeakerSettings: PressureBeakerSettings {
        PressureBeakerSettings(width: 0.3 * width)
    }

    var common: AqueousScreenLayoutSettings {
        AqueousScreenLayoutSettings(geometry: geometry)
    }
}

struct GaseousReactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        GaseousReactionScreen(
            model: GaseousReactionViewModel()
        )
        .previewLayout(.iPhone12ProMaxLandscape)
    }
}
