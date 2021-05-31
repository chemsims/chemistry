//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PHScale: View {

    /// The tick labels on the top of the bar
    /// These will also be reversed and placed along the bottom
    let topTicks: [TextLine]

    /// Label for the top axis
    let topLabel: ColoredText

    /// Label for the bottom axis
    let bottomLabel: ColoredText

    /// Label for the left side of the bar
    let leftLabel: ColoredText

    /// Label for the right side of the bar
    let rightLabel: ColoredText


    /// Value of the top indicator
    let topIndicatorValue: IndicatorValue

    /// Value of the bottom indicator
    let bottomIndicatorValue: IndicatorValue

    /// Minimum tick value on the ticks along the top of the bar
    let topMinTickValue: CGFloat

    /// Maximum tick value on the ticks along the top of the bar
    let topMaxTickValue: CGFloat

    var body: some View {
        GeometryReader { geo in
            PHScaleWithGeometry(
                geometry: PHScaleGeometry(
                    width: geo.size.width,
                    height: geo.size.height,
                    tickCount: topTicks.count,
                    topTickMinValue: topMinTickValue,
                    topTickMaxValue: topMaxTickValue
                ),
                topTicks: topTicks,
                topLabel: topLabel,
                bottomLabel: bottomLabel,
                leftLabel: leftLabel,
                rightLabel: rightLabel,
                topIndicatorValue: topIndicatorValue,
                bottomIndicatorValue: bottomIndicatorValue
            )
        }
    }

    struct IndicatorValue {
        let value: CGFloat
        let text: ColoredText
        let background: Color
    }
}

private struct PHScaleWithGeometry: View {

    let geometry: PHScaleGeometry
    let topTicks: [TextLine]
    let topLabel: ColoredText
    let bottomLabel: ColoredText
    let leftLabel: ColoredText
    let rightLabel: ColoredText
    let topIndicatorValue: PHScale.IndicatorValue
    let bottomIndicatorValue: PHScale.IndicatorValue

    var body: some View {
        ZStack {
            bar

            labelAboveBar(leftLabel, isLeft: true)
            labelAboveBar(rightLabel, isLeft: false)

            labelBesideBar(topLabel, isLeft: true)
            labelBesideBar(bottomLabel, isLeft: false)

            topIndicator
            bottomIndicator
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }

    private func labelAboveBar(_ label: ColoredText, isLeft: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                    .modifyIf(isLeft) { $0.frame(width: geometry.barHorizontalSpacing) }

                TextLinesView(
                    line: label.text,
                    fontSize: geometry.labelsFontSize,
                    color: label.color
                )
                .frame(height: geometry.barVerticalSpacing, alignment: .bottom)

                Spacer()
                    .modifyIf(!isLeft) {
                        $0.frame(width: geometry.barHorizontalSpacing)
                    }
            }
            Spacer()
        }
    }

    private func labelBesideBar(_ label: ColoredText, isLeft: Bool) -> some View {
        VStack(spacing: 0) {
            Spacer()
                .modifyIf(isLeft) { $0.frame(height: geometry.barVerticalSpacing) }

            HStack(spacing: 0) {
                if !isLeft {
                    Spacer()
                }

                TextLinesView(
                    line: label.text,
                    fontSize: geometry.labelsFontSize,
                    color: label.color
                )
                .frame(
                    width: geometry.barHorizontalSpacing,
                    height: geometry.sideLabelsHeight
                )

                if isLeft {
                    Spacer()
                }
            }

            Spacer()
                .modifyIf(!isLeft) { $0.frame(height: geometry.barVerticalSpacing) }
        }
    }

    private var bar: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Spacer()
                PHScaleBar(
                    geometry: geometry,
                    topTicks: topTicks
                )
                .frame(size: geometry.barSize)
                Spacer()
            }
            Spacer()
        }
    }

    private var topIndicator: some View {
        indicator(
            topIndicatorValue,
            position: .top,
            axis: geometry.topIndicatorAxis
        )
    }

    private var bottomIndicator: some View {
        indicator(
            bottomIndicatorValue,
            position: .bottom,
            axis: geometry.bottomIndicatorAxis
        )
    }

    private func indicator(
        _ indicator: PHScale.IndicatorValue,
        position: PHScaleBar.LabelPosition,
        axis: AxisPositionCalculations<CGFloat>
    ) -> some View {
        return VStack(spacing: 0) {
            if position == .bottom {
                Spacer()
            }

            Tooltip(
                text: indicator.text.text,
                color: indicator.text.color,
                background: indicator.background,
                border: .gray,
                fontSize: geometry.indicatorFontSize,
                arrowPosition: position == .top ? .bottom : .top,
                arrowLocation: .inside,
                hasShadow: false
            )
            .frame(size: geometry.indicatorSize)

            if position == .top {
                Spacer()
            }
        }
        .position(
            x: axis.getPosition(at: indicator.value),
            y: geometry.height / 2
        )
    }
}

struct PHScale_Previews: PreviewProvider {

    static var previews: some View {
        bar
            .previewLayout(.fixed(width: 400, height: 110))

        bar
            .previewLayout(.fixed(width: 300, height: 80))

        bar
            .previewLayout(.fixed(width: 700, height: 120))

        bar
            .previewLayout(.fixed(width: 200, height: 100))
    }

    private static var bar: some View {
        PHScale(
            topTicks: ticks,
            topLabel: ColoredText(
                text: "[H]",
                color: RGB.hydrogenDarker.color
            ),
            bottomLabel: ColoredText(
                text: "[OH^-^]",
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
                value: 3,
                text: ColoredText(text: "[H]^+^ = 1x10^-1^", color: .white),
                background: RGB.hydrogen.color
            ),
            bottomIndicatorValue: .init(
                value: 7,
                text: ColoredText(text: "[OH] = 10^2^", color: .white),
                background: RGB.hydroxide.color
            ),
            topMinTickValue: 0,
            topMaxTickValue: 14
        )
    }

    private static let ticks: [TextLine] =
        stride(
            from: 0,
            through: -14,
            by: -1
        ).map { "10^\($0)^" }
}
