//
// Reactions App
//


import SwiftUI

struct BeakerBurner: View {

    @Binding var temp: CGFloat
    let settings: BurnerSettings

    var body: some View {
        ZStack(alignment: .bottom) {
            Image("stand", bundle: .reactionsCore)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: settings.standWidth)

            Image("burner", bundle: .reactionsCore)
                .resizable()
                .frame(width: settings.burnerWidth, height: settings.burnerHeight)

            FlamesView(
                temp: $temp,
                settings: settings
            )
            .offset(y: -settings.burnerHeight)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Beaker stand with flame"))
    }
}

public struct BurnerSettings {

    let standWidth: CGFloat
    let minTemp: CGFloat
    let maxTemp: CGFloat
    let tripleFlameThreshold: CGFloat

    var burnerWidth: CGFloat {
        0.4 * standWidth
    }

    var burnerHeight: CGFloat {
        0.1064 * burnerWidth
    }

    var flameWidth: CGFloat {
        0.18 * burnerWidth
    }
}

struct BeakerBurner_Previews: PreviewProvider {
    static var previews: some View {
        BeakerBurner(
            temp: .constant(100),
            settings: BurnerSettings(
                standWidth: 500,
                minTemp: 100,
                maxTemp: 300,
                tripleFlameThreshold: 100
            )
        )
        .previewLayout(.iPhoneSELandscape)
    }
}
