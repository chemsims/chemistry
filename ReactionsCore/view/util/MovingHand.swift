//
// Reactions App
//


import SwiftUI

public struct MovingHand: View {

    public init(
        initialPosition: CGPoint,
        finalPosition: CGPoint,
        handWidth: CGFloat,
        initialWait: TimeInterval = 0.25,
        finalWait: TimeInterval = 0.25,
        moveDuration: TimeInterval = 1
    ) {
        self.initialPosition = initialPosition
        self.finalPosition = finalPosition
        self.handWidth = handWidth
        self.initialWait = initialWait
        self.finalWait = finalWait
        self.moveDuration = moveDuration
    }

    let initialPosition: CGPoint
    let finalPosition: CGPoint
    let handWidth: CGFloat
    let initialWait: TimeInterval
    let finalWait: TimeInterval
    let moveDuration: TimeInterval

    private var pointEquation: PointEquation {
        let initial = ConstantPointEquation(initialPosition)
        let final = ConstantPointEquation(finalPosition)
        let mid = LinearPointEquation(
            initial: initialPosition,
            final: finalPosition,
            initialProgress: initialWait,
            finalProgress: initialWait + moveDuration
        )
        return SwitchingPointEquation(
            left: initial,
            right: SwitchingPointEquation(
                left: mid,
                right: final,
                thresholdProgress: initialWait + moveDuration
            ),
            thresholdProgress: initialWait
        )
    }

    @State private var progress: CGFloat = 0

    public var body: some View {
        Image(.core(.closedHand))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: handWidth)
            .animatablePosition(
                equation: pointEquation,
                input: progress
            )
            .onAppear(perform: runAnimation)
            .allowsHitTesting(false)
    }

    private func runAnimation() {
        let totalDuration = initialWait + finalWait + moveDuration
        let animation = Animation.linear(duration: totalDuration).repeatForever(autoreverses: false)
        withAnimation(animation) {
            progress = totalDuration
        }
    }
}

struct MovingHand_Previews: PreviewProvider {
    static var previews: some View {
        MovingHand(
            initialPosition: CGPoint(x: 50, y: 50),
            finalPosition: CGPoint(x: 300, y: 400),
            handWidth: 100
        )
    }
}
