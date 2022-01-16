//
// Reactions App
//

import SwiftUI

extension View {

    /// Overlays a slider at the edge of the view.
    ///
    /// - Parameters:
    ///     - value: Binding of the value passed to the slider.
    ///     - minValue: Minimum value of the slider.
    ///     - maxValue: Maximum value of the slider.
    ///     - accessibilityLabel: Accessibility label of the slider
    ///     - position: Position of the slider beside the element.
    ///     - length: Length of the slider if provided. When not provided, the size of the element along the main slider
    ///     axis is used instead. Note that this length if used for the slider itself, while the tooltip will exceed this length.
    ///     - background: Tooltip background color.
    ///     - border: Tooltip border color.
    ///     - includeFill: Whether to include fill in the slider
    ///     - useHaptics: Whether to include haptics in the slider
    ///     - hasShadow: Whether the tooltip has a drop shadow
    public func slider(
        value: Binding<CGFloat>,
        minValue: CGFloat,
        maxValue: CGFloat,
        accessibilityLabel: String,
        position: SliderOverlay.Position = .top,
        length: CGFloat? = nil,
        includeFill: Bool = true,
        useHaptics: Bool = true,
        background: Color = RGB.gray(base: 230).color,
        border: Color = RGB.gray(base: 200).color,
        hasShadow: Bool = false
    ) -> some View {
        self.modifier(
            SliderOverlayModifier(
                value: value,
                minValue: minValue,
                maxValue: maxValue,
                accessibilityLabel: accessibilityLabel,
                length: length,
                position: position,
                background: background,
                border: border,
                includeFill: includeFill,
                useHaptics: useHaptics,
                hasShadow: hasShadow
            )
        )
    }
}

struct SliderOverlayModifier: ViewModifier {

    @Binding var value: CGFloat
    let minValue: CGFloat
    let maxValue: CGFloat
    let accessibilityLabel: String
    let length: CGFloat?
    let position: SliderOverlay.Position
    let background: Color
    let border: Color
    let includeFill: Bool
    let useHaptics: Bool
    let hasShadow: Bool

    public func body(content: Content) -> some View {
        content.overlay(
            SliderOverlay(
                value: $value,
                minValue: minValue,
                maxValue: maxValue,
                length: length,
                position: position,
                background: background,
                border: border,
                includeFill: includeFill,
                useHaptics: useHaptics,
                hasShadow: hasShadow
            )
            .accessibility(label: Text(accessibilityLabel))
        )
    }
}

public struct SliderOverlay: View {

    @Binding var value: CGFloat
    let minValue: CGFloat
    let maxValue: CGFloat
    let length: CGFloat?
    let position: Position
    let background: Color
    let border: Color
    let includeFill: Bool
    let useHaptics: Bool
    let hasShadow: Bool

    public var body: some View {
        GeometryReader { geo in
            SliderOverlayWithGeometry(
                value: $value,
                minValue: minValue,
                maxValue: maxValue,
                lengthOpt: length,
                position: position,
                background: background,
                border: border,
                includeFill: includeFill,
                useHaptics: useHaptics,
                hasShadow: hasShadow,
                geometry: geo
            )
        }
    }

    public enum Position {
        // Left is not supported yet as tooltip doesn't yet support right arrow position
        case top, bottom, right

        var orientation: Orientation {
            self == .top || self == .bottom ? .landscape : .portrait
        }

        var arrowPosition: Tooltip.ArrowPosition {
            switch self {
            case .top: return .bottom
            case .right: return .left
            case .bottom: return .top
            }
        }
    }
}

private struct SliderOverlayWithGeometry: View {

    @Binding var value: CGFloat
    let minValue: CGFloat
    let maxValue: CGFloat
    let lengthOpt: CGFloat?
    let position: SliderOverlay.Position
    let background: Color
    let border: Color
    let includeFill: Bool
    let useHaptics: Bool
    let hasShadow: Bool
    let geometry: GeometryProxy

    var body: some View {
        ZStack {
            BlankTooltip(
                geometry: sliderGeometry.tooltipGeometry,
                background: RGB.gray(base: 230).color,
                border: RGB.gray(base: 100).color,
                hasShadow: hasShadow
            )
            .frame(size: sliderGeometry.tooltipSize)

            CustomSlider(
                value: $value,
                axis: LinearAxis(
                    minValuePosition: sliderGeometry.minValuePosition,
                    maxValuePosition: sliderGeometry.maxValuePosition,
                    minValue: minValue,
                    maxValue: maxValue
                ),
                orientation: position.orientation,
                includeFill: includeFill,
                settings: SliderGeometrySettings(handleWidth: sliderGeometry.handleWidth),
                disabled: false,
                useHaptics: useHaptics
            )
            .frame(width: sliderGeometry.sliderWidth, height: sliderGeometry.sliderHeight)
        }
        .offset(
            x: sliderGeometry.xOffset(geometry: geometry),
            y: sliderGeometry.yOffset(geometry: geometry) + extraYOffset
        )
    }

    // in iOS 13 the slider is aligned at the center of the view
    // rather than the top edge
    private var extraYOffset: CGFloat {
        if isAtLeastIOS14 {
            return 0
        }
        return -geometry.size.height / 2
    }

    private var length: CGFloat {
        if let length = lengthOpt {
            return length
        }
        return position.orientation == .portrait ? geometry.size.height : geometry.size.width
    }

    private var sliderGeometry: SliderOverlayGeometry {
        .init(length: length, position: position)
    }
}

private struct SliderOverlayGeometry {
    let length: CGFloat
    let position: SliderOverlay.Position

    var sliderWidth: CGFloat {
        position.orientation == .landscape ? length : handleWidth
    }

    var sliderHeight: CGFloat {
        position.orientation == .portrait ? length : handleWidth
    }

    var minValuePosition: CGFloat {
        let axisLimitsPadding: CGFloat = 0.1
        if position.orientation == .portrait {
            return (1 - axisLimitsPadding) * length
        }
        return axisLimitsPadding * length
    }

    var maxValuePosition: CGFloat {
        length - minValuePosition
    }

    func xOffset(geometry: GeometryProxy) -> CGFloat {
        switch position {
        case .top, .bottom:
            return (geometry.size.width - tooltipSize.width) / 2
        case .right:
            return geometry.size.width + paddingToElement + tooltipGeometry.arrowHeight
        }
    }

    func yOffset(geometry: GeometryProxy) -> CGFloat {
        switch position {
        case .top: return -tooltipSize.height - paddingToElement - tooltipGeometry.arrowHeight
        case .bottom: return geometry.size.height + paddingToElement + tooltipGeometry.arrowHeight
        case .right: return (geometry.size.height - length) / 2
        }
    }

    var paddingToElement: CGFloat {
        0.2 * handleWidth
    }

    var tooltipInnerPadding: CGFloat {
        0.5 * handleWidth
    }

    var handleWidth: CGFloat {
        0.15 * length
    }

    var tooltipSize: CGSize {
        let lengthFactor: CGFloat = 1.1
        let depthFactor: CGFloat = 1.5

        switch position {
        case .top, .bottom:
            return CGSize(width: lengthFactor * sliderWidth, height: depthFactor * sliderHeight)
        case .right:
            return CGSize(width: depthFactor * sliderWidth, height: lengthFactor * sliderHeight)
        }
    }

    var tooltipGeometry: TooltipGeometry {
        TooltipGeometry(
            size: tooltipSize,
            arrowPosition: position.arrowPosition,
            arrowLocation: .outside
        )
    }
}

extension SliderOverlay {
    /// Returns the total depth of the tooltip, including spacing to the element.
    ///
    /// For example, for a `right` position, the depth would be the width of the tooltip, including the padding to the element.
    /// While for a `top` position, the depth would instead be the height.
    public static func tooltipDepth(
        forLength length: CGFloat,
        position: Position
    ) -> CGFloat {
        let geo = SliderOverlayGeometry(length: length, position: position)
        return geo.tooltipSize.height + geo.tooltipGeometry.arrowHeight + geo.paddingToElement
    }
}

struct SliderOverlay_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 70) {
            ViewWrapper(position: .top)
            ViewWrapper(position: .bottom)
            ViewWrapper(position: .right)
        }
    }

    private struct ViewWrapper: View {
        let position: SliderOverlay.Position
        @State var value: CGFloat = 0.5

        var body: some View {
            Rectangle()
                .foregroundColor(.purple)
                .frame(width: 100, height: 100)
                .opacity(Double(value))
                .slider(
                    value: $value,
                    minValue: 0.5,
                    maxValue: 1,
                    accessibilityLabel: "",
                    position: position
                )
        }
    }
}
