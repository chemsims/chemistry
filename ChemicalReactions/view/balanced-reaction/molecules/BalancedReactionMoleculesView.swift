//
// Reactions App
//

import SwiftUI

struct BalancedReactionMoleculeView: View {

    let structure: BalancedReaction.MoleculeStructure
    let atomSize: CGFloat

    @ViewBuilder
    var body: some View {
        switch structure {
        case let .oneToFour(single, quad):
            oneToFour(single: single, quad: quad)

        case let .double(atom):
            double(atom: atom)

        case let .oneToThree(single, triple):
            oneToThree(single: single, triple: triple)

        case let .oneToTwoHorizontal(single, double):
            oneToTwoHorizontal(single: single, double: double)

        case let .oneToTwoPyramid(single, double):
            oneToTwoPyramid(single: single, double: double)
        }
    }

    private func double(atom: BalancedReaction.Atom) -> some View {
        BalancedReactionMoleculeView.Double(
            atomSize: atomSize,
            atom: atom
        )
    }

    private func oneToTwoHorizontal(
        single: BalancedReaction.Atom,
        double: BalancedReaction.Atom
    ) -> some View {
        BalancedReactionMoleculeView.OneToTwoHorizontal(
            atomSize: atomSize,
            singleAtom: single,
            doubleAtom: double
        )
    }

    private func oneToTwoPyramid(
        single: BalancedReaction.Atom,
        double: BalancedReaction.Atom
    ) -> some View {
        BalancedReactionMoleculeView.OneToTwoPyramid(
            atomSize: atomSize,
            singleAtom: single,
            doubleAtom: double
        )
    }

    private func oneToThree(
        single: BalancedReaction.Atom,
        triple: BalancedReaction.Atom
    ) -> some View {
        BalancedReactionMoleculeView.OneToThree(
            atomSize: atomSize,
            singleAtom: single,
            tripleAtom: triple
        )
    }

    private func oneToFour(
        single: BalancedReaction.Atom,
        quad: BalancedReaction.Atom
    ) -> some View {
        BalancedReactionMoleculeView.OneToFour(
            atomSize: atomSize,
            singleAtom: single,
            quadAtom: quad
        )
    }
}

extension BalancedReactionMoleculeView {
    struct Atom: View {
        let size: CGFloat
        let atom: BalancedReaction.Atom

        var body: some View {
            ZStack {
                Circle()
                    .foregroundColor(atom.color)
                
                Text(atom.symbol)
                    .font(.system(size: 0.75 * size))
                    .foregroundColor(.white)
            }
            .frame(square: size)
        }
    }
}

struct BalancedReactionMoleculesView_Previews: PreviewProvider {
    static var previews: some View {
        BalancedReactionMoleculeView(
            structure: BalancedReaction.Molecule.water.structure,
            atomSize: 100
        )
    }
}
