//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct Tooltip: View {

    let text: String

    var body: some View {
        Text(text)
            .foregroundColor(Styling.tooltipText)
            .padding()
            .offset(y: -3.5)
            .background(
                card
            )
    }

    private var card: some View {
        ZStack {
            TooltipShape()
                .foregroundColor(Styling.tooltipBackground)
            TooltipShape()
                .stroke()
                .foregroundColor(Styling.tooltipBorder)
        }.shadow(radius: 2)
    }
}

private struct TooltipShape: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let arrowWidth: CGFloat = min(rect.size.width / 4, 7)
        let arrowHeight: CGFloat = min(rect.size.width / 4, 7)
        let cornerRadius: CGFloat = min(rect.size.width / 4, 5)

        let w = rect.size.width
        let h = rect.size.height

        let start = CGPoint(x: 0, y: cornerRadius)

        // Top left corner
        path.move(to: start)
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        path.addLine(to: CGPoint(x: w - cornerRadius, y: 0))

        // Top right corner
        path.addQuadCurve(
            to: CGPoint(x: w, y: cornerRadius),
            control: CGPoint(x: w, y: 0)
        )
        path.addLine(to: CGPoint(x: w, y: h - arrowHeight - cornerRadius))

        // Bottom right corner
        path.addQuadCurve(
            to: CGPoint(x: w - cornerRadius, y: h - arrowHeight),
            control: CGPoint(x: w, y: h - arrowHeight)
        )

        // Bottom edge and arrow
        path.addLines(
            [
                CGPoint(x: w - cornerRadius, y: h - arrowHeight),
                CGPoint(x: (w/2) + arrowWidth, y: h - arrowHeight),
                CGPoint(x: w/2, y: h),
                CGPoint(x: (w/2) - arrowWidth, y: h - arrowHeight),
                CGPoint(x: cornerRadius, y: h-arrowHeight)
            ]
        )

        // Bottom left corner
        path.addQuadCurve(
            to: CGPoint(x: 0, y: h - arrowHeight - cornerRadius),
            control: CGPoint(x: 0, y: h - arrowHeight)
        )
        path.addLine(to: start)

        return path
    }

}

struct Tooltip_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Tooltip(text: "Hello, world!!")

        }
    }
}
