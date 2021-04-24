//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AnimatingReactionDefinition: View {

    private let elementWidth: CGFloat = 20
    private let moleculeRadius: CGFloat = 5

    @State private var progress: CGFloat = 0
    @State private var color = Color.black

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topMolecules
            elements
        }
        .onAppear {
            let animation = Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false)
            withAnimation(animation) {
                progress = 1
                color = .red
            }
        }
    }

    private var topMolecules: some View {
        ZStack {
            MoleculeArc(
                alignment: .bottom,
                moleculeRadius: moleculeRadius,
                progress: progress
            )
            .foregroundColor(color)
            .frame(
                width: (4 * elementWidth) + (2 * moleculeRadius),
                height: 4 * moleculeRadius
            )
            .offset(x: (0.5 * elementWidth) - moleculeRadius)
        }
    }

    private var elements: some View {
        HStack(spacing: 0) {
            element("A")
            element("+")
            element("B")
            DoubleSidedArrow(topHighlight: nil, reverseHighlight: nil)
                .frame(width: elementWidth)
            element("C")
            element("+")
            element("D")

        }
    }

    private func element(_ name: String) -> some View {
        FixedText(name)
            .frame(width: elementWidth)
    }
}



struct AnimatingReactionDefinition_Previews: PreviewProvider {
    static var previews: some View {
        AnimatingReactionDefinition()
    }
}
