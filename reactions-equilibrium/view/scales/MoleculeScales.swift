//
// Reactions App
//

import SwiftUI
import ReactionsCore

private struct MoleculeScales: View {
    var body: some View {
        GeometryReader { geo in
            SizedMoleculeScales(
                settings: MoleculeScalesGeometry(
                    width: geo.size.width,
                    height: geo.size.height
                )
            )
        }
    }
}

private struct SizedMoleculeScales: View {

    let settings: MoleculeScalesGeometry

    private let rotationDegrees: Equation = ConstantEquation(value: 20)
    private let currentTime: CGFloat = 0

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
            .frame(width: settings.armWidth, height: 1.52)
            .animatableRotation(degreesRotation: rotationDegrees, currentTime: currentTime)
            .position(settings.rotationCenter)
            .foregroundColor(Styling.scalesBody)
    }

    private var leftBasket: some View {
        basketView(isLeft: true)
    }

    private var rightBasket: some View {
        basketView(isLeft: false)
    }

    private func basketView(isLeft: Bool) -> some View {
        MoleculeScaleBasket(
            moleculeLeft: MoleculeConcentration(
                concentration: ConstantEquation(value: 1),
                color: .from(.aqMoleculeB)
            ),
            moleculeRight: MoleculeConcentration(
                concentration: ConstantEquation(value: 0.5),
                color: .from(.aqMoleculeA)
            ),
            currentTime: 0
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

private struct MoleculeScalesGeometry {
    let width: CGFloat
    let height: CGFloat

    var rotationCenter: CGPoint {
        CGPoint(x: width / 2, y: rotationY)
    }

    private var rotationY: CGFloat {
        0.247 * height
    }

    var basketWidth: CGFloat {
        0.391 * height
    }

    var armWidth: CGFloat {
        width - basketWidth
    }

    var basketHeight: CGFloat {
        MoleculeScaleBasketGeometry.heightToWidth * basketWidth
    }

    var basketYOffset: CGFloat {
        basketHeight / 2
    }

}

struct MoleculeScales_Previews: PreviewProvider {
    static var previews: some View {
        MoleculeScales()
            .previewLayout(.fixed(width: 400, height: 300))
    }
}
