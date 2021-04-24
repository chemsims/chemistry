//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AnimatingReactionDefinition: View {

    init(coefficients: MoleculeValue<Int>, showMolecules: Bool) {
        self.coefficients = coefficients
        self.showMolecules = showMolecules
        let moleculeNameWidths = coefficients.map(Self.width)
        self.moleculeNameWidths = moleculeNameWidths
        self.elementWidths = [
            moleculeNameWidths.reactantA,
            Self.elementWidth,
            moleculeNameWidths.reactantB,
            Self.elementWidth,
            moleculeNameWidths.productC,
            Self.elementWidth,
            moleculeNameWidths.productD
        ]

    }

    let coefficients: MoleculeValue<Int>
    let showMolecules: Bool

    private let moleculeNameWidths: MoleculeValue<CGFloat>
    private let elementWidths: [CGFloat]

    private static let elementWidth: CGFloat = 20
    private let moleculeRadius: CGFloat = 4

    @State private var progress: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            topMolecules
            elements
            bottomMolecules
        }
    }

    private var topMolecules: some View {
        ZStack(alignment: .leading) {
            if showMolecules {
                molecules(
                    startMolecule: .A,
                    endMolecule: .C,
                    verticalAlignment: .bottom,
                    horizontalAlignment: .leading
                )
                .onAppear {
                    let animation = Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false)
                    withAnimation(animation) {
                        progress = 1
                    }
                }.onDisappear {
                    progress = 0
                }

                molecules(
                    startMolecule: .B,
                    endMolecule: .D,
                    verticalAlignment: .bottom,
                    horizontalAlignment: .leading
                )
            }
        }
        .frame(height: 4 * moleculeRadius)
    }

    private var bottomMolecules: some View {
        ZStack(alignment: .leading) {
            if showMolecules {
                molecules(
                    startMolecule: .D,
                    endMolecule: .B,
                    verticalAlignment: .top,
                    horizontalAlignment: .trailing
                )

                molecules(
                    startMolecule: .C,
                    endMolecule: .A,
                    verticalAlignment: .top,
                    horizontalAlignment: .trailing
                )
            }
        }
        .frame(height: 4 * moleculeRadius)
    }

    private var elements: some View {
        HStack(spacing: 0) {
            element(AqueousMolecule.A)
            element("+")
            element(AqueousMolecule.B)
            DoubleSidedArrow(topHighlight: nil, reverseHighlight: nil)
                .frame(width: Self.elementWidth)
            element(AqueousMolecule.C)
            element("+")
            element(AqueousMolecule.D)
        }
        .font(.system(size: 15))
    }

    private func element(_ molecule: AqueousMolecule) -> some View {
        FixedText(coefficients.string(forMolecule: molecule))
            .frame(width: moleculeNameWidths.value(for: molecule))
    }

    private func element(_ name: String) -> some View {
        FixedText(name)
            .frame(width: Self.elementWidth)
    }

    private static func width(forCoefficient coeff: Int) -> CGFloat {
        coeff == 1 ? elementWidth : 1.5 * elementWidth
    }

    private func moleculeCount(_ molecule: AqueousMolecule) -> MoleculeArc.Count {
        MoleculeArc.Count.fromNumber(coefficients.value(for: molecule)) ?? .four
    }
}

private extension AnimatingReactionDefinition {
    func molecules(
        startMolecule: AqueousMolecule,
        endMolecule: AqueousMolecule,
        verticalAlignment: MoleculeArc.VerticalAlignment,
        horizontalAlignment: MoleculeArc.HorizontalAlignment
    ) -> some View {
        let indices = MoleculeValue(reactantA: 0, reactantB: 2, productC: 4, productD: 6)
        let startMoleculeIndex = indices.value(for: startMolecule)
        let endMoleculeIndex = indices.value(for: endMolecule)

        let startIndex = min(startMoleculeIndex, endMoleculeIndex)
        let span = abs(startMoleculeIndex - endMoleculeIndex)

        return MoleculeArc(
            verticalAlignment: verticalAlignment,
            horizontalAlignment: horizontalAlignment,
            startState: MoleculeArcState(
                count: moleculeCount(startMolecule), rotation: .degrees(60)
            ),
            endState: MoleculeArcState(
                count: moleculeCount(endMolecule), rotation: .degrees(235)
            ),
            moleculeRadius: moleculeRadius,
            progress: progress
        )
        .foregroundColor(progress == 0 ? startMolecule.color : endMolecule.color)
        .frame(
            width: getSpanWidth(startIndex: startIndex, span: span)
        )
        .offset(x: getOffset(startIndex: startIndex))
    }

    private func getOffset(startIndex: Int) -> CGFloat {
        let previous = elementWidths.prefix(startIndex).reduce(0) { $0 + $1 }
        let extra = elementWidths[startIndex] / 2
        return previous  + extra
    }

    private func getSpanWidth(startIndex: Int, span: Int) -> CGFloat {
        let endOffset = getOffset(startIndex: startIndex + span)
        let startOffset = getOffset(startIndex: startIndex)
        return endOffset - startOffset
    }
}

struct AnimatingReactionDefinition_Previews: PreviewProvider {

    static var previews: some View {
        ViewWrapper()
    }

    private struct ViewWrapper: View {
        @State private var showMolecules = true

        var body: some View {
            VStack {
                Button(action: {
                    withAnimation(.easeOut) {
                        showMolecules.toggle()
                    }
                }) {
                    Text("Button")
                }

                AnimatingReactionDefinition(
                    coefficients: MoleculeValue(
                        reactantA: 1,
                        reactantB: 2,
                        productC: 3,
                        productD: 4
                    ),
                    showMolecules: showMolecules
                )
            }
        }
    }
}
