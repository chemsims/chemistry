//
// Reactions App
//

import ReactionsCore
import SwiftUI

struct SharePromptModal: View {

    let layout: SupportStudentsModalSettings
    let showShareSheet: () -> Void
    let dismissPrompt: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                Spacer()
                mainContent
                Spacer()
            }
            Spacer()
        }
    }

    private var mainContent: some View {
        VStack {
            Text("Share app")
                .font(.largeTitle.bold())
                .foregroundColor(.primaryDarkBlue)

            Text(Strings.promptToShare)
            HStack {
                SupportStudentsModal.CapsuleButton(
                    label: "Share",
                    settings: layout,
                    action: showShareSheet
                )
                .foregroundColor(.primaryDarkBlue)
                .frame(size: layout.supportButtonSize)

                SupportStudentsModal.CapsuleButton(
                    label: "Skip",
                    settings: layout,
                    action: dismissPrompt
                )
                .foregroundColor(.gray)
                .frame(size: layout.skipButtonSize)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: layout.cornerRadius)
                .foregroundColor(.white)
                .shadow(radius: 2)
        )
        .frame(width: layout.shareModalWidth)
    }

    private struct CapsuleButton: View {

        let label: String
        let action: () -> Void

        var body: some View {
            Button(action: {}) {
                RoundedRectangle(cornerRadius: 10)

                Text(label)
                    .foregroundColor(.white)
            }
        }
    }
}

struct SharePromptModal_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            SharePromptModal(
                layout: .init(geometry: geo),
                showShareSheet: { },
                dismissPrompt: { }
            )
        }
        .previewLayout(.iPhoneSELandscape)
    }
}
