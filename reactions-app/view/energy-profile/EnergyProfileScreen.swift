//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileScreen: View {

    @ObservedObject var model: EnergyProfileViewModel

    @State private var selectReactionIsToggled = false

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
            HStack(alignment: .top, spacing: 20) {
                Spacer()
                EnergyProfileRateChart(
                    settings: EnergyRateChartSettings(
                        chartSize: settings.chartsSize
                    ),
                    equation: model.rateEquation,
                    currentTempInverse: model.temp2.map { 1 / $0 }
                )

                EnergyProfileChart(
                    settings: EnergyRateChartSettings(
                        chartSize: settings.chartsSize
                    ),
                    peakHeightFactor: model.peakHeightFactor,
                    initialHeightFactor: model.initialHeightFactor,
                    concentrationC: model.concentrationC
                )

                ReactionOrderSelection(
                    isToggled: $selectReactionIsToggled,
                    selection: $model.selectedReaction,
                    height: settings.selectOrderHeight
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
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: settings.beakerWidth)
                EnergyProfileRateEquation(
                    k1: model.k1,
                    k2: model.k2,
                    ea: model.activationEnergy,
                    t1: model.temp1,
                    t2: model.temp2,
                    maxWidth: settings.equationWidth,
                    maxHeight: settings.equationHeight
                )
                .padding(.leading, settings.equationLeadingPadding)
                Spacer()
            }
        }
    }

    private func beakerView(settings: EnergyProfileLayoutSettings) -> some View {
        HStack {
            EnergyProfileBeaker(
                selectedCatalyst: model.selectedCatalyst,
                selectCatalyst: model.selectCatalyst,
                catalystInProgress: model.catalystInProgress,
                setCatalystInProgress: model.setCatalystInProgress,
                emitCatalyst: model.emitCatalyst,
                temp: $model.temp2,
                extraEnergyFactor: model.extraEnergyFactor,
                updateConcentrationC: model.setConcentrationC,
                allowReactionsToC: model.allowReactionsToC,
                catalystIsShaking: model.catalystIsShaking
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
            .padding(.leading, settings.beakerLeadingPadding)
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
        0.9 * (geometry.size.width - beakerTotalWidth - orderLayoutSettings.beakyBoxTotalWidth)
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
    var beakerTotalWidth: CGFloat {
        beakerWidth + beakerLeadingPadding
    }
    var beakerLeadingPadding: CGFloat {
        0.01 * geometry.size.width
    }
    var equationLeadingPadding: CGFloat {
        0.1 * equationWidth
    }
    var selectOrderHeight: CGFloat {
        0.15 * chartsSize
    }
}

struct EnergyProfileScreen_Previews: PreviewProvider {
    static var previews: some View {

        // iPhone 11
        EnergyProfileScreen(model: EnergyProfileViewModel())
            .previewLayout(.fixed(width: 896, height: 414))

        // iPhone SE
        EnergyProfileScreen(model: EnergyProfileViewModel())
            .previewLayout(.fixed(width: 568, height: 320))


        // iPad Mini
        EnergyProfileScreen(model: EnergyProfileViewModel())
            .previewLayout(.fixed(width: 1024, height: 768))

    }
}
