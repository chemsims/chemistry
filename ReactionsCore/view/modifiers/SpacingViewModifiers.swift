//
// Reactions App
//

import SwiftUI

public enum VerticalSpacingAlignment {
    case top, center, bottom
}

public enum HorizontalSpacingAlignment {
    case leading, center, trailing
}

extension View {

    /// Adds horizontal and vertical spacing around a view
    public func spacing(
        horizontalAlignment: HorizontalSpacingAlignment,
        verticalAlignment: VerticalSpacingAlignment
    ) -> some View {
        self
            .horizontalSpacing(alignment: horizontalAlignment)
            .verticalSpacing(alignment: verticalAlignment)
    }

    /// Adds horizontal spacing around the view
    public func horizontalSpacing(alignment: HorizontalSpacingAlignment) -> some View {
        self.modifier(HSpacingViewModifier(alignment: alignment))
    }

    /// Adds vertical spacing around the view
    public func verticalSpacing(alignment: VerticalSpacingAlignment) -> some View {
        self.modifier(VSpacingViewModifier(alignment: alignment))
    }
}

private struct VSpacingViewModifier: ViewModifier {

    let alignment: VerticalSpacingAlignment

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if alignment == .bottom || alignment == .center {
                Spacer(minLength: 0)
            }
            content
            if alignment == .top || alignment == .center {
                Spacer(minLength: 0)
            }
        }
    }
}

private struct HSpacingViewModifier: ViewModifier {

    let alignment: HorizontalSpacingAlignment

    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            if alignment == .trailing || alignment == .center {
                Spacer(minLength: 0)
            }
            content
            if alignment == .leading || alignment == .center {
                Spacer(minLength: 0)
            }
        }
    }
}

struct SpacingViewModifiers_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.red)
                .frame(square: 100)
                .verticalSpacing(alignment: .bottom)

            Rectangle()
                .foregroundColor(.purple)
                .frame(square: 100)
                .verticalSpacing(alignment: .top)

            Rectangle()
                .foregroundColor(.green)
                .frame(square: 100)
                .horizontalSpacing(alignment: .leading)

            Rectangle()
                .foregroundColor(.orange)
                .frame(square: 100)
                .horizontalSpacing(alignment: .trailing)

            Rectangle()
                .foregroundColor(.black)
                .frame(square: 100)
                .horizontalSpacing(alignment: .trailing)
                .verticalSpacing(alignment: .top)

            Rectangle()
                .foregroundColor(.blue)
                .frame(square: 100)
                .verticalSpacing(alignment: .bottom)
                .horizontalSpacing(alignment: .leading)
        }
    }
}
