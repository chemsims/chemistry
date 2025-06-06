//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct EnergyProfileScreen: View {

    init(navigation: NavigationModel<EnergyProfileState>) {
        self.model = navigation.model
    }

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
            Rectangle()
                .edgesIgnoringSafeArea(.all)
                .foregroundColor(model.color(for: nil))

            chartsView(settings: settings)
                .zIndex(1)
            beakyView(settings: settings)
            equationView(settings: settings)
            beakerView(settings: settings)
                .disabled(!model.interactionEnabled)
        }
    }

    private func beakyView(settings: EnergyProfileLayoutSettings) -> some View {
        BeakyOverlay(
            statement: model.statement,
            next: model.next,
            back: model.back,
            nextIsDisabled: !model.canClickNext,
            settings: settings.orderLayoutSettings.beakyGeometrySettings
        )
        .padding(.trailing, settings.orderLayoutSettings.beakyRightPadding)
        .padding(.bottom, settings.orderLayoutSettings.beakyBottomPadding)
    }

    private func chartsView(settings: EnergyProfileLayoutSettings) -> some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                EnergyProfileRateChart(
                    settings: EnergyRateChartSettings(
                        chartSize: settings.chartsSize
                    ),
                    equation: model.rateEquation,
                    currentTempInverse: model.temp2.map { 1 / $0 },
                    highlightChart: model.highlight(element: .linearChart)
                )

                Spacer(minLength: 0)

                EnergyProfileChart(
                    settings: EnergyRateChartSettings(
                        chartSize: settings.chartsSize
                    ),
                    showTemperature: model.temp2 != nil,
                    highlightTop: model.highlight(element: .reactionProfileTop),
                    highlightBottom: model.highlight(element: .reactionProfileBottom),
                    moleculeHighlightColor: model.color(
                        for: [.moleculeChartLabel, .reactionProfileBottom]
                    ),
                    order: model.selectedReaction,
                    chartInput: model.chartInput
                )
                .colorMultiply(model.color(for: [.reactionProfileTop, .reactionProfileBottom]))

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: settings.chartsTopPadding) {
                    BranchMenu(layout: settings.orderLayoutSettings.branchMenu)
                        .zIndex(1)

                    ReactionOrderSelection(
                        isToggled: model.canSetReaction ? $selectReactionIsToggled : .constant(false),
                        selection: $model.selectedReaction,
                        height: settings.selectOrderHeight
                    )
                    .colorMultiply(model.color(for: .reactionToggle))
                    .disabled(!model.canSetReaction)
                }
            }
            .padding(.top, settings.chartsTopPadding)
            .padding(.trailing, settings.chartsTopPadding * 0.5)
            .padding(.leading, settings.chartsLeadingPadding)
            Spacer()
        }
    }

    private func equationView(settings: EnergyProfileLayoutSettings) -> some View {
        VStack {
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: settings.beakerTotalWidth)
                EnergyProfileRateEquation(
                    k1: model.k1,
                    k2: model.k2,
                    ea: model.activationEnergy,
                    t1: model.temp1,
                    t2: model.temp2,
                    maxWidth: settings.equationWidth,
                    maxHeight: settings.equationHeight,
                    highlights: model.highlightedElements
                )
                .padding(.leading, settings.equationLeadingPadding)
                .accessibilityElement(children: .contain)
                Spacer()
            }
        }
    }

    private func beakerView(settings: EnergyProfileLayoutSettings) -> some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: settings.orderLayoutSettings.menuSize)
            EnergyProfileBeaker(
                reactionState: model.reactionState,
                catalystState: model.catalystState,
                selectCatalyst: model.selectCatalyst,
                setCatalystInProgress: model.setCatalystInProgress,
                particleState: model.particleState,
                temp: $model.temp2,
                extraEnergyFactor: model.extraEnergyFactor,
                updateConcentrationC: model.setConcentrationC,
                catalystIsShaking: model.catalystIsShaking,
                canReactToC: model.canReactToC,
                canSelectCatalyst: model.canSelectCatalyst,
                highlightSlider: model.highlight(element: .tempSlider),
                highlightBeaker: model.highlight(element: .beaker),
                highlightCatalyst: model.highlight(element: .catalysts),
                availableCatalysts: model.availableCatalysts,
                usedCatalysts: model.usedCatalysts,
                reactionInput: model.selectedReaction.energyProfileReactionInput,
                catalystColor: model.catalystColor,
                order: model.selectedReaction,
                concentrationC: model.concentrationC,
                chartInput: model.chartInput
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
            .padding(.leading, settings.beakerLeadingPadding)
            Spacer()
        }
    }
}

private struct EnergyProfileLayoutSettings {
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
        1.15 * orderLayoutSettings.chartSize
    }
    var chartsTopPadding: CGFloat {
        orderLayoutSettings.topPadding
    }
    var equationWidth: CGFloat {
        0.95 * availableEquationWidth
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
        beakerWidth + beakerLeadingPadding + orderLayoutSettings.menuSize
    }
    var beakerLeadingPadding: CGFloat {
        0.01 * geometry.size.width
    }
    var equationLeadingPadding: CGFloat {
        0.025 * availableEquationWidth
    }
    var selectOrderHeight: CGFloat {
        0.15 * chartsSize
    }

    var chartsLeadingPadding: CGFloat {
        beakerWidth + beakerLeadingPadding + orderLayoutSettings.menuSize
    }

    private var availableEquationWidth: CGFloat {
        geometry.size.width - beakerTotalWidth - orderLayoutSettings.beakyBoxTotalWidth
    }
}

struct EnergyProfileScreen_Previews: PreviewProvider {
    static var previews: some View {

        
        EnergyProfileScreen(
            navigation: EnergyProfileNavigationViewModel.model(
                EnergyProfileViewModel(),
                persistence: InMemoryEnergyProfilePersistence()
            )
        )
        .previewLayout(.iPadAirLandscape)

        // iPhone 11
        EnergyProfileScreen(
            navigation: EnergyProfileNavigationViewModel.model(
                EnergyProfileViewModel(),
                persistence: InMemoryEnergyProfilePersistence()
            )
        )
        .previewLayout(.fixed(width: 896, height: 414))

        // iPhone SE
        EnergyProfileScreen(
            navigation: EnergyProfileNavigationViewModel.model(
                EnergyProfileViewModel(),
                persistence: InMemoryEnergyProfilePersistence()
            )
        )
        .previewLayout(.fixed(width: 568, height: 320))

        // iPad Mini
        EnergyProfileScreen(
            navigation: EnergyProfileNavigationViewModel.model(
                EnergyProfileViewModel(),
                persistence: InMemoryEnergyProfilePersistence()
            )
        )
        .previewLayout(.fixed(width: 1024, height: 768))

    }
}
