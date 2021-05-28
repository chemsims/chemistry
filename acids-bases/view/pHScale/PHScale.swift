//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PHScale: View {

    /// The tick labels on the top of the bar
    /// These will also be reversed and placed along the bottom
    let topLabels: [TextLine]

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
                    geometry: geo,
                    tickCount: topLabels.count,
                    topTickMinValue: topMinTickValue,
                    topTickMaxValue: topMaxTickValue
                ),
                topLabels: topLabels,
                topIndicatorValue: topIndicatorValue,
                bottomIndicatorValue: bottomIndicatorValue
            )
        }
    }

    struct IndicatorValue {
        let value: CGFloat
        let formatted: TextLine
        let fontColor: Color
        let background: Color
    }
}

private struct PHScaleWithGeometry: View {

    let geometry: PHScaleGeometry
    let topLabels: [TextLine]
    let topIndicatorValue: PHScale.IndicatorValue
    let bottomIndicatorValue: PHScale.IndicatorValue

    var body: some View {
        ZStack {
            bar
            topIndicator
            bottomIndicator
        }
    }

    private var bar: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Spacer()
                PHScaleBar(
                    geometry: geometry,
                    topLabels: topLabels
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
                text: indicator.formatted,
                color: indicator.fontColor,
                background: indicator.background,
                border: .gray,
                fontSize: 10,
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
        PHScale(
            topLabels: labels,
            topIndicatorValue: .init(
                value: 3,
                formatted: "[H] = 10^1^",
                fontColor: .white,
                background: RGB.hydrogen.color
            ),
            bottomIndicatorValue: .init(
                value: 7,
                formatted: "[OH] = 10^2^",
                fontColor: .white,
                background: RGB.hydroxide.color
            ),
            topMinTickValue: 0,
            topMaxTickValue: 14
        )
        .previewLayout(.fixed(width: 400, height: 110))
    }

    private static let labels: [TextLine] =
        stride(
            from: 0,
            through: -14,
            by: -1
        ).map { "10^\($0)^" }
}
