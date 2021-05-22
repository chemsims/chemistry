//
// Reactions App
//

import SwiftUI

public struct PlaceholderTerm: View {

    let value: String?
    let emphasise: Bool

    let boxWidth: CGFloat
    let boxHeight: CGFloat
    let boxPadding: CGFloat

    public init(
        value: String?,
        emphasise: Bool = false,
        boxWidth: CGFloat = EquationSizing.boxWidth,
        boxHeight: CGFloat = EquationSizing.boxHeight,
        boxPadding: CGFloat = EquationSizing.boxPadding
    ) {
        self.value = value
        self.emphasise = emphasise
        self.boxWidth = boxWidth
        self.boxHeight = boxHeight
        self.boxPadding = boxPadding
    }

    public var body: some View {
        if value != nil {
            FixedText(value!)
                .modifier(PlaceholderFraming(boxWidth: boxWidth, boxHeight: boxHeight))
                .animation(.none)
                .foregroundColor(emphasise ? .orangeAccent : .black)
                .accessibility(value: Text(value!))
        } else {
            Box(padding: boxPadding)
                .modifier(PlaceholderFraming(boxWidth: boxWidth, boxHeight: boxHeight))
                .accessibility(value: Text("Place-holder"))
        }
    }
}

private struct PlaceholderFraming: ViewModifier {

    let boxWidth: CGFloat
    let boxHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(
                width: boxWidth,
                height: boxHeight
            )
            .minimumScaleFactor(0.5)
    }
}

private struct Box: View {

    let padding: CGFloat

    var body: some View {
        EquationPlaceholderView()
            .padding(padding)
    }
}

struct EquationPlaceholderView: View {

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .stroke(style: StrokeStyle(
                            lineWidth: 1,
                            lineCap: .square,
                            lineJoin: .round,
                            miterLimit: 0,
                            dash: dash2(geometry),
                            dashPhase: geometry.size.height / 6
                        )
                )
        }
    }

    // The dash array reads, [stroke-width, gap-width, stroke-width, ... ]
    // When the end of the array is met, it loops back to the start
    private func dash2(_ geometry: GeometryProxy) -> [CGFloat] {
        let d1 = geometry.size.width / 6
        let v1 = geometry.size.height / 6
        return [
            d1 + v1,    // Top left corner
            d1,         // Top, left gap
            2 * d1,     // Top edge
            d1,         // Top, right gap
            d1 + v1,    // Top right corner
            v1,         // Right, top gap
            2 * v1,     // Right edge
            v1          // Right, bottom gap
        ]
    }

    private func dash(_ geometry: GeometryProxy) -> [CGFloat] {
        let phase = dashPhase(geometry)
        return [2 * phase, phase]
    }

    private func dashPhase(_ geometry: GeometryProxy) -> CGFloat {
        geometry.size.width / 6
    }

    private func smallHorizontal(_ geometry: GeometryProxy) -> CGFloat {
        geometry.size.width / 6
    }
}

struct EquationPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EquationPlaceholderView()
                .frame(width: 100, height: 100)

            EquationPlaceholderView()
                .frame(width: 100, height: 70)
        }
    }

}
