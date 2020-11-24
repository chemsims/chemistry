//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileChart: View {

    let peakHeightFactor: CGFloat
    let concentrationC: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                EnergyProfileChartShape(
                    peak: 1
                )
                .stroke()
                .foregroundColor(Styling.timeAxisCompleteBar)

                EnergyProfileChartShape(
                    peak: peakHeightFactor
                )
                .stroke()
                .foregroundColor(.orangeAccent)
                .border(Color.black)

                ZStack {
                    Circle()
                        .frame(width: geometry.size.width * 0.1)
                        .foregroundColor(Color.orangeAccent.opacity(0.5))
                    Circle()
                        .frame(width: geometry.size.width * 0.045)
                        .foregroundColor(.orangeAccent)
                }
                .position(
                    x: concentrationC * geometry.size.width,
                    y: BellCurve(
                        peak: peakHeightFactor,
                        frameWidth: geometry.size.width,
                        frameHeight: geometry.size.height
                    ).absoluteY(absoluteX: concentrationC * geometry.size.width)
                )
            }
        }
    }
}

struct EnergyProfileChartShape: Shape {

    var peak: CGFloat

    private let points: CGFloat = 100

    var animatableData: CGFloat {
        get { peak }
        set { peak = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let curve = BellCurve(
            peak: peak,
            frameWidth: rect.width,
            frameHeight: rect.height
        )

        path.move(to: CGPoint(x: 0, y: curve.absoluteY(absoluteX: 0)))
        let dx = rect.size.width / points
        for x in stride(from: 0, through: rect.size.width / 2, by: dx) {
            let y = curve.absoluteY(absoluteX: x)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        for x in stride(from: rect.size.width / 2, through: rect.size.width, by: dx) {
            let y = curve.absoluteY(absoluteX: x)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }

}

fileprivate struct BellCurve {

    let peak: CGFloat
    let frameWidth: CGFloat
    let frameHeight: CGFloat

    let leftAsymptote: CGFloat = 0.5
    let rightAsymptote: CGFloat = 0.2
    private let minPeak: CGFloat = 0.7
    private let maxPeak: CGFloat = 0.9

    func absoluteY(absoluteX: CGFloat) -> CGFloat {
        let relativeX = absoluteX / frameWidth
        let y = relativeY(relativeX: relativeX)
        let absoluteFromTop = y * frameHeight
        return frameHeight - absoluteFromTop
    }

    private func relativeY(relativeX: CGFloat) -> CGFloat {
        let asymptote = relativeX < 0.5 ? leftAsymptote : rightAsymptote
        let adjustedPeak = minPeak + (peak * (maxPeak - minPeak))
        let height = adjustedPeak - asymptote
        let exponent = -1 * pow((relativeX - 0.5), 2) * 30
        return (height * pow(CGFloat(Darwin.M_E), exponent)) + asymptote
    }

}


struct EnergyProfileChart_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileChart(
            peakHeightFactor: 0,
            concentrationC: 0.5
        )
    }
}
