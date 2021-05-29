//
// Reactions App
//

import SwiftUI

struct PHMeter: View {

    let content: TextLine
    let fontSize: CGFloat

    var body: some View {
        GeometryReader { geo in
            PHMeterWithGeometry(
                geometry: geo,
                content: content,
                fontSize: fontSize
            )
        }
    }
}

private struct PHMeterWithGeometry: View {
    let geometry: GeometryProxy
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
            RoundedRectangle(cornerRadius: indicatorCornerRadius)
                .foregroundColor(indicatorColor)

            RoundedRectangle(cornerRadius: indicatorCornerRadius)
                .stroke()
                .foregroundColor(stalkTipColor)

            TextLinesView(line: content, fontSize: fontSize)
                .padding(.vertical, textVerticalPadding)
                .padding(.horizontal, textHorizontalPadding)
        }
        .frame(height: indicatorHeight)
        .minimumScaleFactor(0.5)
    }

    private var stalk: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .stroke()
                .frame(
                    width: stalkWidth,
                    height: height - capHeight
                )

            stalkTip
                .stroke()

            stalkTip
        }
        .padding(.leading, stalkLeadingPadding)
        .foregroundColor(stalkTipColor)
    }

    private var stalkTip: some Shape {
        Path { p in
            p.addLines([
                CGPoint(x: 0, y: height - capHeight),
                CGPoint(x: 0, y: height - tipHeight),
                CGPoint(x: stalkWidth / 2, y: height),
                CGPoint(x: stalkWidth, y: height - tipHeight),
                CGPoint(x: stalkWidth, y: height - capHeight)
            ])
        }
    }

    private var height: CGFloat {
        geometry.size.height
    }
    

    // Height of the indicator which shows the content
    private var indicatorHeight: CGFloat {
        min(30, 0.2 * height)
    }

    // Height of the cap (including tip)
    private var capHeight: CGFloat {
        0.18 * height
    }

    // Height of just the tip (the triangle part)
    private var tipHeight: CGFloat {
        0.35 * capHeight
    }

    private var indicatorCornerRadius: CGFloat {
        0.2 * indicatorHeight
    }

    private var textHorizontalPadding: CGFloat {
        0.04 * geometry.size.width
    }

    private var textVerticalPadding: CGFloat {
        0.05 * indicatorHeight
    }

    private var stalkWidth: CGFloat {
        min(10, 0.1 * geometry.size.width)
    }

    private var stalkLeadingPadding: CGFloat {
        2 * textHorizontalPadding
    }

}

struct PHMeter_Previews: PreviewProvider {
    static var previews: some View {
        PHMeter(
            content: "pH: 12",
            fontSize: 20
        )
        .frame(width: 100, height: 140)
        .padding()
    }
}
