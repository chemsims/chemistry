//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubleReactionDefinitionView: View {

    let reaction: SolubleReactionType
    let direction: AnimatingReactionDefinition.Direction
    let arrowWidth: CGFloat
    let fontSize: CGFloat

    var body: some View {
        HStack(spacing: 5) {
            Text(reaction.reactantDisplay)
            AnimatingDoubleSidedArrow(
                width: arrowWidth,
                direction: direction
            )
            TextLinesView(lines: [reaction.productText], fontSize: fontSize)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
        .font(.system(size: fontSize))
    }

    private var label: String {
        "\(reaction.reactantLabel) double-sided arrow \(reaction.productLabel). \(direction.label ?? "")"
    }
}

struct AqueousReactionTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SolubleReactionDefinitionView(
            reaction: .A,
            direction: .forward,
            arrowWidth: 15,
            fontSize: 15
        )
    }
}
