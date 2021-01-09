//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileChart: View {

    let settings: EnergyRateChartSettings
    let peakHeightFactor: CGFloat
    let tempHeightFactor: CGFloat
    let showTemperature: Bool
    let highlightTop: Bool
    let highlightBottom: Bool
    let moleculeHighlightColor: Color
    let order: ReactionOrder

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
            chartHighlight
            chart
            annotations
        }.frame(width: settings.chartSize, height: settings.chartSize)
    }

    private var chartHighlight: some View {
        ZStack {
            VStack {
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(highlightTop ? 1 : 0)
                    .frame(
                        height: 0.52 * settings.chartSize
                    )
                Spacer()
            }
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(highlightBottom ? 1 : 0)
                    .frame(
                        height: 0.51 * settings.chartSize
                    )
            }
        }
    }

    private var chart: some View {
        ZStack {
            ZStack {
                if (showTemperature) {
                    tempLine
                }

                EnergyProfileChartShape(
                    peak: eaShape.peak,
                    leftAsymptote: eaShape.leftAsymptote,
                    rightAsymptote: eaShape.rightAsymptote
                )
                .stroke()
                .foregroundColor(Styling.energyProfileCompleteBar)
                .frame(width: settings.chartSize, height: settings.chartSize)

                EnergyProfileChartShape(
                    peak: scaledPeak,
                    leftAsymptote: eaShape.leftAsymptote,
                    rightAsymptote: eaShape.rightAsymptote
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
            frameHeight: settings.chartSize,
            leftAsymptote: eaShape.leftAsymptote,
            rightAsymptote: eaShape.rightAsymptote
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
            Group {
                reactantsAnnotations
                productAnnotation
            }
            .colorMultiply(moleculeHighlightColor)

            eaHeightAnnotation
        }
        .frame(width: settings.chartSize, height: settings.chartSize)
        .font(.system(size: settings.fontSize * 0.8))
        .lineLimit(1)
    }

    private var eaHeightAnnotation: some View {
        let leftY = scaledBellCurve.absoluteY(absoluteX: 0)
        let rightY = scaledBellCurve.absoluteY(absoluteX: settings.chartSize)
        let startY = min(leftY, rightY)
        let midY = scaledBellCurve.absoluteY(absoluteX: settings.chartSize / 2)
        let height = startY - midY
        let padding = settings.chartSize * 0.04

        return VStack(spacing: 0) {
            Spacer()
                .frame(height: midY + padding)
            DoubleHeadedArrow(arrowHeight: settings.chartSize * 0.035)
                .stroke(lineWidth: 1)
                .frame(
                    width: settings.chartSize * 0.05,
                    height: height - padding
                )
            TextLinesView(line: "E_a_", fontSize: settings.fontSize)
            Spacer()
        }.foregroundColor(.black)
    }

    private var productAnnotation: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: rightAsymptoteVerticalSpacer)
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing: 1) {
                    HStack(spacing: 0) {
                        annotationMolecule(color: input.moleculeC.color.color)
                        annotationMolecule(color: input.moleculeC.color.color)
                    }
                    Text(input.moleculeC.name)
                }
            }.padding(.trailing, settings.chartSize * 0.02)
            Spacer()
        }
    }

    private var reactantsAnnotations: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: leftAsymptoteVerticalSpacer)
            HStack(alignment: .bottom, spacing: 1) {
                reactantAnnotation(color: input.moleculeA.color.color, value: input.moleculeA.name)
                Text("+")
                reactantAnnotation(color: input.moleculeB.color.color, value: input.moleculeB.name)
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
        peakHeightFactor * eaShape.peak
    }

    private var input: EnergyProfileReactionInput {
        order.energyProfileReactionInput
    }

    private var eaShape: EnergyProfileShapeSettings {
        order.energyProfileShapeSettings
    }

    private var bellCurve: BellCurve {
        makeCurve(peak: eaShape.peak)
    }

    private var scaledBellCurve: BellCurve {
        makeCurve(peak: eaShape.peak * peakHeightFactor)
    }

    private func makeCurve(peak: CGFloat) -> BellCurve {
        BellCurve(
            peak: peak,
            frameWidth: settings.chartSize,
            frameHeight: settings.chartSize,
            leftAsymptote: eaShape.leftAsymptote,
            rightAsymptote: eaShape.rightAsymptote
        )
    }

    private var curve: BellCurve2 {
        BellCurve2(
            peak: eaShape.peak,
            leftAsymptote: eaShape.leftAsymptote,
            rightAsymptote: eaShape.rightAsymptote
        )
    }

    private var leftAsymptoteVerticalSpacer: CGFloat {
        asymptoteVerticalSpacer(asymptoteRelativeHeight: curve.getY(at: 0))
    }

    private var rightAsymptoteVerticalSpacer: CGFloat {
        asymptoteVerticalSpacer(asymptoteRelativeHeight: curve.getY(at: 1))
    }

    private func asymptoteVerticalSpacer(asymptoteRelativeHeight: CGFloat) -> CGFloat {
        let spacer = settings.chartSize * (1 - asymptoteRelativeHeight)
        let padding = settings.annotationMoleculeSize * 0.4
        return spacer + padding
    }
}


fileprivate struct EnergyProfileChartShape: Shape {

    var peak: CGFloat
    var leftAsymptote: CGFloat
    var rightAsymptote: CGFloat

    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>> {
        get {
            AnimatablePair(peak, AnimatablePair(leftAsymptote, rightAsymptote))
        }
        set {
            peak = newValue.first
            leftAsymptote = newValue.second.first
            rightAsymptote = newValue.second.second
        }
    }

    private let points: CGFloat = 100
    private let minPeak: CGFloat = 0.7
    private let maxPeak: CGFloat = 0.9

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let adjustedPeak = minPeak + (peak * (maxPeak - minPeak))
        let equation = BellCurve2(
            peak: adjustedPeak,
            leftAsymptote: leftAsymptote,
            rightAsymptote: rightAsymptote
        )
        func absoluteY(_ relativeX: CGFloat) -> CGFloat {
            let relativeY = equation.getY(at: relativeX)
            let yFromBottom = relativeY * rect.height
            return rect.height - yFromBottom
        }

        path.move(to: CGPoint(x: 0, y: absoluteY(0)))
        let dx = 1 / points
        for x in stride(from: CGFloat(0), through: 1, by: dx) {
            let absoluteX = x * rect.width
            let y = absoluteY(x)
            path.addLine(to: CGPoint(x: absoluteX, y: y))
        }
        return path
    }

}

fileprivate struct BellCurve {

    let peak: CGFloat
    let frameWidth: CGFloat
    let frameHeight: CGFloat

    let leftAsymptote: CGFloat
    let rightAsymptote: CGFloat
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

fileprivate struct BellCurve2: Equation {
    let peak: CGFloat
    let leftAsymptote: CGFloat
    let rightAsymptote: CGFloat

    func getY(at x: CGFloat) -> CGFloat {
        let asymptote = x < 0.5 ? leftAsymptote : rightAsymptote
        let height = peak - asymptote
        let exponent = -1 * pow((x - 0.5), 2) * 30
        return (height * pow(CGFloat(Darwin.M_E), exponent)) + asymptote
    }
}


struct EnergyProfileChart_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileChart(
            settings: EnergyRateChartSettings(chartSize: 250),
            peakHeightFactor: 0,
            tempHeightFactor: 1,
            showTemperature: true,
            highlightTop: true,
            highlightBottom: true,
            moleculeHighlightColor: .white,
            order: .Zero
        )
    }
}
