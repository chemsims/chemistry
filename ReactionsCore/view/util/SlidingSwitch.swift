//
// Reactions App
//

import SwiftUI

public struct SlidingSwitch<Value: Equatable>: View {

    @Binding var selected: Value
    let backgroundColor: Color
    let fontColor: Color
    let leftSettings: SwitchOptionSettings<Value>
    let rightSettings: SwitchOptionSettings<Value>

    let feedbackGenerator: UISelectionFeedbackGenerator

    public init(
        selected: Binding<Value>,
        backgroundColor: Color,
        fontColor: Color,
        leftSettings: SwitchOptionSettings<Value>,
        rightSettings: SwitchOptionSettings<Value>
    ) {
        self._selected = selected
        self.backgroundColor = backgroundColor
        self.fontColor = fontColor
        self.leftSettings = leftSettings
        self.rightSettings = rightSettings
        self.feedbackGenerator = UISelectionFeedbackGenerator()
    }

    public var body: some View {
        GeometryReader { geo in
            SlidingSwitchWithGeometry(
                selected: $selected,
                backgroundColor: backgroundColor,
                fontColor: fontColor,
                leftSettings: leftSettings,
                rightSettings: rightSettings,
                feedbackGenerator: feedbackGenerator,
                width: geo.size.width,
                height: geo.size.height
            )
        }
    }
}

public struct SwitchOptionSettings<Value> {
    let value: Value
    let color: Color
    let label: String

    public init(value: Value, color: Color, label: String) {
        self.value = value
        self.color = color
        self.label = label
    }
}

private struct SlidingSwitchWithGeometry<Value: Equatable>: View {

    @Binding var selected: Value
    let backgroundColor: Color
    let fontColor: Color
    let leftSettings: SwitchOptionSettings<Value>
    let rightSettings: SwitchOptionSettings<Value>

    let feedbackGenerator: UISelectionFeedbackGenerator

    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            pill
            face
        }.onTapGesture {
            withAnimation(.easeOut(duration: 0.3)) {
                if isLeft {
                    selected = rightSettings.value
                } else {
                    selected = leftSettings.value
                }
                feedbackGenerator.selectionChanged()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibility(value: Text(isLeft ? leftSettings.label : rightSettings.label))
    }

    private var isLeft: Bool {
        selected == leftSettings.value
    }

    private var settings: SwitchOptionSettings<Value> {
        isLeft ? leftSettings : rightSettings
    }

    private var face: some View {
        ZStack {
            Circle()
                .foregroundColor(settings.color)
            Text(settings.label)
                .fixedSize()
                .foregroundColor(fontColor)
        }
        .frame(width: 0.85 * height, height: 0.9 * height)
        .shadow(radius: 1)
        .position(
            x: isLeft ? leftCircleX : rightCircleX,
            y: height / 2
        )
    }

    private var pill: some View {
        ZStack {
            Circle()
                .position(x: leftCircleX, y: height / 2)
            Rectangle()
                .frame(width: width - circleWidth)
            Circle()
                .position(x: rightCircleX, y: height / 2)
        }
        .foregroundColor(backgroundColor)
    }

    private var leftCircleX: CGFloat {
        height / 2
    }

    private var rightCircleX: CGFloat {
        width - height / 2
    }

    private var circleWidth: CGFloat {
        let maxWidth = width / 2
        return min(maxWidth, height)
    }
}

struct SlidingSwitch_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper()
            .frame(width: 60, height: 30)
    }

    struct ViewWrapper: View {

        @State private var value = 1

        var body: some View {
            SlidingSwitch(
                selected: $value,
                backgroundColor: .gray,
                fontColor: .black,
                leftSettings: SwitchOptionSettings(
                    value: 1,
                    color: .blue,
                    label: "A"
                ),
                rightSettings: SwitchOptionSettings(
                    value: 2,
                    color: .red,
                    label: "B"
                )
            )
            .font(.system(size: 20))
        }
    }
}
