//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AnimatingReactionDefinition: View {

    let coefficients: MoleculeValue<Int>
    let direction: ReactionDefinitionArrowDirection

    let labelPrefix: String?
    let labelSuffix: String?

    /// - Parameters:
    ///      - direction: Direction of the reaction
    ///      - labelPrefix: Optional string to add before the accessibility label
    ///      - labelSuffix: Optional string to add at the end of the accessibility label. This occurs at the end of the element
    ///      names, but before the arrows & molecules are described
    ///
    init(
        coefficients: MoleculeValue<Int>,
        direction: ReactionDefinitionArrowDirection,
        labelPrefix: String? = nil,
        labelSuffix: String? = nil
    ) {
        self.coefficients = coefficients
        self.direction = direction
        self.labelPrefix = labelPrefix
        self.labelSuffix = labelSuffix
    }

    var body: some View {
        GeometryReader { geo in
            AnimatingReactionDefinitionWithGeometry(
                coefficients: coefficients,
                direction: direction,
                geometry: geo,
                labelPrefix: labelPrefix,
                labelSuffix: labelSuffix
            )
        }
    }
}


private struct AnimatingReactionDefinitionWithGeometry: View {

    let coefficients: MoleculeValue<Int>
    let direction: ReactionDefinitionArrowDirection
    let geometry: GeometryProxy

    let labelPrefix: String?
    let labelSuffix: String?

    @State private var progress: CGFloat = 0

    private let animationDuration: Double = 2
    private let startProgress: CGFloat = 0.15
    private let endProgress: CGFloat = 0.75

    var body: some View {
        VStack(alignment: .leading, spacing: vSpacing) {
            topMolecules
            elements
            bottomMolecules
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
    }

    private var topMolecules: some View {
        ZStack(alignment: .leading) {
            if direction == .equilibrium {
                molecules(
                    startMolecule: .A,
                    endMolecule: .C,
                    verticalAlignment: .bottom,
                    horizontalAlignment: .leading
                )
                .onAppear {
                    let animation = Animation
                        .linear(duration: animationDuration)
                        .repeatForever(autoreverses: false)
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
            elementSide(.A, .B)
            AnimatingDoubleSidedArrow(
                width: arrowWidth,
                direction: direction
            )
            elementSide(.C, .D)
        }
        .font(.system(size: fontSize))
        .frame(height: textHeight)
        .minimumScaleFactor(0.75)
    }

    private func elementSide(_ lhs: AqueousMolecule, _ rhs: AqueousMolecule) -> some View {
        HStack(spacing: 0) {
            element(lhs)
            plus
            element(rhs)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label(lhs, rhs)))
    }

    private var label: String {
        let lhs = label(.A, .B)
        let rhs = label(.C, .D)
        let base = "Reaction definition, \(lhs), double sided arrow, \(rhs)."
        let baseWithExtra = "\(labelPrefix ?? "")\(base)\(labelSuffix ?? "")"

        return "\(baseWithExtra). \(arrowLabel). \(moleculeMovementLabel)"
    }

    private var arrowLabel: String {
        direction.label ?? ""
    }

    private var moleculeMovementLabel: String {
        if direction == .equilibrium {
            return """
            Molecules on the left side are turning into molecules on the right side above the text.
            The reverse motion is happening at the same speed below the text.
            """
        }
        return ""
    }

    private func label(_ lhs: AqueousMolecule, _ rhs: AqueousMolecule) -> String {
        func labelForMolecule(_ molecule: AqueousMolecule) -> String {
            let coeff = coefficients.value(for: molecule)
            let prefix = coeff == 1 ? "" : "\(coeff)"
            return "\(prefix)\(molecule.rawValue)"
        }

        return "\(labelForMolecule(lhs)) + \(labelForMolecule(rhs))"
    }

    private var bottomMolecules: some View {
        ZStack(alignment: .leading) {
            if direction == .equilibrium {
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
        let str = coefficients.string(forMolecule: molecule)
        return FixedText(str)
            .frame(width: elementWidth)
            .transition(.identity)
            .id(str)
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

        let spanWidth = getSpanWidth(startIndex: startIndex, span: span)

        let arrowIndex = 3
        let spanToArrow = arrowIndex - startIndex
        let arrowLocation = getSpanWidth(startIndex: startIndex, span: spanToArrow)

        let startRotation = Angle.degrees(Double(60 + (startMoleculeIndex * 20)))
        let endRotation = Angle.degrees(Double(295 + (endMoleculeIndex * 5)))

        let rgb = RGBGradientEquation(
            colors: [startMolecule.rgb, .gray(base: 170), endMolecule.rgb],
            initialX: 0,
            finalX: 1
        )

        let startCount = moleculeCount(startMolecule)
        let endCount = moleculeCount(endMolecule)

        return MoleculeArc(
            verticalAlignment: verticalAlignment,
            horizontalAlignment: horizontalAlignment,
            startState: MoleculeArcState(
                count: startCount, rotation: startRotation
            ),
            endState: MoleculeArcState(
                count: endCount, rotation: endRotation
            ),
            apexXLocation: arrowLocation / spanWidth,
            apexCount: apexCount(startCount: startCount, endCount: endCount),
            moleculeRadius: moleculeRadius,
            startProgress: startProgress,
            endProgress: endProgress,
            progress: progress
        )
        .foregroundColor(rgb: rgb, progress: progress)
        .frame(width: spanWidth)
        .offset(x: getOffset(startIndex: startIndex))
    }

    private func apexCount(startCount: MoleculeArc.Count, endCount: MoleculeArc.Count) -> MoleculeArc.Count {
        if startCount == endCount {
            return startCount
        }

        let midNumber = (startCount.number + endCount.number) / 2
        if let midCount = MoleculeArc.Count.fromNumber(midNumber),
           midCount != startCount && midCount != endCount {
            return midCount
        }

        return MoleculeArc.Count.allCases.reversed().first { count in
            count != startCount && count != endCount
        } ?? .four
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

extension AnimatingReactionDefinition {
    static let fontSizeToHeight: CGFloat = 0.21

    static let moleculeFrameHeightToHeight: CGFloat = 0.28
}

extension AnimatingReactionDefinitionWithGeometry {
    var width: CGFloat {
        geometry.size.width
    }
    var height: CGFloat {
        geometry.size.height
    }
    var fontSize: CGFloat {
        AnimatingReactionDefinition.fontSizeToHeight * height
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
        AnimatingReactionDefinition.moleculeFrameHeightToHeight * height
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
                    direction: .equilibrium
                )
                .frame(width: 160, height: 60)
            }
        }
    }
}
