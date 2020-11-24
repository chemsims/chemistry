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
        ZStack {
            chartsView(settings: settings)
            beakyView(settings: settings)
            equationView(settings: settings)
            beakerView(settings: settings)
        }
    }

    private func beakyView(settings: OrderedReactionLayoutSettings) -> some View {
        BeakyOverlay(
            statement: [],
            next: {},
            back: {},
            settings: settings
        )
        .padding(.trailing, settings.beakyRightPadding)
        .padding(.bottom, settings.beakyBottomPadding)
    }


    private func chartsView(settings: OrderedReactionLayoutSettings) -> some View {
        VStack {
            HStack(spacing: 20) {
                Spacer()
                Rectangle()
                    .stroke()
                    .frame(width: settings.chartSize * 1, height: settings.chartSize * 1)
                    .border(Color.black)
                    .frame(width: settings.chartSize * 1.15, height: settings.chartSize * 1.15, alignment: .topTrailing)
                    .border(Color.black.opacity(0.7))

                Rectangle()
                    .stroke()
                    .frame(width: settings.chartSize * 1, height: settings.chartSize * 1)
                    .border(Color.black)
                    .frame(width: settings.chartSize * 1.15, height: settings.chartSize * 1.15, alignment: .topTrailing)
                    .border(Color.black.opacity(0.7))
            }
            .padding(.top, settings.chartsTopPadding)
            .padding(.trailing, settings.chartsTopPadding * 0.5)
            Spacer()
        }
    }

    private func equationView(settings: OrderedReactionLayoutSettings) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                    .frame(width: totalBeakerWidth(settings: settings))
                EnergyProfileRate(
                    k1: nil,
                    k2: nil,
                    ea: nil,
                    t1: nil,
                    t2: nil,
                    maxWidth: equationWidth(settings: settings),
                    maxHeight: equationHeight(settings: settings)
                )
                    .padding(.leading, 0.1 * equationWidth(settings: settings))
                Spacer()
            }
        }
    }

    private func totalBeakerWidth(settings: OrderedReactionLayoutSettings) -> CGFloat {
        settings.width / 3.4
    }

    private func beakerView(settings: OrderedReactionLayoutSettings) -> some View {
        HStack {
            EnergyBeakerWithStand()
                .frame(width: totalBeakerWidth(settings: settings))
                .frame(height: settings.geometry.size.height * 0.8)
                .padding(.leading, settings.geometry.size.width * 0.01)
            Spacer()
        }
    }

    private func equationWidth(settings: OrderedReactionLayoutSettings) -> CGFloat {
        settings.width / 3.5
    }

    private func equationHeight(settings: OrderedReactionLayoutSettings) -> CGFloat {
        settings.height / 2.3
    }
}

struct EnergyProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileScreen()
            .previewLayout(.fixed(width: 500, height: 300))
    }
}
