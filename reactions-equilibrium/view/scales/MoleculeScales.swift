//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct MoleculeScales: View {

    @State private var currentTime: CGFloat = 0
    private var equation = QuadraticEquation(
        parabola: CGPoint(x: 5, y: 45),
        through: .zero
    )

    var body: some View {
        GeometryReader { geo in
            ZStack {
                button
                Rectangle()
                    .foregroundColor(Styling.scalesBody)
                 .frame(width: 200, height: 2)
                    .animatableRotation(
                        degreesRotation: equation,
                        currentTime: currentTime
                    )

                basket(lhs: true, geo: geo)
                basket(lhs: false, geo: geo)
            }
        }
        .padding(.leading, 50)
    }

    private func basket(lhs: Bool, geo: GeometryProxy) -> some View {
        circle
            .modifier(
                AnimatablePositionModifier(
                    equation: TrackingEquation(
                        rotationCenter: CGPoint(
                            x: geo.size.width / 2,
                            y: geo.size.height / 2
                        ),
                        armWidth: lhs ? 100 : -100
                    ),
                    rotation: equation,
                    currentTime: currentTime
                )
            )
            .offset(y: 30)
    }

    private var circle: some View {
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
        .frame(width: 60, height: 60)
    }

    private var button: some View {
        VStack {
            Button(action: {
                withAnimation(.linear(duration: 5)) {
                    if currentTime == 5 {
                        currentTime = 0
                    } else {
                        currentTime = 5
                    }
                }
            }) {
                Text("click me")
            }
            Spacer()
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

struct MoleculeScales_Previews: PreviewProvider {
    static var previews: some View {
        MoleculeScales()
    }
}
