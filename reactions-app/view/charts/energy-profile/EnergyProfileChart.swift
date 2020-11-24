//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileChart: View {

    let peakHeightFactor: CGFloat

    var body: some View {
        ZStack {
            EnergyProfileChartShape(
                leftAsymptote: 0.5,
                peak: 1,
                rightAsymptote: 0.2
            )
            .stroke()
            .foregroundColor(Styling.timeAxisCompleteBar)

            EnergyProfileChartShape(
                leftAsymptote: 0.5,
                peak: peakHeightFactor,
                rightAsymptote: 0.2
            )
            .stroke()
            .foregroundColor(.orangeAccent)
        }.border(Color.black)
    }
}

struct EnergyProfileChartShape: Shape {

    let leftAsymptote: CGFloat
    var peak: CGFloat
    let rightAsymptote: CGFloat

    private let points: CGFloat = 100
    private let minPeak: CGFloat = 0.7
    private let maxPeak: CGFloat = 0.9

    var animatableData: CGFloat {
        get { peak }
        set { peak = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        func absoluteY(absoluteX: CGFloat, asymptote: CGFloat) -> CGFloat {
            let relativeX = absoluteX / rect.size.width
            let relativeY = getRelativeY(at: relativeX, asymptote: asymptote)
            let absoluteFromTop = relativeY * rect.size.height
            return rect.size.height - absoluteFromTop
        }

        path.move(to: CGPoint(x: 0, y: absoluteY(absoluteX: 0, asymptote: leftAsymptote)))
        let dx = rect.size.width / points
        for x in stride(from: 0, through: rect.size.width / 2, by: dx) {
            let y = absoluteY(absoluteX: x, asymptote: leftAsymptote)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        for x in stride(from: rect.size.width / 2, through: rect.size.width, by: dx) {
            let y = absoluteY(absoluteX: x, asymptote: rightAsymptote)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }

    private func getRelativeY(at relativeX: CGFloat, asymptote: CGFloat) -> CGFloat {
        let adjustedPeak = minPeak + (peak * (maxPeak - minPeak))
        let height = adjustedPeak - asymptote
        let exponent = -1 * pow((relativeX - 0.5), 2) * 30
        return (height * pow(CGFloat(Darwin.M_E), exponent)) + asymptote
    }

}


struct EnergyProfileChart_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileChart(
            peakHeightFactor: 0
        )
    }
}
