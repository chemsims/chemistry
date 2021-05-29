//
// Reactions App
//

import SwiftUI

public struct PHMeter: View {

    public init(
        content: TextLine,
        fontSize: CGFloat
    ) {
        self.content = content
        self.fontSize = fontSize
    }

    let content: TextLine
    let fontSize: CGFloat

    public var body: some View {
        GeometryReader { geo in
            PHMeterWithGeometry(
                geometry: PHMeterGeometry(
                    width: geo.size.width,
                    height: geo.size.height
                ),
                content: content,
                fontSize: fontSize
            )
        }
    }
}

extension PHMeter {
    /// Returns true if the stalk of the meter enclosed by `meterSize` overlaps the given `areaSize`
    /// when separated by `meterCenterFromAreaCenter`
    ///
    /// - Parameters:
    ///     - meterSize: Size of the frame of frame enclosing the meter
    ///     - areaSize: Size of the area to check overlap in
    ///     - meterCenterFromAreaCenter:
    ///     Distance from the meter center to the area center. This follows SwiftUI frame of reference.
    ///     i.e., positive width is to the right and positive height is down.
    public static func tipOverlapsArea(
        meterSize: CGSize,
        areaSize: CGSize,
        meterCenterFromAreaCenter: CGSize
    ) -> Bool {
        let geometry = PHMeterGeometry(
            width: meterSize.width,
            height: meterSize.height
        )
        let dHCenters = meterCenterFromAreaCenter.height
        let pHOriginY = dHCenters + (areaSize.height / 2) - (meterSize.height / 2)

        let dWCenters = meterCenterFromAreaCenter.width
        let pHOriginX = dWCenters + (areaSize.width / 2) - (meterSize.width / 2)

        let tipRect = CGRect(
            origin: CGPoint(
                x: pHOriginX + geometry.stalkLeadingPadding,
                y: pHOriginY + geometry.topOfCapY
            ),
            size: CGSize(
                width: geometry.stalkWidth,
                height: geometry.capHeight
            )
        )
        let areaRect = CGRect(origin: .zero, size: areaSize)

        return tipRect.intersects(areaRect)
    }
}

private struct PHMeterWithGeometry: View {
    let geometry: PHMeterGeometry
    let content: TextLine
    let fontSize: CGFloat

    private let indicatorColor = RGB.gray(base: 220).color
    private let stalkTipColor = RGB.gray(base: 50).color

    var body: some View {
        ZStack(alignment: .topLeading) {
            stalk
            indicator
        }
    }

    private var indicator: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: geometry.indicatorCornerRadius)
                .foregroundColor(indicatorColor)

            RoundedRectangle(cornerRadius: geometry.indicatorCornerRadius)
                .stroke(lineWidth: geometry.lineWidth)
                .foregroundColor(stalkTipColor)

            TextLinesView(line: content, fontSize: fontSize)
                .padding(.vertical, geometry.textVerticalPadding)
                .padding(.horizontal, geometry.textHorizontalPadding)
                .frame(height: geometry.indicatorHeight)
        }
        .frame(height: geometry.indicatorHeight)
        .minimumScaleFactor(0.5)
    }

    private var stalk: some View {
        ZStack(alignment: .leading) {
            Group {
                BlurView(
                    style: .systemUltraThinMaterialLight
                )

                Rectangle()
                    .stroke(lineWidth: geometry.lineWidth)
            }
            .frame(
                width: geometry.stalkWidth,
                height: geometry.height - geometry.capHeight
            )

            stalkTip
                .stroke(lineWidth: geometry.lineWidth)

            stalkTip
        }
        .padding(.leading, geometry.stalkLeadingPadding)
        .foregroundColor(stalkTipColor)
    }

    private var stalkTip: some Shape {
        Path { p in
            p.addLines([
                CGPoint(x: 0, y: geometry.topOfCapY),
                CGPoint(x: 0, y: geometry.topOfTipY),
                CGPoint(x: geometry.stalkWidth / 2, y: geometry.height),
                CGPoint(x: geometry.stalkWidth, y: geometry.topOfTipY),
                CGPoint(x: geometry.stalkWidth, y: geometry.topOfCapY)
            ])
        }
    }
}

struct PHMeterGeometry {
    let width: CGFloat
    let height: CGFloat

    var lineWidth: CGFloat {
        min(0.5, 0.015 * width)
    }

    // Height of the indicator which shows the content
    var indicatorHeight: CGFloat {
        min(30, 0.2 * height)
    }

    // Height of the cap (including tip)
    var capHeight: CGFloat {
        0.18 * height
    }

    // Height of just the tip (the triangle part)
    var tipHeight: CGFloat {
        0.35 * capHeight
    }

    var indicatorCornerRadius: CGFloat {
        0.2 * indicatorHeight
    }

    var textHorizontalPadding: CGFloat {
        0.04 * width
    }

    var textVerticalPadding: CGFloat {
        0.05 * indicatorHeight
    }

    var stalkWidth: CGFloat {
        0.08 * width
    }

    var stalkLeadingPadding: CGFloat {
        2 * textHorizontalPadding
    }

    var topOfCapY: CGFloat {
        height - capHeight
    }

    var topOfTipY: CGFloat {
        height - tipHeight
    }
}

struct PHMeter_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Circle()
                .foregroundColor(.blue)
            PHMeter(
                content: "pH: 12",
                fontSize: 20
            )
            .frame(width: 100, height: 140)
            .padding()
        }
    }
}
