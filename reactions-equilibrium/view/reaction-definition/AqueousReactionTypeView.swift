//
// Reactions App
//


import SwiftUI

struct AqueousReactionTypeView: View {

    let type: AqueousReactionType
    let highlightTopArrow: Bool
    let highlightReverseArrow: Bool

    var body: some View {
        HStack(spacing: 5) {
            Text(type.reactantDisplay)
            DoubleSidedArrow(
                topHighlight: highlightTopArrow ? .orangeAccent : nil,
                reverseHighlight: highlightReverseArrow ? .orangeAccent : nil
            )
            Text(type.productDisplay)
        }
    }
}

struct AqueousReactionTypeView_Previews: PreviewProvider {
    static var previews: some View {
        AqueousReactionTypeView(type: .A, highlightTopArrow: false, highlightReverseArrow: true)
    }
}
