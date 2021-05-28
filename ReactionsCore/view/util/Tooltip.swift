//
// Reactions App
//

import SwiftUI

public struct Tooltip: View {

    public init(
        text: TextLine,
        color: Color,
        background: Color,
        border: Color,
        fontSize: CGFloat,
        arrowPosition: ArrowPosition,
        arrowLocation: ArrowLocation,
        hasShadow: Bool = true
    ) {
        self.text = text
        self.color = color
        self.background = background
        self.border = border
        self.fontSize = fontSize
        self.arrowPosition = arrowPosition
        self.arrowLocation = arrowLocation
        self.hasShadow = hasShadow
    }

    let text: TextLine
    let color: Color
    let background: Color
    let border: Color
    let fontSize: CGFloat
    let arrowPosition: ArrowPosition
    let arrowLocation: ArrowLocation
    let hasShadow: Bool

    public var body: some View {
        GeometryReader { geo in
            TooltipWithGeometry(
                text: text,
                color: color,
                background: background,
                border: border,
                fontSize: fontSize,
                hasShadow: hasShadow,
                geometry: TooltipGeometry(
                    size: geo.size,
                    arrowPosition: arrowPosition,
                    arrowLocation: arrowLocation
                )
            )
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    public enum ArrowPosition {
        case top, left, bottom
    }

    public enum ArrowLocation {
        case inside, outside
    }
}

private struct TooltipWithGeometry: View {

    let text: TextLine
    let color: Color
    let background: Color
    let border: Color
    let fontSize: CGFloat
    let hasShadow: Bool
    let geometry: TooltipGeometry

    var body: some View {
        ZStack {
            card
            textView
        }
    }

    private var textView: some View {
        TextLinesView(
            line: text,
            fontSize: fontSize,
            color: color
        )
        .frame(width: geometry.textWidth, height: geometry.textHeight)
        .offset(x: geometry.textXOffset, y: geometry.textYOffset)
    }

    private var card: some View {
        ZStack {
            TooltipShape(geometry: geometry)
                .foregroundColor(background)
            TooltipShape(geometry: geometry)
                .stroke()
                .foregroundColor(border)
        }
        .shadow(radius: hasShadow ? 2 : 0)
    }
}

private struct TooltipShape: Shape {
    let geometry: TooltipGeometry

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Top Left corner
        path.move(to: geometry.topLeft.offset(dx: 0, dy: geometry.cornerRadius))
        path.addQuadCurve(
            to: geometry.topLeft.offset(dx: geometry.cornerRadius, dy: 0),
            control: geometry.topLeft
        )

        // Top arrow
        if geometry.arrowPosition == .top {
            path.addLine(
                to: CGPoint(
                    x: (rect.width - geometry.arrowWidth) / 2,
                    y: geometry.topEdge
                )
            )
            path.addLine(
                to: CGPoint(
                    x: rect.width / 2,
                    y: geometry.topEdge - geometry.arrowHeight
                )
            )
            path.addLine(
                to: CGPoint(
                    x: (rect.width + geometry.arrowWidth) / 2,
                    y: geometry.topEdge
                )
            )
        }

        // Top edge
        path.addLine(to: geometry.topRight.offset(dx: -geometry.cornerRadius, dy: 0))

        // Top right corner
        path.addQuadCurve(
            to: geometry.topRight.offset(dx: 0, dy: geometry.cornerRadius),
            control: geometry.topRight
        )

        // Right edge
        path.addLine(to: geometry.bottomRight.offset(dx: 0, dy: -geometry.cornerRadius))

        // Bottom right corner
        path.addQuadCurve(
            to: geometry.bottomRight.offset(dx: -geometry.cornerRadius, dy: 0),
            control: geometry.bottomRight
        )

        // Bottom arrow
        if geometry.arrowPosition == .bottom {
            path.addLine(
                to: CGPoint(x: (rect.width + geometry.arrowWidth) / 2, y: geometry.bottomEdge)
            )
            path.addLine(to: CGPoint(x: rect.width / 2, y: geometry.bottomEdge + geometry.arrowHeight))
            path.addLine(to: CGPoint(x: (rect.width - geometry.arrowWidth) / 2, y: geometry.bottomEdge))
        }

        // Bottom edge
        path.addLine(to: geometry.bottomLeft.offset(dx: geometry.cornerRadius, dy: 0))

        // Bottom left corner
        path.addQuadCurve(
            to: geometry.bottomLeft.offset(dx: 0, dy: -geometry.cornerRadius),
            control: geometry.bottomLeft
        )

        if geometry.arrowPosition == .left {
            path.addLine(
                to: CGPoint(x: geometry.leftEdge, y: (rect.height + geometry.arrowWidth) / 2)
            )
            path.addLine(
                to: CGPoint(
                    x: geometry.leftEdge - geometry.arrowHeight,
                    y: rect.height / 2
                )
            )
            path.addLine(
                to: CGPoint(x: geometry.leftEdge, y: (rect.height - geometry.arrowWidth) / 2)
            )
        }

        path.closeSubpath()

        return path
    }
}

private struct TooltipGeometry {
    let size: CGSize
    let arrowPosition: Tooltip.ArrowPosition
    let arrowLocation: Tooltip.ArrowLocation

    var arrowWidth: CGFloat {
        if arrowPosition == .bottom {
            return 0.2 * size.width
        }
        return 0.5 * size.height
    }

    var arrowHeight: CGFloat {
        let ideal = 0.5 * arrowWidth
        if arrowPosition == .bottom {
            return min(ideal, 0.5 * size.height)
        }
        return min(ideal, 0.5 * size.width)
    }

    let lineWidth: CGFloat = 1

    var cornerRadius: CGFloat {
        min(size.width / 4, 5)
    }

    var topLeft: CGPoint {
        CGPoint(x: leftEdge, y: topEdge)
    }

    var topRight: CGPoint {
        CGPoint(x: size.width, y: topEdge)
    }

    var bottomRight: CGPoint {
        CGPoint(x: size.width, y: bottomEdge)
    }

    var bottomLeft: CGPoint {
        CGPoint(x: leftEdge, y: bottomEdge)
    }

    var leftEdge: CGFloat {
        if arrowPosition == .left && arrowLocation == .inside {
            return arrowHeight
        }
        return 0
    }

    var bottomEdge: CGFloat {
        if arrowPosition == .bottom && arrowLocation == .inside {
            return size.height - arrowHeight
        }
        return size.height
    }

    var topEdge: CGFloat {
        if arrowPosition == .top && arrowLocation == .inside {
            return arrowHeight
        }
        return 0
    }

    var textWidth: CGFloat {
        size.width - leftEdge - (2 * lineWidth)
    }

    var textHeight: CGFloat {
        bottomEdge - topEdge - (2 * lineWidth)
    }

    var textYOffset: CGFloat {
        -(size.height - bottomEdge - topEdge) / 2
    }

    var textXOffset: CGFloat {
        leftEdge / 2
    }
}


struct Tooltip_Previews: PreviewProvider {

    static let width: CGFloat = 120
    static let height: CGFloat = 40

    static var arrowPositions: [Tooltip.ArrowPosition] = [.top, .left, .bottom]
    static var arrowLocations: [Tooltip.ArrowLocation] = [.inside, .outside]

    static var arrows: [(Tooltip.ArrowPosition, Tooltip.ArrowLocation)] {
        arrowPositions.flatMap { pos in
            arrowLocations.map { loc in
                (pos, loc)
            }
        }
    }

    static var previews: some View {
        VStack(spacing: 50) {
            ForEach(arrows.indices) { i in
                Tooltip(
                    text: "Hello, world!!",
                    color: .black,
                    background: .gray,
                    border: .darkGray,
                    fontSize: 15,
                    arrowPosition: arrows[i].0,
                    arrowLocation: arrows[i].1
                )
                .frame(width: width, height: height)
            }
        }
        .padding(50)
        .previewLayout(.sizeThatFits)
    }
}
