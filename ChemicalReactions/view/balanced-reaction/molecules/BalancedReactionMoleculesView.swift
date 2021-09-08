//
// Reactions App
//

import SwiftUI

struct BalancedReactionMoleculeView: View {

    let structure: BalancedReaction.MoleculeStructure
    let atomSize: CGFloat
    let showSymbols: Bool
    let dragEnabled: Bool
    let onDragEnd: (CGSize) -> Void

    @GestureState private var offset: CGSize = .zero

    var body: some View {
        mainContent
            .offset(offset)
            .gesture(DragGesture().updating($offset) { (gesture, offsetState, _) in
                guard dragEnabled else {
                    return
                }
                offsetState = gesture.translation
            }
            .onEnded { gesture in
                onDragEnd(gesture.translation)
            })
    }

    @ViewBuilder
    private var mainContent: some View {
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
            atom: atom,
            showSymbol: showSymbols
        )
    }

    private func oneToTwoHorizontal(
        single: BalancedReaction.Atom,
        double: BalancedReaction.Atom
    ) -> some View {
        BalancedReactionMoleculeView.OneToTwoHorizontal(
            atomSize: atomSize,
            singleAtom: single,
            doubleAtom: double,
            showSymbols: showSymbols
        )
    }

    private func oneToTwoPyramid(
        single: BalancedReaction.Atom,
        double: BalancedReaction.Atom
    ) -> some View {
        BalancedReactionMoleculeView.OneToTwoPyramid(
            atomSize: atomSize,
            singleAtom: single,
            doubleAtom: double,
            showSymbols: showSymbols
        )
    }

    private func oneToThree(
        single: BalancedReaction.Atom,
        triple: BalancedReaction.Atom
    ) -> some View {
        BalancedReactionMoleculeView.OneToThree(
            atomSize: atomSize,
            singleAtom: single,
            tripleAtom: triple,
            showSymbols: showSymbols
        )
    }

    private func oneToFour(
        single: BalancedReaction.Atom,
        quad: BalancedReaction.Atom
    ) -> some View {
        BalancedReactionMoleculeView.OneToFour(
            atomSize: atomSize,
            singleAtom: single,
            quadAtom: quad,
            showSymbols: showSymbols
        )
    }
}

extension BalancedReactionMoleculeView {
    struct Atom: View {
        let size: CGFloat
        let atom: BalancedReaction.Atom
        let showSymbol: Bool

        var body: some View {
            ZStack {
                Circle()
                    .foregroundColor(atom.color)

                if showSymbol {
                    Text(atom.symbol)
                        .font(.system(size: 0.75 * size))
                        .foregroundColor(.white)
                        .transition(.identity)
                }
            }
            .frame(square: size)
        }
    }
}

struct BalancedReactionMoleculesView_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper()
    }

    private struct ViewWrapper: View {
        @State private var showSymbol = true

        var body: some View {
            VStack {
                BalancedReactionMoleculeView(
                    structure: BalancedReaction.Molecule.water.structure,
                    atomSize: 100,
                    showSymbols: showSymbol,
                    dragEnabled: true,
                    onDragEnd: { _ in }
                )
                .animation(.linear(duration: 1))

                Button(action: {
                    showSymbol.toggle()
                }) {
                    Text("Toggle symbol")
                }
            }
        }
    }
}
