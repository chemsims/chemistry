//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct MoleculeScales: View {

    let equations: BalancedReactionEquations
    let currentTime: CGFloat

    var body: some View {
        GeometryReader { geo in
            SizedMoleculeScales(
                reaction: equations,
                rotationDegrees: RotationEquation(reaction: equations),
                currentTime: currentTime,
                settings: MoleculeScalesGeometry(
                    width: geo.size.width,
                    height: geo.size.height
                )
            )
        }
    }
}

private struct RotationEquation: Equation {

    let reaction: BalancedReactionEquations
    let maxAngle: CGFloat = 25

    func getY(at x: CGFloat) -> CGFloat {
        let reactantSum = reaction.reactantA.getY(at: x) + reaction.reactantB.getY(at: x)
        let productSum = reaction.productC.getY(at: x) + reaction.productD.getY(at: x)
        return maxAngle * (productSum - reactantSum)
    }
}

private struct SizedMoleculeScales: View {

    let reaction: BalancedReactionEquations
    let rotationDegrees: Equation
    let currentTime: CGFloat
    let settings: MoleculeScalesGeometry

    var body: some View {
        ZStack {
            arm
            stand
            leftBasket
            rightBasket
        }
        .frame(width: settings.width)
    }

    private var stand: some View {
        Image("scales-stand")
            .resizable()
            .aspectRatio(contentMode: .fit)
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
            left: MoleculeConcentration(concentration: reaction.reactantA, color: .from(.aqMoleculeA)),
            right: MoleculeConcentration(concentration: reaction.reactantB, color: .from(.aqMoleculeB))
        )
    }

    private var rightBasket: some View {
        basketView(
            isLeft: false,
            left: MoleculeConcentration(
                concentration: reaction.productC,
                color: .from(.aqMoleculeC)
            ),
            right: MoleculeConcentration(
                concentration: reaction.productD,
                color: .from(.aqMoleculeD)
            )
        )
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

struct MoleculeScales_Previews: PreviewProvider {
    static var previews: some View {
        MoleculeScales(
            equations: BalancedReactionEquations(
                coefficients: BalancedReactionCoefficients(
                    reactantA: 2,
                    reactantB: 2,
                    productC: 1,
                    productD: 4
                ),
                a0: 0.4,
                b0: 0.5,
                finalTime: 10
            ),
            currentTime: 2
        )
        .previewLayout(.fixed(width: 400, height: 300))
    }
}
