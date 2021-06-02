//
// Reactions App
//

import SwiftUI

struct BlurView: UIViewRepresentable {

    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(
            effect: UIBlurEffect(style: style)
        )
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
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
