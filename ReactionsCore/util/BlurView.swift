//
// Reactions App
//

import SwiftUI

public struct BlurView: UIViewRepresentable {

    public init(style: UIBlurEffect.Style) {
        self.style = style
    }

    let style: UIBlurEffect.Style

    public func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(
            effect: UIBlurEffect(style: style)
        )
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    }
}

struct BlurView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.red, .blue, .purple]),
                startPoint: .leading,
                endPoint: .trailing
            )

            BlurView(style: .systemMaterial)
                .padding()
                .opacity(1)
        }

    }
}
