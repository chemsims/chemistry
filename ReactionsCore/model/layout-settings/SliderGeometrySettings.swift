//
// Reactions App
//


import CoreGraphics

public struct SliderGeometrySettings {

    public let handleWidth: CGFloat
    public let handleThickness: CGFloat
    public let handleCornerRadius: CGFloat
    public let barThickness: CGFloat

    public init(handleWidth: CGFloat) {
        self.init(
            handleWidth: handleWidth,
            handleThickness: 0.5 * handleWidth,
            handleCornerRadius: 0.125 * handleWidth,
            barThickness: 0.094 * handleWidth
        )
    }

    public init(
        handleWidth: CGFloat,
        handleThickness: CGFloat,
        handleCornerRadius: CGFloat,
        barThickness: CGFloat
    ) {
        self.handleWidth = handleWidth
        self.handleThickness = handleThickness
        self.handleCornerRadius = handleCornerRadius
        self.barThickness = barThickness
    }

    public func updating(
        handleWidth: CGFloat? = nil,
        handleThickness: CGFloat? = nil,
        handleCornerRadius: CGFloat? = nil,
        barThickness: CGFloat? = nil
    ) -> SliderGeometrySettings {
        SliderGeometrySettings(
            handleWidth: handleWidth ?? self.handleWidth,
            handleThickness: handleThickness ?? self.handleThickness,
            handleCornerRadius: handleCornerRadius ?? self.handleCornerRadius,
            barThickness: barThickness ?? self.barThickness
        )
    }
}
