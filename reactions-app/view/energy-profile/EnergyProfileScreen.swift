//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileScreen: View {

    @ObservedObject var model: EnergyProfileViewModel

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            makeView(
                settings: EnergyProfileLayoutSettings(
                    geometry: geometry,
                    horizontalSize: horizontalSizeClass,
                    verticalSize: verticalSizeClass
                )
            )
        }
    }

    private func makeView(settings: EnergyProfileLayoutSettings) -> some View {
        ZStack {
            chartsView(settings: settings)
            beakyView(settings: settings)
            equationView(settings: settings)
            beakerView(settings: settings)
        }
    }

    private func beakyView(settings: EnergyProfileLayoutSettings) -> some View {
        BeakyOverlay(
            statement: model.statement,
            next: model.next,
            back: model.back,
            settings: settings.orderLayoutSettings
        )
        .padding(.trailing, settings.orderLayoutSettings.beakyRightPadding)
        .padding(.bottom, settings.orderLayoutSettings.beakyBottomPadding)
    }


    private func chartsView(settings: EnergyProfileLayoutSettings) -> some View {
        VStack {
            HStack(spacing: 20) {
                Spacer()
                EnergyProfileRateChart(
                    settings: EnergyRateChartSettings(chartSize: settings.chartsSize),
                    equation: model.rateEquation,
                    currentTempInverse: model.temp2.map { 1 / $0 }
                )

                EnergyProfileChart(
                    settings: EnergyRateChartSettings(chartSize: settings.chartsSize),
                    peakHeightFactor: model.peakHeightFactor,
                    concentrationC: model.concentrationC
                )
            }
            .padding(.top, settings.chartsTopPadding)
            .padding(.trailing, settings.chartsTopPadding * 0.5)
            Spacer()
        }
    }

    private func equationView(settings: EnergyProfileLayoutSettings) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                    .frame(width: settings.beakerWidth)
                EnergyProfileRate(
                    k1: model.k1,
                    k2: model.k2,
                    ea: model.activationEnergy,
                    t1: model.temp1,
                    t2: model.temp2,
                    maxWidth: settings.equationWidth,
                    maxHeight: settings.equationHeight
                )
                .padding(.leading, 0.1 * settings.equationWidth)
                Spacer()
            }
        }
    }

    private func beakerView(settings: EnergyProfileLayoutSettings) -> some View {
        HStack {
            EnergyBeakerWithStand(
                selectedCatalyst: model.selectedCatalyst,
                selectCatalyst: model.selectCatalyst,
                temp: $model.temp2,
                updateConcentrationC: model.setConcentrationC,
                allowReactionsToC: model.allowReactionsToC
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
            .padding(.leading, settings.geometry.size.width * 0.01)
            Spacer()
        }
    }

}

fileprivate struct EnergyProfileLayoutSettings {
    let geometry: GeometryProxy
    let horizontalSize: UserInterfaceSizeClass?
    let verticalSize: UserInterfaceSizeClass?

    var orderLayoutSettings: OrderedReactionLayoutSettings {
        OrderedReactionLayoutSettings(
            geometry: geometry,
            horizontalSize: horizontalSize,
            verticalSize: verticalSize
        )
    }

    var chartsSize: CGFloat {
        1.2 * orderLayoutSettings.chartSize
    }
    var chartsTopPadding: CGFloat {
        orderLayoutSettings.chartsTopPadding
    }
    var equationWidth: CGFloat {
        geometry.size.width / 3.5
    }
    var equationHeight: CGFloat {
        geometry.size.height / 2.3
    }
    var beakerWidth: CGFloat {
        geometry.size.width / 3.4
    }
    var beakerHeight: CGFloat {
        0.95 * geometry.size.height
    }

}

struct EnergyProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileScreen(model: EnergyProfileViewModel())
            .previewLayout(.fixed(width: 568, height: 320))
    }
}
