//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PHScaleBar: View {

    let topLabels: [TextLine]

    var body: some View {
        GeometryReader { geo in
            PHScaleBarWithGeometry(
                geometry: geo,
                topLabels: topLabels
            )
        }
    }
}

private struct PHScaleBarWithGeometry: View {

    let geometry: GeometryProxy
    let topLabels: [TextLine]
    var bottomLabels: [TextLine] {
        topLabels.reversed()
    }

    var body: some View {
        ZStack(alignment: .leading) {
            PHScaleBarBackground()
            row(elements: topLabels, position: .top)
            row(elements: bottomLabels, position: .bottom)
        }
    }

    private func row(
        elements: [TextLine],
        position: LabelPosition
    ) -> some View {
        ForEach(elements.indices) { i in
            VStack(spacing: 0) {
                if position == .bottom {
                    Spacer()
                }

                element(elements[i], index: i, position: position)

                if position == .top {
                    Spacer()
                }
            }
        }
    }

    private func element(
        _ content: TextLine,
        index: Int,
        position: LabelPosition
    ) -> some View {
        // The offset for the index, adjusted to take into account
        // the element width
        let indexOffset = CGFloat(index + 1) * elementXSpacing
        let adjustedOffset = indexOffset - (elementWidth / 2)

        return VStack(spacing: 1) {
            if position == .top {
                Rectangle()
                    .frame(width: 1, height: tickSize)
            }

            TextLinesView(line: content, fontSize: fontSize)

            if position == .bottom {
                Rectangle()
                    .frame(width: 1, height: tickSize)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.1)
        .frame(width: elementWidth)
        .offset(
            x: adjustedOffset
        )
    }

    private var elementXSpacing: CGFloat {
        geometry.size.width / CGFloat((topLabels.count + 1))
    }

    private var elementWidth: CGFloat {
        0.8 * elementXSpacing
    }

    private var fontSize: CGFloat {
        geometry.size.width * 0.021
    }

    private var tickSize: CGFloat {
        geometry.size.height * 0.06
    }

    enum LabelPosition {
        case top, bottom
    }
}

private struct PHScaleBarBackground: View {

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    gradient: PHScaleColors.gradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(
                    RoundedRectangle(cornerRadius: cornerRadius(geo))
                )

                RoundedRectangle(cornerRadius: cornerRadius(geo))
                    .stroke()
            }
        }
    }

    private func cornerRadius(_ geo: GeometryProxy) -> CGFloat {
        geo.size.height * 0.1
    }
}

struct PHScaleBar_Previews: PreviewProvider {
    static var previews: some View {
        PHScaleBar(
            topLabels: stride(from: 0, through: -14, by: -1).map { "10^\($0)^" }
        )
        .previewLayout(.fixed(width: 400, height: 120))
        .padding()
    }
}
