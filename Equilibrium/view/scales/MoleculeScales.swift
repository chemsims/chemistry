//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct MoleculeScales: View {

    let reaction: BalancedReactionEquation
    let angleFraction: Equation
    let currentTime: CGFloat

    var body: some View {
        GeometryReader { geo in
            SizedMoleculeScales(
                reaction: reaction,
                angleFraction: angleFraction,
                currentTime: currentTime,
                settings: MoleculeScalesGeometry(
                    width: geo.size.width,
                    height: geo.size.height
                )
            )
        }
    }
}

private struct SizedMoleculeScales: View {

    let reaction: BalancedReactionEquation
    let angleFraction: Equation
    let currentTime: CGFloat
    let settings: MoleculeScalesGeometry

    var body: some View {
        ZStack {
            arm
                .accessibility(label: Text("Scales with a basket of molecules on the left and right"))
                .updatingAccessibilityValue(x: currentTime, format: getRotationLabel)
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

    private func getRotationLabel(forTime time: CGFloat) -> String {
        let rotation = rotationDegrees.getY(at: time)
        var end: String {
            if rotation > 0 {
                return " clockwise"
            }
            return rotation < 0 ? " anti-clockwise" : ""
        }

        return "Rotation is \(abs(rotation).str(decimals: 0)) degrees\(end)"
    }

    private var rotationDegrees: ScalesRotationEquation {
        ScalesRotationEquation(
            fraction: angleFraction,
            maxAngle: settings.maxRotationAngle
        )
    }

    private var stand: some View {
        Image("scales-stand", bundle: .equilibrium)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .accessibility(hidden: true)
    }

    private var arm: some View {
        Rectangle()
            .frame(width: settings.armWidth, height: MoleculeScalesGeometry.lineWidth)
            .animatableRotation(degreesRotation: rotationDegrees, currentTime: currentTime)
            .position(settings.rotationCenter)
            .foregroundColor(Styling.scalesBody)
    }

    private var leftBasket: some View {
        basketView(
            isLeft: true,
            left: MoleculeConcentration(concentration: reaction.concentration.reactantA, color: .from(.aqMoleculeA), label: "A"),
            right: MoleculeConcentration(concentration: reaction.concentration.reactantB, color: .from(.aqMoleculeB), label: "B")
        )
        .accessibility(label: Text(basketLabel(side: "left", molecule1: "A", molecule2: "B")))
    }

    private var rightBasket: some View {
        basketView(
            isLeft: false,
            left: MoleculeConcentration(
                concentration: reaction.concentration.productC,
                color: .from(.aqMoleculeC),
                label: "C"
            ),
            right: MoleculeConcentration(
                concentration: reaction.concentration.productD,
                color: .from(.aqMoleculeD),
                label: "D"
            )
        )
        .accessibility(label: Text(basketLabel(side: "right", molecule1: "C", molecule2: "D")))
    }

    private func basketLabel(
        side: String,
        molecule1: String,
        molecule2: String
    ) -> String {
        "\(side) basket showing molecules of \(molecule1) and \(molecule2)"
    }

    private func basketView(
        isLeft: Bool,
        left: MoleculeConcentration,
        right: MoleculeConcentration
    ) -> some View {
        MoleculeScaleBasket(
            moleculeLeft: left,
            moleculeRight: right,
            currentTime: currentTime
        )
        .frame(width: settings.basketWidth, height: settings.basketHeight)
        .offset(y: settings.basketYOffset)
        .modifier(
            AnimatablePositionModifier(
                equation: TrackingEquation(
                    rotationCenter: settings.rotationCenter,
                    armWidth: isLeft ? settings.armWidth / 2 : -settings.armWidth / 2
                ),
                rotation: rotationDegrees,
                currentTime: currentTime
            )
        )
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

struct MoleculeScalesGeometry {
    fileprivate let width: CGFloat
    fileprivate let height: CGFloat

    static let lineWidth: CGFloat = 0.8
    static let widthToHeight: CGFloat = 1.657

    var maxRotationAngle: CGFloat {
        let maxForRight = Self.maxRotationForRightHand(
            rotationY: rotationY,
            singleArmWidth: armWidth / 2
        ).degrees
        let maxForLeft = Self.maxRotationForLeftHand(
            maxHeight: height - rotationY,
            singleArmWidth: armWidth / 2,
            basketHeight: basketHeight
        ).degrees
        return CGFloat(min(maxForLeft, maxForRight))
    }

    fileprivate var rotationCenter: CGPoint {
        CGPoint(x: width / 2, y: rotationY)
    }

    private var rotationY: CGFloat {
        0.247 * height
    }

    fileprivate var basketWidth: CGFloat {
        0.391 * height
    }

    fileprivate var armWidth: CGFloat {
        width - basketWidth
    }

    fileprivate var basketHeight: CGFloat {
        MoleculeScaleBasketGeometry.heightToWidth * basketWidth
    }

    fileprivate var basketYOffset: CGFloat {
        basketHeight / 2
    }
}

extension MoleculeScalesGeometry {
    static func maxRotationForRightHand(
        rotationY: CGFloat,
        singleArmWidth: CGFloat
    ) -> Angle {
        Angle(radians: Double(asin(rotationY / singleArmWidth)))
    }


    static func maxRotationForLeftHand(
        maxHeight: CGFloat,
        singleArmWidth: CGFloat,
        basketHeight: CGFloat
    ) -> Angle {
        let sinTheta = (maxHeight - basketHeight) / singleArmWidth
        return Angle(radians: Double(asin(sinTheta)))
    }
}
