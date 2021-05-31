//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntroRightStack: View {

    @ObservedObject var model: IntroScreenViewModel
    let layout: IntroScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            phScale
            Spacer()
           bottomRow
        }
        .frame(width: layout.common.rightColumnWidth)
    }

    private var phScale: some View {
        PHOrConcentrationBar(
            model: model,
            layout: layout
        )
    }

    private var bottomRow: some View {
        HStack(spacing: 0) {
            barChart
            Spacer()
            beaky
        }
    }

    private var barChart: some View {
        BarChart(
            data: model.components.barChart.all,
            time: model.components.fractionSubstanceAdded,
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
    let layout: IntroScreenLayout

    @State private var isViewingPh = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            toggle
            pHBar
        }
    }

    private var pHBar: some View {
        generalBar(
            topTicks: (0...14).map { "\($0)" },
            formattedLabel: { "p\($0.rawValue)" },
            indicatorValue: \.p,
            formattedValue: { TextLine($0.str(decimals: 1)) },
            minTickValue: 0,
            maxTickValue: 14
        )
    }

    private func generalBar(
        topTicks: [TextLine],
        formattedLabel: (PrimaryIon) -> TextLine,
        indicatorValue: KeyPath<PrimaryIonConcentration, CGFloat>,
        formattedValue: (CGFloat) -> TextLine,
        minTickValue: CGFloat,
        maxTickValue: CGFloat
    ) -> some View {

        let h = model.components.concentration(ofIon: .hydrogen)
        let oh = model.components.concentration(ofIon: .hydroxide)

        let hValue = h[keyPath: indicatorValue]
        let ohValue = oh[keyPath: indicatorValue]

        func indicatorLabel(_ ion: PrimaryIon, _ value: TextLine) -> TextLine {
            formattedLabel(ion) + ": " + value
        }

        let hLabel = indicatorLabel(.hydrogen, formattedValue(hValue))
        let ohLabel = indicatorLabel(.hydroxide, formattedValue(ohValue))

        return PHScale(
            topTicks: topTicks,
            topLabel: ColoredText(
                text: formattedLabel(.hydrogen),
                color: RGB.hydrogenDarker.color
            ),
            bottomLabel: ColoredText(
                text: formattedLabel(.hydroxide),
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
                value: hValue,
                text: ColoredText(
                    text: hLabel,
                    color: .white
                ),
                background: RGB.hydrogen.color
            ),
            bottomIndicatorValue: .init(
                value: ohValue,
                text: ColoredText(
                    text: ohLabel,
                    color: .white
                ),
                background: RGB.hydroxide.color
            ),
            topMinTickValue: minTickValue,
            topMaxTickValue: maxTickValue
        )
        .frame(size: layout.phScaleSize)
    }

    private var toggle: some View {
        HStack(spacing: 5) {
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
    }
}

struct IntroRightStack_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Spacer()
                IntroRightStack(
                    model: IntroScreenViewModel(),
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
