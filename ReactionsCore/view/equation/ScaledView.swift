//
// Reactions App
//

import SwiftUI

// TODO - deprecate this in favour of using the view modifier & extension method below
public struct ScaledView<Content: View>: View {
    let naturalWidth: CGFloat
    let naturalHeight: CGFloat
    let maxWidth: CGFloat?
    let maxHeight: CGFloat?
    let content: () -> Content

    public init(
        naturalWidth: CGFloat,
        naturalHeight: CGFloat,
        maxWidth: CGFloat?,
        maxHeight: CGFloat?,
        content: @escaping () -> Content
    ) {
        self.naturalWidth = naturalWidth
        self.naturalHeight = naturalHeight
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.content = content
    }

    public var body: some View {
        content()
            .scaleEffect(x: scale, y: scale)
    }

    private var scale: CGFloat {
        let xScale = maxWidth.map { $0 / naturalWidth } ?? 1
        let yScale = maxHeight.map { $0 / naturalHeight } ?? 1
        return min(xScale, yScale)
    }
}

extension View {
    public func scaledToFit(
        inWidth width: CGFloat?,
        inHeight height: CGFloat?,
        naturalSize: CGSize
    ) -> some View {
        self.modifier(ScaledViewModifier(
            naturalWidth: naturalSize.width,
            naturalHeight: naturalSize.height,
            maxWidth: width,
            maxHeight: height
        ))
    }
}

private struct ScaledViewModifier: ViewModifier {
    let naturalWidth: CGFloat
    let naturalHeight: CGFloat
    let maxWidth: CGFloat?
    let maxHeight: CGFloat?

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: scale, y: scale)
    }

    private var scale: CGFloat {
        let xScale = maxWidth.map { $0 / naturalWidth } ?? 1
        let yScale = maxHeight.map { $0 / naturalHeight } ?? 1
        return min(xScale, yScale)
    }
}
