//
// Reactions App
//

import SwiftUI

public struct MoleculeScales: View {

    public init(
        leftMolecules: MoleculeScales.Molecules,
        rightMolecules: MoleculeScales.Molecules,
        rotationFraction: Equation,
        equationInput: CGFloat,
        cols: Int,
        rows: Int
    ) {
        self.leftMolecules = leftMolecules
        self.rightMolecules = rightMolecules
        self.rotationFraction = rotationFraction
        self.equationInput = equationInput
        self.cols = cols
        self.rows = rows
    }

    let leftMolecules: Molecules
    let rightMolecules: Molecules
    let rotationFraction: Equation
    let equationInput: CGFloat
    let cols: Int
    let rows: Int

    public var body: some View {
        GeometryReader { geo in
            SizedMoleculeScales(
                leftMolecules: leftMolecules,
                rightMolecules: rightMolecules,
                rotationFraction: rotationFraction,
                equationInput: equationInput,
                cols: cols,
                rows: rows,
                settings: MoleculeScalesGeometry(
                    width: geo.size.width,
                    height: geo.size.height
                )
            )
        }
    }

    public enum Molecules {
        case single(concentration: MoleculeEquation)
        case double(left: MoleculeEquation, right: MoleculeEquation)
    }

    public struct MoleculeEquation {

        public init(fractionToDraw: Equation, color: Color, label: String) {
            self.fractionToDraw = fractionToDraw
            self.color = color
            self.label = label
        }

        let fractionToDraw: Equation
        let color: Color
        let label: String
    }
}

private struct SizedMoleculeScales: View {

    let leftMolecules: MoleculeScales.Molecules
    let rightMolecules: MoleculeScales.Molecules
    let rotationFraction: Equation
    let equationInput: CGFloat
    let cols: Int
    let rows: Int
    let settings: MoleculeScalesGeometry

    var body: some View {
        ZStack {
            arm
                .accessibility(sortPriority: 3)

            stand

            leftBasket
                .accessibility(sortPriority: 2)

            rightBasket
                .accessibility(sortPriority: 1)
        }
        .frame(width: settings.width)
        .accessibilityElement(children: .contain)
    }

    private var stand: some View {
        Image("scales-stand", bundle: .reactionsCore)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .accessibility(hidden: true)
    }

    private var rotationDegrees: Equation {
        settings.maxRotationAngle * rotationFraction
    }
}

// MARK: Baskets
private extension SizedMoleculeScales {

    private var leftBasket: some View {
        basket(
            isLeft: true,
            molecules: leftMolecules
        )
    }

    private var rightBasket: some View {
        basket(
            isLeft: false,
            molecules: rightMolecules
        )
    }

    private func basket(
        isLeft: Bool,
        molecules: MoleculeScales.Molecules
    ) -> some View {
        MoleculeScaleBasket(
            molecules: molecules,
            equationInput: equationInput,
            cols: cols,
            rows: rows
        )
        .frame(
            width: settings.basketWidth,
            height: settings.basketHeight
        )
        .offset(y: settings.basketYOffset)
        .modifier(
            AnimatablePositionModifier(
                equation: TrackingEquation(
                    rotationCenter: settings.rotationCenter,
                    armWidth: isLeft ? settings.armWidth / 2 : -settings.armWidth / 2
                ),
                rotation: rotationDegrees,
                currentTime: equationInput
            )
        )
        .accessibility(
            label: Text(
                basketLabel(side: isLeft ? "left" : "right", molecules: molecules)
            )
        )
    }

    private func basketLabel(
        side: String,
        molecules: MoleculeScales.Molecules
    ) -> String {
        switch molecules {
        case let .single(concentration):
            return "\(side) basket showing molecules of \(concentration.label)"
        case let .double(left, right):
            return "\(side) basket showing molecules of \(left.label) and \(right.label)"
        }
    }
}

private struct AnimatablePositionModifier: AnimatableModifier {
    let equation: TrackingEquation
    let rotation: Equation
    var currentTime: CGFloat

    var animatableData: CGFloat {
        get { currentTime }
        set { currentTime = newValue }
    }

    func body(content: Content) -> some View {
        content.position(equation.getPoint(for: rotation, at: currentTime))
    }
}

private struct TrackingEquation {

    let rotationCenter: CGPoint
    let armWidth: CGFloat

    func getPoint(for degreesRotation: Equation, at time: CGFloat) -> CGPoint {
        let rotation = degreesRotation.getY(at: time)
        let rads = Angle(degrees: Double(rotation)).radians

        let dy = armWidth * CGFloat(sin(rads))
        let dx = armWidth * CGFloat(cos(rads))

        return CGPoint(
            x: rotationCenter.x - dx,
            y: rotationCenter.y - dy
        )
    }
}

// MARK: Arm
private extension SizedMoleculeScales {

    private var arm: some View {
        Rectangle()
            .frame(
                width: settings.armWidth,
                height: MoleculeScalesGeometry.lineWidth
            )
            .animatableRotation(
                degreesRotation: rotationDegrees,
                currentTime: equationInput
            )
            .position(settings.rotationCenter)
            .foregroundColor(Styling.scalesBody)
            .accessibility(label: Text("Scales with a basket of molecules on the left and right"))
            .updatingAccessibilityValue(x: equationInput, format: getRotationLabel)
    }

    private func getRotationLabel(at input: CGFloat) -> String {
        let rotation = rotationDegrees.getY(at: input)
        var end: String {
            if rotation > 0 {
                return " clockwise"
            } else if rotation < 0 {
                return " anti-clockwise"
            }
            return ""
        }

        return "Rotation is \(abs(rotation).str(decimals: 0)) degrees\(end)"
    }
}

struct MoleculeScales_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper()
    }

    private struct ViewWrapper: View {

        @State private var hasEnded = false

        var body: some View {
            VStack {
                MoleculeScales(
                    leftMolecules: .single(
                        concentration: .init(
                            fractionToDraw: LinearEquation(m: 1, x1: 0, y1: 0),
                            color: .red,
                            label: "A"
                        )
                    ),
                    rightMolecules: .single(
                        concentration: .init(
                            fractionToDraw: LinearEquation(m: -1, x1: 0, y1: 1),
                            color: .purple,
                            label: "B"
                        )
                    ),
                    rotationFraction: LinearEquation(m: 2, x1: 0, y1: -1),
                    equationInput: hasEnded ? 0 : 1,
                    cols: 4,
                    rows: 4
                )
                .frame(width: 380, height: 250)

                Button(action: {
                    withAnimation(.linear(duration: 2)) {
                        hasEnded.toggle()
                    }
                }) {
                    Text("Rotate")
                }
            }
        }
    }
}
