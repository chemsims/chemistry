//
// Reactions App
//

import SwiftUI

public struct NextButton: View {

    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        GeneralDirectionButton(
            action: action,
            systemImage: "arrowtriangle.right.fill"
        )
        .accessibility(label: Text("Next"))
    }
}

public struct PreviousButton: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        GeneralDirectionButton(
            action: action,
            systemImage: "arrowtriangle.left.fill"
        )
        .accessibility(label: Text("Back"))
    }
}

fileprivate extension View {

    @ViewBuilder
    func rightKeyShortcut() -> some View {
        if #available(iOS 14, *) {
            self
                .keyboardShortcut(.rightArrow)
        } else {
            self
        }
    }

    @ViewBuilder
    func leftKeyShortcut() -> some View {
        if #available(iOS 14, *) {
            self
                .keyboardShortcut(.leftArrow)
        } else {
            self
        }
    }
}

private struct GeneralDirectionButton: View {
    let action: () -> Void
    let systemImage: String

    var body: some View {
        CircleIconButton(
            action: action,
            systemImage: systemImage,
            background: Styling.speechBubble,
            border: Styling.speechBubble,
            foreground: Color.black
        )
    }
}

public struct NavButtonButtonStyle: ButtonStyle {

    let scaleDelta: CGFloat
    public init(scaleDelta: CGFloat = 0.1) {
        self.scaleDelta = scaleDelta
    }

    public func makeBody(configuration: Configuration) -> some View {
        let xScale = configuration.isPressed ? 1 + scaleDelta : 1
        let yScale = configuration.isPressed ? 1 - scaleDelta : 1
        return configuration
            .label
            .scaleEffect(x: xScale, y: yScale)
    }

}

struct NextButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            PreviousButton(
                action: {}
            )
            NextButton(
                action: {}
            )
        }
    }
}
