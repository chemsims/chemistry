//
// Reactions App
//

import SwiftUI

extension View {

    /// Overlays a slider beside the view.
    ///
    /// - Parameters:
    ///     - value: Binding of the value passed to the slider.
    ///     - minValue: Minimum value of the slider.
    ///     - maxValue: Maximum value of the slider.
    ///     - position: Position of the slider beside the element.
    ///     - length: Length of the slider if provided. When not provided, the size of the element along the main slider
    ///     axis is used instead. Note that this length if used for the slider itself, while the tooltip will exceed this length.
    ///     - background: Tooltip background color.
    ///     - border: Tooltip border color.
    ///     - includeFill: Whether to include fill in the slider
    ///     - useHaptics: Whether to include haptics in the slider
    public func slider(
        value: Binding<CGFloat>,
        minValue: CGFloat,
        maxValue: CGFloat,
        position: SliderOverlay.Position = .top,
        length: CGFloat? = nil,
        includeFill: Bool = true,
        useHaptics: Bool = true,
        background: Color = RGB.gray(base: 230).color,
        border: Color = RGB.gray(base: 150).color
    ) -> some View {
        self.modifier(
            SliderOverlayModifier(
                value: value,
                minValue: minValue,
                maxValue: maxValue,
                length: length,
                position: position,
                background: background,
                border: border,
                includeFill: includeFill,
                useHaptics: useHaptics
            )
        )
    }
}

struct SliderOverlayModifier: ViewModifier {

    @Binding var value: CGFloat
    let minValue: CGFloat
    let maxValue: CGFloat
    let length: CGFloat?
    let position: SliderOverlay.Position
    let background: Color
    let border: Color
    let includeFill: Bool
    let useHaptics: Bool

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
                useHaptics: useHaptics
            )
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
    let geometry: GeometryProxy

    var body: some View {
        ZStack {
            BlankTooltip(
                geometry: tooltipGeometry,
                background: RGB.gray(base: 230).color,
                border: RGB.gray(base: 100).color,
                hasShadow: true
            )
            .frame(size: tooltipSize)

            CustomSlider(
                value: $value,
                axis: AxisPositionCalculations(
                    minValuePosition: minValuePosition,
                    maxValuePosition: maxValuePosition,
                    minValue: minValue,
                    maxValue: maxValue
                ),
                orientation: position.orientation,
                includeFill: includeFill,
                settings: SliderGeometrySettings(handleWidth: handleWidth),
                disabled: false,
                useHaptics: useHaptics
            )
            .frame(width: sliderWidth, height: sliderHeight)
        }
        .offset(x: xOffset, y: yOffset)
    }

    private var length: CGFloat {
        if let length = lengthOpt {
            return length
        }
        return position.orientation == .portrait ? geometry.size.height : geometry.size.width
    }

    private var sliderWidth: CGFloat {
        position.orientation == .landscape ? length : handleWidth
    }

    private var sliderHeight: CGFloat {
        position.orientation == .portrait ? length : handleWidth
    }

    private var minValuePosition: CGFloat {
        let axisLimitsPadding: CGFloat = 0.1
        if position.orientation == .portrait {
            return (1 - axisLimitsPadding) * length
        }
        return axisLimitsPadding * length
    }

    private var maxValuePosition: CGFloat {
        length - minValuePosition
    }

    private var xOffset: CGFloat {
        switch position {
        case .top, .bottom:
            return (geometry.size.width - tooltipSize.width) / 2
        case .right:
            return geometry.size.width + paddingToElement + tooltipGeometry.arrowHeight
        }
    }

    private var yOffset: CGFloat {
        switch position {
        case .top: return -tooltipSize.height - paddingToElement - tooltipGeometry.arrowHeight
        case .bottom: return geometry.size.height + paddingToElement + tooltipGeometry.arrowHeight
        case .right: return (geometry.size.height - length) / 2
        }
    }

    private var paddingToElement: CGFloat {
        0.2 * handleWidth
    }

    private var tooltipInnerPadding: CGFloat {
        0.5 * handleWidth
    }

    private var handleWidth: CGFloat {
        0.15 * length
    }

    private var tooltipSize: CGSize {
        let lengthFactor: CGFloat = 1.1
        let depthFactor: CGFloat = 1.5

        switch position {
        case .top, .bottom:
            return CGSize(width: lengthFactor * sliderWidth, height: depthFactor * sliderHeight)
        case .right:
            return CGSize(width: depthFactor * sliderWidth, height: lengthFactor * sliderHeight)
        }
    }

    private var tooltipGeometry: TooltipGeometry {
        TooltipGeometry(
            size: tooltipSize,
            arrowPosition: position.arrowPosition,
            arrowLocation: .outside
        )
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
                    position: position
                )
        }
    }
}
