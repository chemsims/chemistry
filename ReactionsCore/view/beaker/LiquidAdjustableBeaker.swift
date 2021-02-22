//
// ReactionsApp
//

import SwiftUI

struct LiquidAdjustableBeaker: View {

    let moleculesA: [GridCoordinate]
    let concentrationB: Equation?
    let currentTime: CGFloat?
    let reactionPair: ReactionPairDisplay

    @State private var rows: CGFloat = 0

    var body: some View {
        HStack {
            slider
            beaker
        }
    }

    private var slider: some View {
        CustomSlider(
            value: $rows,
            axis: axis,
            handleThickness: 20,
            handleColor: .orangeAccent,
            handleCornerRadius: 5,
            barThickness: 10,
            barColor: .gray,
            orientation: .portrait,
            includeFill: true
        )
        .frame(width: 50)
    }

    private var beaker: some View {
        FilledBeaker(
            moleculesA: moleculesA,
            concentrationB: concentrationB,
            currentTime: currentTime,
            reactionPair: reactionPair,
            rows: rows
        )
    }

    private var axis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 700,
            maxValuePosition: 50,
            minValue: 0, maxValue: 20
        )
    }
}

struct LiquidAdjustableBeaker_Previews: PreviewProvider {
    static var previews: some View {
        LiquidAdjustableBeaker(
            moleculesA: [],
            concentrationB: nil,
            currentTime: nil,
            reactionPair: ReactionType.A.display
        )
    }
}
