//
// Reactions App
//


import SwiftUI

extension BurnerSettings {
    fileprivate var maxExtraWidthScale: CGFloat {
        0.5
    }
}

struct FlamesView: View {

    @Binding var temp: CGFloat
    let settings: BurnerSettings

    @State private var flameScale: CGFloat = 0

    var body: some View {
        flames
            .onAppear {
                let animation = Animation.spring(
                    response: 1
                ).repeatForever(autoreverses: true)
                withAnimation(animation) {
                    self.flameScale = 0.1
                }
            }
    }

    private var flames: some View {
        ZStack(alignment: .bottom) {
            smallFlame
                .offset(x: settings.flameWidth)

            smallFlame
                .offset(x: -settings.flameWidth)

            FlameImage()
                .frame(width: largeFlameWidth)
                .scaleEffect(
                    x: 1 + flameScale,
                    y: 1 - flameScale,
                    anchor: .bottom
                )
        }
    }

    private var smallFlame: some View {
        FlameImage()
            .opacity(temp > settings.tripleFlameThreshold ? 1 : 0)
            .animation(.easeIn(duration: 0.25))
            .frame(width: largeFlameWidth * 0.6)
            .scaleEffect(
                x: 1 + flameScale,
                y: 1 - flameScale,
                anchor: .bottom
            )
    }

    private var largeFlameWidth: CGFloat {
        let scale = 1 + (tempFactor * settings.maxExtraWidthScale)
        return settings.flameWidth * scale
    }

    private var tempFactor: CGFloat {
        let numerator = min(temp, settings.maxTemp) - settings.minTemp
        let delta = settings.maxTemp - settings.minTemp
        return numerator / delta
    }
}

struct FlameImage: View {
    var body: some View {
        Image("flame", bundle: .reactionsCore)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct FlamesView_Previews: PreviewProvider {
    static var previews: some View {
        FlamesView(
            temp: .constant(400),
            settings: BurnerSettings(
                standWidth: 100,
                minTemp: 10,
                maxTemp: 20,
                tripleFlameThreshold: 200
            )
        )
        .previewLayout(.iPhoneSELandscape)
    }
}
