//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AnimatingReactionDefinition: View {

    let coefficients: MoleculeValue<Int>
    let showMolecules: Bool
    let topArrowHighlight: Color?
    let bottomArrowHighlight: Color?

    var body: some View {
        GeometryReader { geo in
            AnimatingReactionDefinitionWithGeometry(
                coefficients: coefficients,
                showMolecules: showMolecules,
                topArrowHighlight: topArrowHighlight,
                bottomArrowHighlight: bottomArrowHighlight,
                geometry: geo
            )
        }
    }
}

private struct AnimatingReactionDefinitionWithGeometry: View {

    let coefficients: MoleculeValue<Int>
    let showMolecules: Bool
    let topArrowHighlight: Color?
    let bottomArrowHighlight: Color?

    @State private var progress: CGFloat = 0

    let geometry: GeometryProxy


    var body: some View {
        VStack(alignment: .leading, spacing: vSpacing) {
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
        .frame(height:  moleculeFrameHeight)
    }

    private var elements: some View {
        HStack(spacing: 0) {
            element(AqueousMolecule.A)
            plus
            element(AqueousMolecule.B)
            if showMolecules {
                AnimatingDoubleSidedArrow(
                    topHighlight: .orangeAccent,
                    bottomHighlight: .orangeAccent,
                    width: arrowWidth
                )
            } else {
                DoubleSidedArrow(
                    topHighlight: topArrowHighlight,
                    reverseHighlight: bottomArrowHighlight
                )
                .frame(width: arrowWidth)
            }
            element(AqueousMolecule.C)
            plus
            element(AqueousMolecule.D)
        }
        .font(.system(size: fontSize))
        .frame(height: textHeight)
        .minimumScaleFactor(0.75)
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
        .frame(height: moleculeFrameHeight)
    }

    private func element(_ molecule: AqueousMolecule) -> some View {
        FixedText(coefficients.string(forMolecule: molecule))
            .frame(width: elementWidth)
            .animation(nil)
    }

    private var plus: some View {
        FixedText("+")
            .frame(width: plusWidth)
    }
}


extension AnimatingReactionDefinitionWithGeometry {

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
                count: moleculeCount(endMolecule), rotation: .degrees(295)
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


    private func moleculeCount(_ molecule: AqueousMolecule) -> MoleculeArc.Count {
        MoleculeArc.Count.fromNumber(coefficients.value(for: molecule)) ?? .four
    }

    private func getSpanWidth(startIndex: Int, span: Int) -> CGFloat {
        let endOffset = getOffset(startIndex: startIndex + span)
        let startOffset = getOffset(startIndex: startIndex)
        return endOffset - startOffset
    }

    private func getOffset(startIndex: Int) -> CGFloat {
        let previous = elementWidths.prefix(startIndex).reduce(0) { $0 + $1 }
        let extra = elementWidths[startIndex] / 2
        return previous  + extra
    }
}

extension AnimatingReactionDefinitionWithGeometry {
    var width: CGFloat {
        geometry.size.width
    }
    var height: CGFloat {
        geometry.size.height
    }
    var fontSize: CGFloat {
        0.18 * height
    }
    var elementWidth: CGFloat {
        0.17 * width
    }
    var arrowWidth: CGFloat {
        0.1 * width
    }
    var plusWidth: CGFloat {
        0.5 * (width - arrowWidth - (4 * elementWidth))
    }
    var textHeight: CGFloat {
        0.3 * height
    }
    var moleculeFrameHeight: CGFloat {
        0.28 * height
    }
    var moleculeRadius: CGFloat {
        0.16 * moleculeFrameHeight
    }
    var vSpacing: CGFloat {
        0.5 * (height - textHeight - (2 * moleculeFrameHeight))
    }

    var elementWidths: [CGFloat] {
        [
            elementWidth,
            plusWidth,
            elementWidth,
            arrowWidth,
            elementWidth,
            plusWidth,
            elementWidth
        ]
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
                    showMolecules: showMolecules,
                    topArrowHighlight: nil,
                    bottomArrowHighlight: nil
                )
                .frame(width: 160, height: 60)
            }
        }
    }
}
