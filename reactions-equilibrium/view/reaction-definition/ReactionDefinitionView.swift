//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubleReactionDefinitionView: View {

    let reaction: SolubleReactionType
    let runForwardArrow: Bool
    let arrowWidth: CGFloat
    let fontSize: CGFloat

    var body: some View {
        HStack(spacing: 5) {
            Text(reaction.reactantDisplay)
            AnimatingDoubleSidedArrow(
                width: arrowWidth,
                runForward: runForwardArrow,
                runReverse: false
            )
            TextLinesView(lines: [reaction.productText], fontSize: fontSize)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
        .font(.system(size: fontSize))
    }

    private var label: String {
        var base = "\(reaction.reactantLabel) double-sided arrow \(reaction.productLabel)"
        if runForwardArrow {
            base.append(", top arrow is moving to the right")
        }
        return base
    }
}

struct AqueousReactionTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SolubleReactionDefinitionView(
            reaction: .A,
            runForwardArrow: false,
            arrowWidth: 15,
            fontSize: 15
        )
    }
}
