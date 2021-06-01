//
// Reactions App
//

import SwiftUI

public struct ParticleContainer: View {

    let settings: ParticleContainerSettings

    public init(settings: ParticleContainerSettings) {
        self.settings = settings
    }

    public var body: some View {
        GeometryReader { geo in
            EmptyParticleContainer(
                settings: settings,
                geometry: ContainerGeometry(width: geo.size.width, height: geo.size.height)
            )
        }
        .frame(idealWidth: 43, idealHeight: 100)
        .aspectRatio(contentMode: .fit)
    }

    public static let heightToWidth: CGFloat = 2.33
}

public struct ParticleContainerSettings {
    let containerColor: Color
    let labelColor: Color
    let label: String
    let labelFontColor: Color
    let strokeColor: Color
    let strokeLineWidth: CGFloat

    /// Creates a new settings instance
    ///
    /// - Parameters:
    ///     - labelColor: Color of the label
    ///     - label: String on the label
    ///     - labelFontColor: Color of the label string
    ///     - containerColor: Color of the container
    ///     - strokeColor: Color of the container stroke
    ///     - strokeLineWidth: Line width of the container stroke
    public init(
        labelColor: Color,
        label: String,
        labelFontColor: Color,
        containerColor: Color = Color.white,
        strokeColor: Color = Color.black,
        strokeLineWidth: CGFloat = 3
    ) {
        self.containerColor = containerColor
        self.labelColor = labelColor
        self.label = label
        self.labelFontColor = labelFontColor
        self.strokeColor = strokeColor
        self.strokeLineWidth = strokeLineWidth
    }
}

private struct EmptyParticleContainer: View {

    let settings: ParticleContainerSettings
    let geometry: ContainerGeometry

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                ContainerShape()
                    .fill(settings.containerColor, style: FillStyle(eoFill: true, antialiased: true))

                label

                ContainerShape()
                    .stroke(settings.strokeColor, lineWidth: settings.strokeLineWidth)
            }
        }
        .compositingGroup()
    }

    private var label: some View {
        ZStack {
            Rectangle()
                .foregroundColor(settings.labelColor)

            Text(settings.label)
                .frame(
                    width: geometry.labelHeight,
                    height: geometry.width
                )
                .lineLimit(1)
                .rotationEffect(.degrees(-90))
                .foregroundColor(settings.labelFontColor)
        }
        .frame(width: geometry.width, height: geometry.labelHeight)
        .clipped()
    }
}

private struct ContainerShape: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let geometry = ContainerGeometry(
            width: rect.width,
            height: rect.height
        )

        addCurve(
            to: &path, origin: .zero,
            size: CGSize(
                width: rect.width,
                height: geometry.outerCapCurveHeight
            )
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        addCurve(
            to: &path,
            origin: CGPoint(
                x: geometry.innerCapHorizontalPadding,
                y: geometry.innerCapTopPadding
            ),
            size: CGSize(
                width: geometry.innerCapWidth,
                height: geometry.innerCapCurveHeight
            )
        )
        path.closeSubpath()

        return path
    }

    private func addCurve(to path: inout Path, origin: CGPoint, size: CGSize) {
        path.move(to: CGPoint(x: origin.x, y: origin.y + size.height))
        path.addQuadCurve(
            to: CGPoint(x: origin.x + (size.width / 2), y: origin.y),
            control: origin
        )
        path.addQuadCurve(
            to: CGPoint(x: origin.x + size.width, y: origin.y + size.height),
            control: CGPoint(x: origin.x + size.width, y: origin.y)
        )
    }
}

private struct ContainerGeometry {
    let width: CGFloat
    let height: CGFloat

    var outerCapCurveHeight: CGFloat {
        0.212 * height
    }

    var innerCapCurveHeight: CGFloat {
        0.178 * height
    }

    var innerCapWidth: CGFloat {
        width - (2 * innerCapHorizontalPadding)
    }

    var innerCapHorizontalPadding: CGFloat {
        0.0832 * width
    }

    var innerCapTopPadding: CGFloat {
        0.1018 * width
    }

    var labelHeight: CGFloat {
        0.66 * height
    }
}

struct ParticleContainer_Previews: PreviewProvider {
    static var previews: some View {
        ParticleContainer(
            settings: ParticleContainerSettings(
                labelColor: .purple,
                label: "ABCDEF",
                labelFontColor: .white
            )
        )
        .padding()
        .font(.system(size: 300))
        .minimumScaleFactor(0.4)
    }
}
