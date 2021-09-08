//
// Reactions App
//


import SwiftUI

extension BalancedReactionMoleculeView {
    struct OneToTwoPyramid: View {
        let atomSize: CGFloat
        let singleAtom: BalancedReaction.Atom
        let doubleAtom: BalancedReaction.Atom
        let showSymbols: Bool

        var body: some View {
            ZStack {
                doubleAtomRow
                singleAtomRow
            }
        }

        private var singleAtomRow: some View {
            VStack(spacing: 0) {
                BalancedReactionMoleculeView.Atom(
                    size: atomSize,
                    atom: singleAtom,
                    showSymbol: showSymbols
                )

                Spacer(minLength: 0)
                    .frame(height: verticalSpacerHeight)
            }
        }

        private var doubleAtomRow: some View {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                    .frame(height: verticalSpacerHeight)

                HStack(spacing: hStackSpacing) {
                    individualDoubleAtom
                    individualDoubleAtom
                }
            }
        }

        private var individualDoubleAtom: some View {
            BalancedReactionMoleculeView.Atom(
                size: atomSize,
                atom: doubleAtom,
                showSymbol: showSymbols
            )
        }

        private var verticalSpacerHeight: CGFloat {
            Self.verticalSpacerSizeToAtomSize * atomSize
        }

        private var hStackSpacing: CGFloat {
            Self.horizontalSpacingToAtomSize * atomSize
        }

        private static let horizontalSpacingToAtomSize: CGFloat = 0.4
        private static let verticalSpacerSizeToAtomSize: CGFloat = 0.6
    }
}

struct OneToTwoPyramid_Previews: PreviewProvider {
    static var previews: some View {
        BalancedReactionMoleculeView.OneToTwoPyramid(
            atomSize: 50,
            singleAtom: .oxygen,
            doubleAtom: .hydrogen,
            showSymbols: true
        )
    }
}
