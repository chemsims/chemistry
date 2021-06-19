//
// Reactions App
//

import SwiftUI

public struct Burette: View {
    public init(fill: Color?, indicatorIsActive: Bool, style: Burette.Style = .init()) {
        self.fill = fill
        self.indicatorIsActive = indicatorIsActive
        self.style = style
    }

    let fill: Color?
    let indicatorIsActive: Bool
    let style: Style

    public var body: some View {
        GeometryReader { geo in
            BuretteWithGeometry(
                fill: fill,
                indicatorIsActive: indicatorIsActive,
                style: style,
                geometry: Geometry(width: geo.size.width, height: geo.size.height)
            )
        }
    }
}

private struct BuretteWithGeometry: View {

    let fill: Color?
    let indicatorIsActive: Bool
    let style: Burette.Style
    let geometry: Burette.Geometry

    var body: some View {
        ZStack(alignment: .topLeading) {
            BurettePanel(isActive: indicatorIsActive, style: style, geometry: geometry)
                .frame(height: geometry.panelHeight)

            BuretteTube(fill: fill, style: style, geometry: geometry)
                .frame(width: geometry.tubeWidth, height: geometry.height)
                .padding(.leading, geometry.tubeLeadingPadding)
        }
        .frame(width: geometry.width, height: geometry.height)
    }
}

private struct BuretteTube: View {

    let fill: Color?
    let style: Burette.Style
    let geometry: Burette.Geometry

    var body: some View {
        ZStack(alignment: .topTrailing) {
            container
                .fill()
                .foregroundColor(fill ?? .white)

            container
                .stroke(lineWidth: geometry.lineWidth)
                .foregroundColor(style.lineColor)

            indicators
        }
    }

    private var indicators: some View {
        VStack {
            ForEach(0..<5, id: \.self) { _ in
                Spacer()
                Rectangle()
                    .frame(width: 0.5 * geometry.tubeWidth, height: geometry.lineWidth)
            }
            Spacer()
        }
        .frame(height: 0.6 * geometry.height)
        .foregroundColor(style.lineColor)
    }

    private var container: some Shape {
        TestTubeContainer(
            tipHeightFractionOfHeight: 0.3,
            bottomRadiusFractionOfWidth: 0.15,
            slopeEdgeRadiusFractionOfWidth: 1
        )
    }
}

private struct BurettePanel: View {

    let isActive: Bool
    let style: Burette.Style
    let geometry: Burette.Geometry
    let middlePanelHeightFraction: CGFloat = 0.3
    let cornerRadiusToHeight: CGFloat = 0.1

    var body: some View {
        GeometryReader { geo in
            BurettePanelWithGeometry(
                isActive: isActive,
                style: style,
                geometry: geometry,
                width: geo.size.width,
                height: geo.size.height
            )
        }
    }
}

private struct BurettePanelWithGeometry: View {

    let isActive: Bool
    let style: Burette.Style
    let geometry: Burette.Geometry
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack(alignment: .topTrailing) {
            middlePanel
            Group {
                clampHandle
                clampHandle.rotationEffect(.degrees(180))
            }
            .padding(.trailing, clampHandleRightPadding)
        }
    }

    private var middlePanel: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: middlePanelCornerRadius)
                .fill(Color.white)
            RoundedRectangle(cornerRadius: middlePanelCornerRadius)
                .stroke(lineWidth: geometry.lineWidth)
                .foregroundColor(style.lineColor)

            Circle()
                .foregroundColor(isActive ? style.activeIndicatorColor : style.inactiveIndicatorColor)
                .frame(square: indicatorDiameter)
                .padding(.trailing, indicatorRightPadding)
        }
        .frame(height: middlePanelHeight)
        .offset(y: clampHandleHeight)
    }

    private var clampHandle: some View {
        VStack {
            ConeShape(radius: clampConeRadius)
                .stroke(lineWidth: geometry.lineWidth)
                .rotationEffect(.degrees(180))
                .frame(height: clampHandleHeight)
                .foregroundColor(style.lineColor)

            Spacer()
        }
        .frame(width: clampHandleWidth)
    }

    var middlePanelHeight: CGFloat {
        0.4 * height
    }

    var middlePanelCornerRadius: CGFloat {
        0.1 * middlePanelHeight
    }

    var clampHandleHeight: CGFloat {
        0.5 * (height - middlePanelHeight)
    }

    var clampConeRadius: CGFloat {
        0.1 * clampHandleHeight
    }

    var clampHandleWidth: CGFloat {
        0.18 * width
    }

    var clampHandleRightPadding: CGFloat {
        let circleCenterToRightEdge = indicatorRightPadding + (indicatorDiameter / 2)
        return circleCenterToRightEdge - (clampHandleWidth / 2)
    }

    var indicatorRightPadding: CGFloat {
        0.1 * width
    }

    var indicatorDiameter: CGFloat {
        0.8 * middlePanelHeight
    }
}

extension Burette {

    public struct Style {
        public init() { }

        private static let defaultDropperStyle = Dropper.Style()
        let lineColor: Color = Self.defaultDropperStyle.capColor
        let activeIndicatorColor: Color = Self.defaultDropperStyle.indicatorColor
        let inactiveIndicatorColor: Color = RGB.gray(base: 230).color
    }

    struct Geometry {
        let width: CGFloat
        let height: CGFloat

        var lineWidth: CGFloat {
            0.007 * width
        }

        var tubeWidth: CGFloat {
            0.3 * width
        }

        var tubeLeadingPadding: CGFloat {
            0.1 * width
        }

        var panelHeight: CGFloat {
            0.4 * height
        }

    }
}

struct Burette_Previews: PreviewProvider {
    static var previews: some View {
        Burette(
            fill: nil,
            indicatorIsActive: true,
            style: .init()
        )
        .frame(width: 600, height: 900)
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
