//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntroRightStack: View {

    @ObservedObject var model: IntroScreenViewModel
    @ObservedObject var components: IntroScreenComponents
    let layout: IntroScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            topRow
            phScale
            bottomRow
        }
        .frame(width: layout.common.rightColumnWidth)
    }

    private var topRow: some View {
        HStack {
            Spacer()
            IntroEquationView(
                concentration: components.concentrations,
                showValues: true
            )
            .frame(size: layout.equationSize)
            Spacer()
            toggle
        }
    }

    private var toggle: some View {
        DropDownSelectionView(
            title: "Choose a substance",
            options: model.availableSubstances,
            isToggled: model.inputState.isChoosingSubstance ? .constant(true) : .constant(false),
            selection: model.chooseSubstanceBinding,
            height: layout.common.toggleHeight,
            animation: .easeOut(duration: 0.5),
            displayString: { $0.symbol },
            label: { _ in "" }, // TODO
            disabledOptions: [],
            onSelection: model.next
        )
    }

    private var phScale: some View {
        PHOrConcentrationBar(
            model: model,
            components: components,
            layout: layout
        )
    }

    private var bottomRow: some View {
        HStack(spacing: 0) {
            Spacer()
            barChart
            Spacer()
            beaky
        }
    }

    private var barChart: some View {
        BarChart(
            data: components.barChart.all,
            time: components.fractionSubstanceAdded,
            settings: layout.common.barChartSettings
        )
    }

    private var beaky: some View {
        BeakyBox(
            statement: model.statement,
            next: model.next,
            back: model.back,
            nextIsDisabled: false,
            settings: layout.common.beakySettings
        )
    }
}

private struct PHOrConcentrationBar: View {

    @ObservedObject var model: IntroScreenViewModel
    @ObservedObject var components: IntroScreenComponents
    let layout: IntroScreenLayout

    @State private var isViewingPh = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            toggle
            if isViewingPh {
                pHBar
            } else {
                concentrationBar
            }
        }
    }

    private var toggle: some View {
        HStack(spacing: layout.phToggleHeight) {
            SelectionToggleText(
                text: "Concentration",
                isSelected: !isViewingPh,
                action: { isViewingPh = false }
            )

            SelectionToggleText(
                text: "pH Scale",
                isSelected: isViewingPh,
                action: { isViewingPh = true }
            )
        }
        .font(.system(size: layout.phToggleFontSize))
        .frame(height: layout.phToggleHeight)
    }

    private var pHBar: some View {
        generalBar(
            formatTickValue: { "\($0)" },
            formatLabel: { "p\($0.rawValue)" },
            indicatorLabelValue: \.p,
            formatValue: { TextLine($0.str(decimals: 1)) }
        )
    }

    private var concentrationBar: some View {
        generalBar(
            formatTickValue: { "10^-\($0)^"},
            formatLabel: { "[\($0.rawValue)]" },
            indicatorLabelValue: \.concentration,
            formatValue: TextLineUtil.scientific
        )
    }

    /// Returns a bar to use for both pH and concentration.
    ///
    /// - Parameters:
    ///     - formatTickValue: Format the tick values, which run from 0 to 14
    ///     - formatLabel: Format axis label for the given ion
    ///     - indicatorLabelValue: The value to use for the indicator label
    ///     - formatValue: Formats the value for use on the indicator label
    private func generalBar(
        formatTickValue: (Int) -> TextLine,
        formatLabel: (PrimaryIon) -> TextLine,
        indicatorLabelValue: KeyPath<PrimaryIonConcentration, CGFloat>,
        formatValue: (CGFloat) -> TextLine
    ) -> some View {

        let h = components.concentration(ofIon: .hydrogen)
        let oh = components.concentration(ofIon: .hydroxide)

        let hValue = h[keyPath: indicatorLabelValue]
        let ohValue = oh[keyPath: indicatorLabelValue]

        func indicatorLabel(_ ion: PrimaryIon, _ value: TextLine) -> TextLine {
            formatLabel(ion) + ": " + value
        }

        let hLabel = indicatorLabel(.hydrogen, formatValue(hValue))
        let ohLabel = indicatorLabel(.hydroxide, formatValue(ohValue))

        return PHScale(
            topTicks: (0...14).map(formatTickValue),
            topLabel: ColoredText(
                text: formatLabel(.hydrogen),
                color: RGB.hydrogenDarker.color
            ),
            bottomLabel: ColoredText(
                text: formatLabel(.hydroxide),
                color: RGB.hydroxideDarker.color
            ),
            leftLabel: ColoredText(
                text: "Acid",
                color: RGB.hydrogenDarker.color
            ),
            rightLabel: ColoredText(
                text: "Basic",
                color: RGB.hydroxideDarker.color
            ),
            topIndicatorValue: .init(
                value: h.p,
                text: ColoredText(
                    text: hLabel,
                    color: .white
                ),
                background: RGB.hydrogen.color
            ),
            bottomIndicatorValue: .init(
                value: oh.p,
                text: ColoredText(
                    text: ohLabel,
                    color: .white
                ),
                background: RGB.hydroxide.color
            ),
            topLeftTickValue: 0,
            topRightTickValue: 14
        )
        .frame(size: layout.phScaleSize)
        .padding(.bottom, layout.phBarBottomPadding)
        .padding(.top, layout.phBarTopPadding)
    }
}

struct IntroRightStack_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Spacer()
                IntroRightStack(
                    model: IntroScreenViewModel(),
                    components: IntroScreenViewModel().components,
                    layout: IntroScreenLayout(
                        common: AcidBasesScreenLayout(
                            geometry: geo,
                            verticalSizeClass: nil,
                            horizontalSizeClass: nil
                        )
                    )
                )
            }
            .padding(5)
        }
        .previewLayout(.iPhone8Landscape)
    }
}
