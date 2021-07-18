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
                showValues: true,
                highlights: model.highlights
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
            label: { $0.symbol.label },
            disabledOptions: [],
            onSelection: model.next
        )
        .disabled(!model.inputState.isChoosingSubstance)
        .accessibility(sortPriority: 0)
    }

    private var phScale: some View {
        PHOrConcentrationBar(
            model: model,
            components: components,
            layout: layout
        )
        .background(Color.white)
        .colorMultiply(model.highlights.colorMultiply(for: .pHScale))
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
        BarChartOrPhChart(
            model: model,
            components: components,
            layout: layout
        )
        .background(
            Color.white.padding(.trailing, -layout.common.chartYAxisWidth)
        )
        .colorMultiply(model.highlights.colorMultiply(for: .phChart))
    }

    private var beaky: some View {
        BeakyBox(
            statement: model.statement,
            next: model.next,
            back: model.back,
            nextIsDisabled: !model.canGoNext,
            settings: layout.common.beakySettings
        )
    }
}

private struct BarChartOrPhChart: View {

    @ObservedObject var model: IntroScreenViewModel
    @ObservedObject var components: IntroScreenComponents
    let layout: IntroScreenLayout

    var body: some View {
        VStack(spacing: layout.chartToggleSpacing) {
            toggle
            if model.graphView == .concentration {
                barChart
            } else {
                phChart
            }
        }
    }

    private var toggle: some View {
        HStack(spacing: 8) {
            SelectionToggleText(
                text: "Concentration",
                isSelected: model.graphView == .concentration,
                action: {
                    model.graphView = .concentration
                }
            )

            SelectionToggleText(
                text: "pH",
                isSelected: model.graphView == .ph,
                action: {
                    model.graphView = .ph
                }
            )
        }
        .font(.system(size: layout.toggleFontSize))
        .minimumScaleFactor(0.5)
        .frame(height: layout.toggleHeight)
    }

    private var barChart: some View {
        BarChart(
            data: components.barChart.all,
            time: components.fractionSubstanceAdded,
            settings: layout.common.barChartSettings
        )
        .frame(width: layout.barChartTotalWidth, alignment: .trailing)
        .accessibilityElement(children: .contain)
        .accessibility(label: Text("Bar chart showing concentration of molecules as a percentage of the y axis height"))
    }

    private var phChart: some View {
        let barGeo = layout.common.barChartSettings
        return HStack(spacing: layout.common.chartYAxisHSpacing) {
            Text("pH")
                .frame(height: layout.common.chartYAxisWidth)
                .rotationEffect(.degrees(-90))
                .frame(width: layout.common.chartYAxisWidth)

            VStack(spacing: barGeo.chartToAxisSpacing) {
                phChartArea
                Text("Moles added")
                    .frame(height: barGeo.totalAxisHeight)
            }
        }
        .font(.system(size: barGeo.labelFontSize))
        .minimumScaleFactor(0.7)
        .accessibilityElement(children: .combine)
        .accessibility(label: Text("Chart showing moles added vs pH"))
        .accessibility(value: Text(phChartAccessibilityValue))
    }

    private var phChartAccessibilityValue: String {
        if components.fractionSubstanceAdded > 0 {
            let startPh = desiredPHLine.getY(at: 0)
            let endPh = desiredPHLine.getY(at: 1)
            let direction = startPh < endPh ? "increases" : "decreases"
            return "The line \(direction) linearly as moles are added"
        }

        return ""
    }

    private var phChartArea: some View {
        TimeChartView(
            data: [
                TimeChartDataLine(
                    equation: desiredPHLine,
                    headColor: components.substance.type.isAcid ?  RGB.hydrogen.color : RGB.hydroxide.color,
                    haloColor: nil,
                    headRadius: layout.common.chartHeadRadius,
                    showFilledLine: false
                )
            ],
            initialTime: 0,
            currentTime: .constant(
                chartInput.getY(
                    at: components.fractionSubstanceAdded
                )
            ),
            finalTime: 1,
            canSetCurrentTime: false,
            settings: layout.common.phChartSettings(
                minX: 0,
                maxX: 1
            ),
            axisSettings: layout.common.chartAxis
        )
        .frame(square: layout.common.chartSize)
        .animation(nil, value: components.substance)
    }

    // The x-axis represents a log scale, and the pH curve is a linear line.
    // We know the linear line, and from a given pH value we can find the
    // correct x position along this line
    private var chartInput: Equation {
        PhXAxisEquation(
            pHEquation: components.phLine,
            desiredLine: desiredPHLine
        )
    }

    private var desiredPHLine: LinearEquation
    {
        let startY = components.phLine.getY(at: 0)
        let endY = components.phLine.getY(at: 1)

        return LinearEquation(
            x1: 0,
            y1: startY,
            x2: 1,
            y2: endY
        )
    }

    private var safeSubstanceAdded: Equation {
        LinearEquation(
            x1: 0,
            y1: 1,
            x2: CGFloat(components.maxSubstanceCount),
            y2: CGFloat(components.maxSubstanceCount)
        )
    }
}

// The x-axis represents a log scale, and the pH curve is a linear line.
// We know the linear line, and from a given pH value we can find the
// correct x position along this line.
private struct PhXAxisEquation: Equation {

    // pH as a function of substance added
    let pHEquation: Equation

    // The linear line to be plotted as a function of substance added
    let desiredLine: LinearEquation

    func getY(at x: CGFloat) -> CGFloat {
        let pH = pHEquation.getY(at: x)
        return desiredLine.getX(at: pH)
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
        HStack(spacing: layout.toggleHeight) {
            SelectionToggleText(
                text: "Concentration",
                isSelected: !isViewingPh,
                action: { isViewingPh = false }
            )
            .accessibility(hint: Text("Shows concentration values on pH bar"))

            SelectionToggleText(
                text: "pH Scale",
                isSelected: isViewingPh,
                action: { isViewingPh = true }
            )
            .accessibility(hint: Text("Shows pH values on pH bar"))
        }
        .font(.system(size: layout.toggleFontSize))
        .frame(height: layout.toggleHeight)
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
            formatLabel: {
                "[\($0.chargedSymbol.text)]"
            },
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
                    model: IntroScreenViewModel(
                        substancePersistence: InMemoryAcidOrBasePersistence(),
                        namePersistence: InMemoryNamePersistence()
                    ),
                    components: IntroScreenViewModel(
                        substancePersistence: InMemoryAcidOrBasePersistence(),
                        namePersistence: InMemoryNamePersistence()
                    ).components,
                    layout: IntroScreenLayout(
                        common: AcidBasesScreenLayout(
                            geometry: geo,
                            verticalSizeClass: nil,
                            horizontalSizeClass: nil
                        )
                    )
                )
            }
        }
        .padding(5)
        .previewLayout(.iPhone8Landscape)
    }
}
