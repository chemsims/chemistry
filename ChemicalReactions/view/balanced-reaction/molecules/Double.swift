//
// Reactions App
//


import SwiftUI

extension BalancedReactionMoleculeView {
    struct Double: View {
        let atomSize: CGFloat
        let atom: BalancedReaction.Atom
        let showSymbol: Bool

        var body: some View {
            HStack(spacing: Self.spacingToAtomSize * atomSize) {
                singleAtom
                singleAtom
            }
        }

        private var singleAtom: some View {
            BalancedReactionMoleculeView.Atom(
                size: atomSize,
                atom: atom,
                showSymbol: showSymbol
            )
        }

        private static let spacingToAtomSize: CGFloat = -0.025
    }
}

struct Double_Previews: PreviewProvider {
    static var previews: some View {
        BalancedReactionMoleculeView.Double(
            atomSize: 20,
            atom: .carbon,
            showSymbol: true
        )
    }
}
