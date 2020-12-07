//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileChart: View {

    let settings: EnergyRateChartSettings
    let peakHeightFactor: CGFloat
    let initialHeightFactor: CGFloat
    let tempHeightFactor: CGFloat
    let showTemperature: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("Energy")
                .rotationEffect(.degrees(-90))
                .frame(height: settings.chartSize)
                .fixedSize()

            VStack {
                annotatedChart
                HStack {
                    Text("Reactants")
                        .fixedSize()
                    Spacer()
                    Text("Products")
                        .fixedSize()
                }.frame(width: settings.chartSize)
            }
        }
        .font(.system(size: settings.fontSize * 0.8))
        .lineLimit(1)
        .minimumScaleFactor(1)
    }

    private var annotatedChart: some View {
        ZStack {
            chart
            annotations
        }
    }

    private var chart: some View {
        ZStack {
            ZStack {
                if (showTemperature) {
                    tempLine
                }

                EnergyProfileChartShape(
                    peak: initialHeightFactor
                )
                .stroke()
                .foregroundColor(Styling.energyProfileCompleteBar)
                .frame(width: settings.chartSize, height: settings.chartSize)

                EnergyProfileChartShape(
                    peak: scaledPeak
                )
                .stroke()
                .foregroundColor(.orangeAccent)
                .border(Color.black)
                .frame(width: settings.chartSize, height: settings.chartSize)
            }.frame(width: settings.chartSize, height: settings.chartSize)
        }
    }

    private var tempLine: some View {
        let curve = BellCurve(
            peak: tempHeightFactor,
            frameWidth: settings.chartSize,
            frameHeight: settings.chartSize
        )
        return Rectangle()
            .frame(height: 1)
            .foregroundColor(Color.black.opacity(0.6))
            .position(
                x: settings.chartSize / 2,
                y: curve.absoluteY(absoluteX: settings.chartSize / 2)
            )
    }

    private var annotations: some View {
        ZStack {
            reactantsAnnotations
            productAnnotation
            eaHeightAnnotation
        }
        .frame(width: settings.chartSize, height: settings.chartSize)
        .font(.system(size: settings.fontSize * 0.8))
        .lineLimit(1)
    }

    private var eaHeightAnnotation: some View {
        let curve = BellCurve(
            peak: scaledPeak,
            frameWidth: settings.chartSize,
            frameHeight: settings.chartSize
        )

        let startY = curve.absoluteY(absoluteX: 0)
        let midY = curve.absoluteY(absoluteX: settings.chartSize / 2)
        let height = startY - midY
        let padding = settings.chartSize * 0.06

        return VStack(spacing: 0) {
            Spacer()
                .frame(height: midY + padding)
            DoubleHeadedArrow(arrowHeight: settings.chartSize * 0.035)
                .stroke(lineWidth: 1)
                .frame(
                    width: settings.chartSize * 0.05,
                    height: height - padding
                )
            Text("Ea")
            Spacer()
        }.foregroundColor(.black)
    }

    private var productAnnotation: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: settings.chartSize * 0.84)
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing: 1) {
                    HStack(spacing: 0) {
                        annotationMolecule(color: UIColor.moleculeC.color)
                        annotationMolecule(color: UIColor.moleculeC.color)
                    }
                    Text("C")
                }
            }.padding(.trailing, settings.chartSize * 0.02)
            Spacer()
        }
    }

    private var reactantsAnnotations: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: settings.chartSize * 0.58)
            HStack(alignment: .bottom, spacing: 1) {
                reactantAnnotation(color: Styling.moleculeA, value: "A")
                Text("+")
                reactantAnnotation(color: Styling.moleculeB, value: "B")
                Spacer()
            }.padding(.leading, settings.chartSize * 0.02)
            Spacer()
        }
    }

    private func reactantAnnotation(color: Color, value: String) -> some View {
        VStack(spacing: 1) {
            annotationMolecule(color: color)
            Text(value)
        }
    }

    private func annotationMolecule(color: Color) -> some View {
        Circle()
            .foregroundColor(color)
            .frame(width: settings.annotationMoleculeSize, height: settings.annotationMoleculeSize)
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
            tempHeightFactor: 1,
            showTemperature: true
        )
    }
}
