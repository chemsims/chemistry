//
// Reactions App
//

import SwiftUI

public struct Dropper: View {

    public init(
        style: Dropper.Style = .init(),
        isActive: Bool,
        tubeFill: Color?,
        onTap: @escaping () -> Void
    ) {
        self.style = style
        self.isActive = isActive
        self.onTap = onTap
        self.tubeFill = tubeFill
    }

    let style: Style
    let isActive: Bool
    let onTap: () -> Void
    let tubeFill: Color?

    public var body: some View {
        GeometryReader { geo in
            DropperWithGeometry(
                style: style,
                geometry: Geometry(width: geo.size.width, height: geo.size.height),
                isActive: isActive,
                onTap: onTap,
                tubeFill: tubeFill
            )
        }
        .aspectRatio(Dropper.aspectRatio, contentMode: .fit)
    }
}

private struct DropperWithGeometry: View {

    let style: Dropper.Style
    let geometry: Dropper.Geometry
    let isActive: Bool
    let onTap: () -> Void
    let tubeFill: Color?

    var body: some View {
        VStack(spacing: 0) {
            DropperCapHead(showIndicator: isActive, geometry: geometry, style: style)
                .frame(width: geometry.capGripHeadWidth, height: geometry.capGripHeadHeight)
                .onTapGesture(perform: onTap)
                .disabled(!isActive)

            DropperCapGrip(style: style, geometry: geometry)
                .frame(width: geometry.width, height: geometry.capGripHeight)

            DropperTube(style: style, geometry: geometry, fillColor: tubeFill)
                .frame(width: geometry.tubeWidth, height: geometry.tubeHeight)
        }
    }
}

private struct DropperCapHead: View {
    let showIndicator: Bool
    let geometry: Dropper.Geometry
    let style: Dropper.Style

    private let indicatorPaddingFraction: CGFloat = 0.15

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                head(geo)
                if showIndicator {
                    indicator(geo)
                }
            }
        }
    }

    func head(_ geo: GeometryProxy) -> some View {
        Capsule(style: .circular)
            .frame(width: geo.size.width, height: 2 * geo.size.height)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            .clipped()
            .foregroundColor(style.capColor)
    }

    func indicator(_ geo: GeometryProxy) -> some View {
        let capDiameter = geo.size.width
        let yPosition = capDiameter / 2

        // height below the indicator
        let availableRadiusForHeight = (0.9 * geo.size.height) - yPosition
        let availableDiameterForHeight = 2 * availableRadiusForHeight

        let availableDiameterForWidth = (1 - (2 * indicatorPaddingFraction)) * capDiameter

        let size = min(availableDiameterForHeight, availableDiameterForWidth)

        return Circle()
            .frame(square: size)
            .position(CGPoint(x: geo.size.width / 2, y: yPosition))
            .foregroundColor(style.indicatorColor)
    }
}

private struct DropperCapGrip: View {

    let style: Dropper.Style
    let geometry: Dropper.Geometry
    private let leadingMarkWidthFraction: CGFloat = 0.2
    private let trailingMarks: Int = 6
    private let markVerticalPaddingFraction: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .foregroundColor(style.capShadeColor)

                Rectangle()
                    .stroke(lineWidth: geometry.tubeLineWidth)
                    .foregroundColor(style.capColor)

                gripMarks(geo)
                    .foregroundColor(style.capColor)
            }
        }
    }

    private func gripMarks(_ geometry: GeometryProxy) -> some Shape {
        let topY = geometry.size.height * markVerticalPaddingFraction
        let markHeight = (1 - (2 * markVerticalPaddingFraction)) * geometry.size.height

        let leadingMarkWidth = leadingMarkWidthFraction * geometry.size.width
        let availableTrailingWidth = (geometry.size.width - leadingMarkWidth)
        let trailingMarkWidth = availableTrailingWidth / CGFloat((2 * trailingMarks) + 1)

        let trailingStartX = leadingMarkWidth + trailingMarkWidth

        return Path { p in
            p.addRect(
                CGRect(
                    origin: CGPoint(x: 0, y: topY),
                    size: CGSize(width: leadingMarkWidth, height: markHeight)
                )
            )

            for i in 0..<trailingMarks {
                let originX = trailingStartX + (CGFloat(2 * i) * trailingMarkWidth)
                p.addRect(
                    CGRect(
                        origin: CGPoint(x: originX, y: topY),
                        size: CGSize(width: trailingMarkWidth, height: markHeight)
                    )
                )
            }
        }
    }
}

private struct DropperTube: View {

    let style: Dropper.Style
    let geometry: Dropper.Geometry
    let fillColor: Color?

    var body: some View {
        ZStack {
            if fillColor != nil {
                tubeFill(fillColor!)
            }

            tube
                .stroke(lineWidth: geometry.tubeLineWidth)
                .foregroundColor(style.capColor)
        }
    }

    private var tube: some Shape {
        TestTubeContainer(
            tipHeightFractionOfHeight: 0.2,
            bottomRadiusFractionOfWidth: 0.15,
            slopeEdgeRadiusFractionOfWidth: 0.3
        )
    }

    private func tubeFill(_ color: Color) -> some View {
        tube.fill(color)
    }
}

extension Dropper {

    public static let aspectRatio: CGFloat = 0.5

    public struct Style {
        public init() { }

        let capColor: Color = RGB.gray(base: 120).color
        let capShadeColor: Color = RGB.gray(base: 220).color
        let indicatorColor: Color = .orangeAccent
    }

    public struct Geometry {
        public init(width: CGFloat, height: CGFloat) {
            self.width = width
            self.height = height
        }

        let width: CGFloat
        let height: CGFloat

        var tubeHeight: CGFloat {
            0.6 * height
        }

        var tubeWidth: CGFloat {
            0.35 * width
        }

        var tubeLineWidth: CGFloat {
            0.01 * width
        }

        var capHeight: CGFloat {
            height - tubeHeight
        }

        var capGripHeight: CGFloat {
            0.3 * capHeight
        }

        var capGripHeadHeight: CGFloat {
            capHeight - capGripHeight
        }

        var capGripHeadWidth: CGFloat {
            0.5 * width
        }
    }
}

struct Dropper_Previews: PreviewProvider {

    static let width: CGFloat = 300
    static let height: CGFloat = 600

    static var previews: some View {
        ViewWrapper()
    }

    private struct ViewWrapper: View {

        @State var isBlue = true

        var body: some View {
            Dropper(
                style: .init(),
                isActive: true,
                tubeFill: isBlue ? .blue : .purple,
                onTap: {
                    withAnimation {
                        isBlue.toggle()
                    }
                }
            )
                .frame(width: width, height: height)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
