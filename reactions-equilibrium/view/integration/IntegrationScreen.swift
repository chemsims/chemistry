//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntegrationScreen: View {

    @ObservedObject var model: IntegrationViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlightedElements.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geometry in
                IntegrationScreenWithGeometry(
                    model: model,
                    settings: IntegrationScreenSettings(
                        geometry: geometry,
                        verticalSizeClass: verticalSizeClass,
                        horizontalSizeClass: horizontalSizeClass
                    )
                )
            }
            .padding(10)
        }
    }
}

private struct IntegrationScreenWithGeometry: View {
    @ObservedObject var model: IntegrationViewModel
    let settings: IntegrationScreenSettings

    var body: some View {
        HStack(spacing: 0) {
            AqueousBeakerView(
                model: model,
                settings: settings.common
            )
            .zIndex(1)
            Spacer()
            ChartStack(
                model: model,
                currentTime: $model.currentTime,
                settings: settings.common
            )
            Spacer()
            IntegrationRightStack(model: model, settings: settings)
        }
    }
}

private struct IntegrationRightStack: View {
    @ObservedObject var model: IntegrationViewModel
    let settings: IntegrationScreenSettings

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            topRow
            Spacer()
            BeakyBox(
                statement: model.statement,
                next: model.next,
                back: model.back,
                nextIsDisabled: false,
                settings: settings.common.beakySettings
            )
        }
    }

    private var topRow: some View {
        HStack(alignment: .top, spacing: settings.chartEquationSpacing) {
            barChart
                .accessibility(sortPriority: 1)
            Spacer()
            VStack(alignment:. trailing) {
                toggle
                Spacer()
                equation
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var toggle: some View {
        ReactionDropDownSelection(
            isToggled: $model.reactionSelectionIsToggled,
            selection: $model.selectedReaction,
            options: AqueousReactionType.allCases,
            onSelection: model.next,
            height: settings.common.reactionToggleHeight
        )
        .frame(
            width: settings.common.reactionToggleHeight,
            height: settings.common.reactionToggleHeight,
            alignment: .topTrailing
        )
        .disabled(model.inputState != .selectReactionType)
        .opacity(model.inputState == .selectReactionType ? 1 : 0.6)
        .colorMultiply(model.highlightedElements.colorMultiply(for: .reactionToggle))
        .zIndex(1)
        .accessibilityElement(children: .contain)
        .accessibility(sortPriority: -1)
    }

    private var equation: some View {
        IntegrationEquationView(model: model)
    }

    private var barChart: some View {
        BarChart(
            data: model.components.barChartData,
            time: model.currentTime,
            settings: settings.barChartGeometry
        )
        .padding(.top, settings.barChartTopPadding)
        .colorMultiply(model.highlightedElements.colorMultiply(for: nil))
    }
}

private extension ReactionComponents {
    var barChartData: [BarChartData] {
        MoleculeValue(builder: { molecule in
            BarChartData(
                label: molecule.rawValue,
                equation: equation.concentration.value(for: molecule),
                color: molecule.color,
                accessibilityLabel: "Bar chart showing concentration of \(molecule.rawValue) in molar"
            )
        }).all
    }
}

struct IntegrationScreenSettings {

    let geometry: GeometryProxy
    let verticalSizeClass: UserInterfaceSizeClass?
    let horizontalSizeClass: UserInterfaceSizeClass?

    var common: EquilibriumAppLayoutSettings {
        EquilibriumAppLayoutSettings(
            geometry: geometry,
            verticalSizeClass: verticalSizeClass,
            horizontalSizeClass: horizontalSizeClass
        )
    }

    var barChartGeometry: BarChartGeometry {
        BarChartGeometry(
            chartWidth: common.chartSize,
            minYValue: 0,
            maxYValue: AqueousReactionSettings.ConcentrationInput.maxAxis,
            barWidthFraction: 0.13,
            fontSizeFraction: ReactionEquilibriumChartsLayoutSettings.fontSizeToChartWidth
        )
    }

    var barChartTopPadding: CGFloat {
        common.chartSelectionHeight
    }

    var chartEquationSpacing: CGFloat {
        0.05 * common.chartSize
    }
}

struct IntegrationScreen_Previews: PreviewProvider {
    static var previews: some View {
        IntegrationScreen(model: IntegrationViewModel())
            .previewLayout(.iPhoneSELandscape)
    }
}
