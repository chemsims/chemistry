//
// Reactions App
//

import SwiftUI

public struct OnboardingView: View {

    public init(model: OnboardingViewModel) {
        self.model = model
    }

    let model: OnboardingViewModel

    public var body: some View {
        ZStack {
            GeometryReader { geo in
                OnboardingViewWithGeometry(
                    model: model,
                    geometry: geo
                )
            }
        }
        .modifier(IgnoresKeyboardModifier())
    }
}

private struct OnboardingViewWithGeometry: View {
    @ObservedObject var model: OnboardingViewModel
    let geometry: GeometryProxy

    var body: some View {
        VStack {
                textInput
                    .padding(.top, textInputTopOuterPadding)
                    .opacity(model.isProvidingName ? 1 : 0)
                    .accessibility(sortPriority: 0.9)

            Spacer(minLength: 0)

            VStack(alignment: .leading) {
                bubbleWithBeaky
                    .accessibility(sortPriority: 1)
                next
                    .accessibility(sortPriority: 0.8)
            }

            Spacer(minLength: 0)
        }
        .frame(
            width: geometry.size.width,
            height: geometry.size.height
        )
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
        TextField(
            "Name",
            text: model.nameBinding,
            onCommit:  {
                model.saveName()
            }
        )
        .font(.system(size: beakySettings.bubbleFontSize))
        .padding(.horizontal, textInputLeadingInnerPadding)
        .frame(size: actionSize)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: actionCornerRadius)
                    .foregroundColor(.white)

                RoundedRectangle(cornerRadius: actionCornerRadius)
                    .stroke()
                    .foregroundColor(.gray)
            }
        )
    }

    private var next: some View {
        Button(action: model.next) {
            ZStack {
                RoundedRectangle(cornerRadius: actionCornerRadius)
                    .foregroundColor(Styling.speechBubble)
                
                RoundedRectangle(cornerRadius: actionCornerRadius)
                    .stroke(lineWidth: 1)
                    .foregroundColor(.orangeAccent)
                
                Text(model.nextText)
                    .foregroundColor(.orangeAccent)
            }
            .frame(size: actionSize)
            .font(.system(size: beakySettings.bubbleFontSize))
        }
        .buttonStyle(NavButtonButtonStyle(scaleDelta: 0.02))
    }

    private let actionColor = Color.gray
}

// MARK: Onboarding geometry
extension OnboardingViewWithGeometry {
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

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                OnboardingView(
                    model: .init(
                        namePersistence: InMemoryNamePersistence(),
                        analytics: NoOpGeneralAnalytics()
                    )
                )
                Spacer()
            }
            Spacer()
        }
        .previewLayout(.iPhone12ProMaxLandscape)
    }
}
