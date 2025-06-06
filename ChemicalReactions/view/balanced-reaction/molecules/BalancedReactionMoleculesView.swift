//
// Reactions App
//

import ReactionsCore
import Combine
import SwiftUI

struct BalancedReactionMoleculeView: View {

    /// Molecule view without drag support
    init(
        structure: BalancedReaction.MoleculeStructure,
        atomSize: CGFloat,
        showSymbols: Bool
    ) {
        self.init(
            structure: structure,
            atomSize: atomSize,
            showSymbols: showSymbols,
            dragEnabled: false,
            onDragUpdate: { _ in },
            onDragEnd: { _ in }
        )
    }

    /// Molecule view with drag support
    init(
        structure: BalancedReaction.MoleculeStructure,
        atomSize: CGFloat,
        showSymbols: Bool,
        dragEnabled: Bool,
        onDragUpdate: @escaping (DragState) -> Void,
        onDragEnd: @escaping (CGSize) -> Void
    ) {
        self.structure = structure
        self.atomSize = atomSize
        self.showSymbols = showSymbols
        self.dragEnabled = dragEnabled
        self.onDragUpdate = onDragUpdate
        self.onDragEnd = onDragEnd
    }


    let structure: BalancedReaction.MoleculeStructure
    let atomSize: CGFloat
    let showSymbols: Bool
    let dragEnabled: Bool
    let onDragUpdate: (DragState) -> Void
    let onDragEnd: (CGSize) -> Void

    @GestureState private var dragState = DragState.none
    @State private var offsetForPreviousOffsetCallback = DragState.none

    // NB if we drop support for iOS 13, we can use onChange(of:perform) instead of
    // on receive
    var body: some View {
        mainContent
            .offset(dragState.offset)
            .gesture(dragGesture)
            .onReceive(Just(dragState)) { dragStateValue in
                if dragStateValue != offsetForPreviousOffsetCallback {
                    onDragUpdate(dragStateValue)
                    self.offsetForPreviousOffsetCallback = dragStateValue
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture().updating($dragState) { (gesture, dragState, _) in
            guard dragEnabled else {
                return
            }
            dragState = .dragging(offset: gesture.translation)
        }
        .onEnded { gesture in
            guard dragEnabled else {
                return
            }
            onDragEnd(gesture.translation)
        }
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
                    onDragUpdate: { _ in },
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
