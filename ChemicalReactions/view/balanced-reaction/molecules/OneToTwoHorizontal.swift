//
// Reactions App
//


import SwiftUI

extension BalancedReactionMoleculeView {
    struct OneToTwoHorizontal: View {

        let atomSize: CGFloat
        let singleAtom: BalancedReaction.Atom
        let doubleAtom: BalancedReaction.Atom

        var body: some View {
            HStack(spacing: Self.spacingToAtomSize * atomSize) {
                individualDouble
                individualSingle
                    .zIndex(1)
                individualDouble
            }
        }

        private var individualSingle: some View {
            BalancedReactionMoleculeView.Atom(
                size: atomSize,
                atom: singleAtom
            )
        }

        private var individualDouble: some View {
            BalancedReactionMoleculeView.Atom(
                size: atomSize,
                atom: doubleAtom
            )
        }

        private static let spacingToAtomSize: CGFloat = -0.15
    }

}


struct TripleHorizontal_Previews: PreviewProvider {
    static var previews: some View {
        BalancedReactionMoleculeView.OneToTwoHorizontal(
            atomSize: 50,
            singleAtom: .carbon,
            doubleAtom: .oxygen
        )
    }
}
