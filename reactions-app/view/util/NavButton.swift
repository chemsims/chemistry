//
// Reactions App
//


import SwiftUI

struct NextButton: View {

    let action: () -> Void

    var body: some View {
        GeneralDirectionButton(
            action: action,
            systemImage: "arrowtriangle.right.fill"
        )
    }
}

struct PreviousButton: View {
    let action: () -> Void

    var body: some View {
        GeneralDirectionButton(
            action: action,
            systemImage: "arrowtriangle.left.fill"
        )
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

fileprivate struct GeneralDirectionButton: View {
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

struct NavButtonButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        let delta: CGFloat = 0.1
        let xScale = configuration.isPressed ? 1 + delta : 1
        let yScale = configuration.isPressed ? 1 - delta : 1
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
