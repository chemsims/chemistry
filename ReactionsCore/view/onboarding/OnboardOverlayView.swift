//
// Reactions App
//

import SwiftUI

public struct OnboardOverlayView: View {

    public init(model: OnboardingViewModel) {
        self.model = model
    }

    let model: OnboardingViewModel

    public var body: some View {
        ZStack {
            GeometryReader { geo in
                OnboardOverlayWithGeometry(
                    model: model,
                    geometry: geo
                )
            }
        }
        .modifier(IgnoresKeyboardModifier())
    }
}

private struct OnboardOverlayWithGeometry: View {
    @ObservedObject var model: OnboardingViewModel
    let geometry: GeometryProxy

    @State private var isEditing: Bool = false

    var body: some View {
        VStack {
                textInput
                    .padding(.top, textInputTopOuterPadding)
                    .opacity(model.isProvidingName ? 1 : 0)

            Spacer(minLength: 0)

            VStack(alignment: .leading) {
                bubbleWithBeaky
                next
            }

            Spacer(minLength: 0)
        }
        .frame(
            width: geometry.size.width,
            height: geometry.size.height
        )
    }

    private var editingName: some View {
        Text(model.name ?? "")
            .foregroundColor(.orangeAccent)
            .font(.system(size: beakySettings.bubbleFontSize))
            .padding(.horizontal, textInputLeadingInnerPadding)
            .frame(size: actionSize)
            .background(roundedRectBackground(withBorder: false))
            .padding()
            .transition(.opacity)
            .animation(.easeOut(duration: 1), value: isEditing)
    }

    private var bubbleWithBeaky: some View {
        HStack(alignment: .bottom, spacing: 0) {
            SpeechBubble(
                lines: model.statement,
                fontSize: beakySettings.bubbleFontSize
            )
            .frame(
                width: beakySettings.bubbleWidth,
                height: beakySettings.bubbleHeight
            )

            Beaky()
                .frame(height: beakyHeight)
        }
    }

    private var textInput: some View {
        TextField("Name", text: model.nameBinding) { isEditing in
            self.isEditing = isEditing
        } onCommit: {
            model.saveName()
        }
        .padding(.horizontal, textInputLeadingInnerPadding)
        .frame(size: actionSize)
        .background(
            RoundedRectangle(cornerRadius: actionCornerRadius)
                .stroke()
                .foregroundColor(.gray)
        )
    }

    private var next: some View {
        Button(action: model.next) {
            ZStack {
                roundedRectBackground(withBorder: true)

                Text(model.nextText)
                    .foregroundColor(.orangeAccent)
            }
            .frame(size: actionSize)
            .font(.system(size: beakySettings.bubbleFontSize))
        }
        .buttonStyle(NavButtonButtonStyle(scaleDelta: 0.02))
    }

    private func roundedRectBackground(withBorder: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: actionCornerRadius)
                .foregroundColor(Styling.speechBubble)

            if withBorder {
                RoundedRectangle(cornerRadius: actionCornerRadius)
                    .stroke(lineWidth: 1)
                    .foregroundColor(.orangeAccent)
            }
        }
    }

    private let actionColor = Color.gray
}

// MARK: Onboarding geometry
extension OnboardOverlayWithGeometry {
    private var beakySettings: BeakyGeometrySettings {
        BeakyGeometrySettings(
            width: 0.5 * geometry.size.width,
            height: 0.6 * geometry.size.height
        )
    }

    private var beakyHeight: CGFloat {
        0.9 * beakySettings.bubbleHeight
    }

    private var actionSize: CGSize {
        CGSize(
            width: beakySettings.bubbleWidth - beakySettings.bubbleStemWidth,
            height: 0.25 * beakySettings.bubbleHeight
        )
    }

    private var actionCornerRadius: CGFloat {
        0.1 * actionSize.height
    }

    private var textInputLeadingInnerPadding: CGFloat {
        0.05 * actionSize.width
    }

    private var textInputTopOuterPadding: CGFloat {
        0.5 * actionSize.height
    }
}

struct OnboardOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                OnboardOverlayView(model: .init())
                Spacer()
            }
            Spacer()
        }
            .previewLayout(.iPhone12ProMaxLandscape)
    }
}
