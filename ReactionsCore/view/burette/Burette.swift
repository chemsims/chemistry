//
// Reactions App
//

import SwiftUI

public struct Burette: View {
    public init(
        fill: Color?,
        isActive: Bool,
        onTap: @escaping (Burette.TapSpeed) -> Void,
        style: Burette.Style = .init()
    ) {
        self.fill = fill
        self.onTap = onTap
        self.isActive = isActive
        self.style = style
    }

    let fill: Color?
    let isActive: Bool
    let onTap: (TapSpeed) -> Void
    let style: Style

    public var body: some View {
        GeometryReader { geo in
            BuretteWithGeometry(
                fill: fill,
                isActive: isActive,
                onTap: onTap,
                style: style,
                geometry: Geometry(width: geo.size.width, height: geo.size.height)
            )
        }
    }

    public enum TapSpeed {
        case slow, fast
    }
}

private struct BuretteWithGeometry: View {

    let fill: Color?
    let isActive: Bool
    let onTap: (Burette.TapSpeed) -> Void
    let style: Burette.Style
    let geometry: Burette.Geometry

    var body: some View {
        ZStack(alignment: .topLeading) {
            BurettePanel(isActive: isActive, onTap: onTap, style: style, geometry: geometry)
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
                .foregroundColor(.white)

            if fill != nil {
                container
                    .foregroundColor(fill!)
            }

            shading

            container
                .stroke(lineWidth: geometry.lineWidth)
                .foregroundColor(style.lineColor)

            indicators
        }
    }

    private var shading: some View {
        ZStack {
            container
                .foregroundColor(style.darkTubeShade)
                .mask(
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white)
                        container
                            .offset(x: -darkShadeWidth)
                    }
                    .compositingGroup()
                    .luminanceToAlpha()
                )

            container
                .foregroundColor(style.lightTubeShade)
                .mask(
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white)
                        container
                            .offset(x: -lightShadeWidth)
                    }
                    .compositingGroup()
                    .luminanceToAlpha()
                )
                .offset(x: -darkShadeWidth)
        }
        .clipShape(container)
    }

    private var indicators: some View {
        VStack {
            ForEach(0..<5, id: \.self) { _ in
                Spacer()
                Rectangle()
                    .frame(width: tickMarkWidth, height: geometry.lineWidth)
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

    private var tickMarkWidth: CGFloat {
        0.5 * geometry.tubeWidth
    }

    private var darkShadeWidth: CGFloat {
        0.5 * tickMarkWidth
    }

    private var lightShadeWidth: CGFloat {
        tickMarkWidth - darkShadeWidth
    }
}

private struct BurettePanel: View {

    let isActive: Bool
    let onTap: (Burette.TapSpeed) -> Void
    let style: Burette.Style
    let geometry: Burette.Geometry
    let middlePanelHeightFraction: CGFloat = 0.3
    let cornerRadiusToHeight: CGFloat = 0.1

    var body: some View {
        GeometryReader { geo in
            BurettePanelWithGeometry(
                isActive: isActive,
                onTap: onTap,
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
    let onTap: (Burette.TapSpeed) -> Void
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

            indicator
        }
        .frame(height: middlePanelHeight)
        .offset(y: clampHandleHeight)
    }

    private var indicator: some View {
        Circle()
            .foregroundColor(
                isActive ? style.activeIndicatorColor : style.inactiveIndicatorColor
            )
            .gesture(indicatorGesture)
        .frame(square: indicatorDiameter)
        .padding(.trailing, indicatorRightPadding)
        .disabled(!isActive)
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

    private var indicatorGesture: some Gesture {
        let fastGesture = tapGesture(count: 2, speed: .fast)
        let slowGesture = tapGesture(count: 1, speed: .slow)

        return fastGesture.simultaneously(with: slowGesture)
    }

    private func tapGesture(count: Int, speed: Burette.TapSpeed) -> some Gesture {
        TapGesture(count: count)
            .onEnded {
                onTap(speed)
            }
    }
}

extension Burette {

    public struct Style {
        public init() { }

        private static let defaultDropperStyle = Dropper.Style()
        let lineColor: Color = Self.defaultDropperStyle.capColor
        let activeIndicatorColor: Color = Self.defaultDropperStyle.indicatorColor
        let inactiveIndicatorColor: Color = RGB.gray(base: 230).color

        let darkTubeShade = Color.black.opacity(0.1)
        let lightTubeShade = Color.black.opacity(0.05)
    }

    public struct Geometry {
        let width: CGFloat
        let height: CGFloat

        var lineWidth: CGFloat {
            0.007 * width
        }

        var tubeWidth: CGFloat {
            Self.tubeWidthToWidth * width
        }

        var tubeLeadingPadding: CGFloat {
            Self.tubeLeadingPaddingToWidth * width
        }

        var panelHeight: CGFloat {
            0.4 * height
        }

        private static let tubeLeadingPaddingToWidth: CGFloat = 0.1
        private static let tubeWidthToWidth: CGFloat = 0.3

        /// Returns the x position of the center of the tube, from the leading edge for the given `frameWidth`
        public static func tubeCenterX(frameWidth: CGFloat) -> CGFloat {
            let padding = tubeLeadingPaddingToWidth * frameWidth
            let tubeWidth = tubeWidthToWidth * frameWidth
            return padding + (tubeWidth / 2)
        }
    }
}

struct Burette_Previews: PreviewProvider {

    static var previews: some View {
        ViewWrapper()
            .previewLayout(.sizeThatFits)
    }

    private struct ViewWrapper: View {
        @State private var slowTaps = 0
        @State private var fastTaps = 0

        var body: some View {
            VStack {
                Burette(
                    fill: nil,
                    isActive: true,
                    onTap: { speed in
                        if speed == .fast {
                            fastTaps += 1
                        } else {
                            slowTaps += 1
                        }
                    },
                    style: .init()
                )
                .frame(width: 350, height: 600)
                .padding(100)

                Text("\(slowTaps) slow taps")
                Text("\(fastTaps) fast taps")
            }
            .font(.system(size: 50))
        }
    }
}
