//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileChart: View {

    let settings: EnergyRateChartSettings
    let peakHeightFactor: CGFloat
    let initialHeightFactor: CGFloat
    let concentrationC: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("Energy")
                .rotationEffect(.degrees(90))
                .frame(height: settings.chartSize)

            VStack {
                chart
                HStack {
                    Text("Reactants")
                    Spacer()
                    Text("Products")
                }.frame(width: settings.chartSize)
            }
        }
        .font(.system(size: settings.fontSize * 0.8))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }

    private var chart: some View {
        ZStack {
            EnergyProfileChartShape(
                peak: initialHeightFactor
            )
            .stroke()
            .foregroundColor(Styling.timeAxisCompleteBar)
            .frame(width: settings.chartSize, height: settings.chartSize)

            EnergyProfileChartShape(
                peak: scaledPeak
            )
            .stroke()
            .foregroundColor(.orangeAccent)
            .border(Color.black)
            .frame(width: settings.chartSize, height: settings.chartSize)

            ZStack {
                EnergyProfileHead(
                    radius: settings.chartHeadHaloSize,
                    concentrationC: concentrationC,
                    peak: scaledPeak
                ).foregroundColor(Styling.primaryColorHalo)

                EnergyProfileHead(
                    radius: settings.chartHeadSize,
                    concentrationC: concentrationC,
                    peak: scaledPeak
                ).foregroundColor(.orangeAccent)
            }.frame(width: settings.chartSize, height: settings.chartSize)
        }
    }

    private var scaledPeak: CGFloat {
        peakHeightFactor * initialHeightFactor
    }
}

fileprivate struct EnergyProfileHead: Shape {

    let radius: CGFloat
    var concentrationC: CGFloat
    var peak: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(concentrationC, peak) }
        set {
            concentrationC = newValue.first
            peak = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let curve = BellCurve(peak: peak, frameWidth: rect.width, frameHeight: rect.height)
        let absoluteX: CGFloat = concentrationC * rect.width
        let absoluteY = curve.absoluteY(absoluteX: absoluteX)

        let originX = absoluteX - radius
        let originY = absoluteY - radius

        let headRect = CGRect(x: originX, y: originY, width: radius * 2, height: radius * 2)
        path.addEllipse(in: headRect)

        return path
    }

}


fileprivate struct EnergyProfileChartShape: Shape {

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
            settings: EnergyRateChartSettings(chartSize: 250),
            peakHeightFactor: 0,
            initialHeightFactor: 1,
            concentrationC: 0.5
        )
    }
}
