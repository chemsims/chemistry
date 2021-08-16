//
// Reactions App
//

import SwiftUI

extension BalancedReactionMoleculeView {
    struct OneToFour: View {
        let atomSize: CGFloat
        let singleAtom: BalancedReaction.Atom
        let quadAtom: BalancedReaction.Atom

        var body: some View {
            ZStack {
                quadAtoms
                BalancedReactionMoleculeView.Atom(
                    size: atomSize,
                    atom: singleAtom
                )
            }
        }

        private var quadAtoms: some View {
            VStack(spacing: Self.spacingToAtomSize * atomSize) {
                quadAtomRow
                quadAtomRow
            }
        }

        private var quadAtomRow: some View {
            HStack(spacing: Self.spacingToAtomSize * atomSize) {
                individualQuadAtom
                individualQuadAtom
            }
        }

        private var individualQuadAtom: some View {
            BalancedReactionMoleculeView.Atom(
                size: atomSize,
                atom: quadAtom
            )
        }

        private static let spacingToAtomSize: CGFloat = 0.13
    }
}

struct OneToFour_Previews: PreviewProvider {
    static var previews: some View {
        BalancedReactionMoleculeView.OneToFour(
            atomSize: 50,
            singleAtom: .carbon,
            quadAtom: .hydrogen
        )
    }
}
