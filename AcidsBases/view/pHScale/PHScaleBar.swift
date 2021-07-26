//
// Reactions App
//

import SwiftUI
import ReactionsCore

/// A bar showing a PH scale, with custom labels
///
/// The `topLabels` will be spaced out evenly along the bar, with spacing on either end.
/// These will also be reversed and used on the bottom row
struct PHScaleBar: View {

    let geometry: PHScaleGeometry
    let topTicks: [TextLine]
    var bottomTicks: [TextLine] {
        topTicks.reversed()
    }

    var body: some View {
        ZStack(alignment: .leading) {
            PHScaleBarBackground()
            row(elements: topTicks, position: .top)
            row(elements: bottomTicks, position: .bottom)
        }
    }

    private func row(
        elements: [TextLine],
        position: LabelPosition
    ) -> some View {

        var label = ""
        if !elements.isEmpty {
            let first = elements.first!.label
            let last = elements.last!.label
            label = "\(position.rawValue) axis ranging from \(first) on the left to \(last) on the right"
        }

        return ZStack {
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
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
    }

    private func element(
        _ content: TextLine,
        index: Int,
        position: LabelPosition
    ) -> some View {
        // The offset for the index, adjusted to take into account
        // the element width
        let indexOffset = CGFloat(index + 1) * geometry.tickXSpacing
        let adjustedOffset = indexOffset - (geometry.tickLabelWidth / 2)

        return VStack(spacing: 1) {
            if position == .top {
                Rectangle()
                    .frame(width: 1, height: geometry.tickHeight)
            }

            TextLinesView(line: content, fontSize: geometry.tickLabelFontSize)

            if position == .bottom {
                Rectangle()
                    .frame(width: 1, height: geometry.tickHeight)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.1)
        .frame(width: geometry.tickLabelWidth)
        .offset(
            x: adjustedOffset
        )
    }

    enum LabelPosition: String {
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
