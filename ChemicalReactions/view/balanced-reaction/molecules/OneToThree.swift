//
// Reactions App
//


import SwiftUI

extension BalancedReactionMoleculeView {
    struct OneToThree: View {

        let atomSize: CGFloat
        let singleAtom: BalancedReaction.Atom
        let tripleAtom: BalancedReaction.Atom
        let showSymbols: Bool

        var body: some View {
            VStack(spacing: Self.bottomAtomsVSpacingToAtomSize * atomSize) {
                VStack(spacing: Self.topAtomsVSpacingToAtomSize * atomSize) {
                    individualTripleAtom
                    individualSingleAtom
                }
                .zIndex(1)
                HStack(spacing: Self.hSpacingToAtomSize * atomSize) {
                    individualTripleAtom
                    individualTripleAtom
                }
            }
        }

        private var tripleStack: some View {
            VStack(spacing: 0.5 * atomSize) {
                individualTripleAtom
                HStack(spacing: Self.hSpacingToAtomSize * atomSize) {
                    individualTripleAtom
                    individualTripleAtom
                }
            }
        }

        private var individualSingleAtom: some View {
            BalancedReactionMoleculeView.Atom(
                size: atomSize,
                atom: singleAtom,
                showSymbol: showSymbols
            )
        }

        private var individualTripleAtom: some View {
            BalancedReactionMoleculeView.Atom(
                size: atomSize,
                atom: tripleAtom,
                showSymbol: showSymbols
            )
        }


        private static let hSpacingToAtomSize: CGFloat = 0.3
        private static let topAtomsVSpacingToAtomSize: CGFloat = -0.15
        private static let bottomAtomsVSpacingToAtomSize: CGFloat = -0.35
    }
}


struct OneToThree_Previews: PreviewProvider {
    static var previews: some View {
        BalancedReactionMoleculeView.OneToThree(
            atomSize: 100,
            singleAtom: .nitrogen,
            tripleAtom: .hydrogen,
            showSymbols: true
        )
    }
}
