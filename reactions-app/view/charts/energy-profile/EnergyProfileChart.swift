//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileChart: View {

    let settings: EnergyRateChartSettings
    let showTemperature: Bool
    let highlightTop: Bool
    let highlightBottom: Bool
    let moleculeHighlightColor: Color
    let order: ReactionOrder
    let chartInput: EnergyProfileChartInput

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
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
        .accessibility(value: Text(value))
    }

    private var label: String {
        let a = input.moleculeA.name
        let b = input.moleculeB.name
        let c = input.moleculeC.name

        let reactantMsg = "Reactants are \(chartInput.leftAsymptote.percentage) up the y axis"
        let productMsg = "Product is \(chartInput.rightAsymptote.percentage) up the y axis"

        let isReduced = chartInput.reducedPeak < chartInput.initialPeak

        let initialEa = "The EA hump is \(chartInput.initialPeak.percentage) up the Y axis"
        let reducedEa = "The EA hump is \(chartInput.reducedPeak.percentage) up the Y axis, reduced from \(chartInput.initialPeak.percentage) before the catalyst was added"


        let eaMsg = isReduced ? reducedEa : initialEa

        let lineMsg = showTemperature ? ". A horizontal line shows the average kinetic energy of the molecules" : ""

        return "Energy profile for the reaction \(a) + \(b) to \(c). \(reactantMsg). \(productMsg). \(eaMsg)\(lineMsg)"
    }

    private var value: String {
        let position = chartInput.canReactToC ? "above" : "below"
        let suffix = "which is \(position) the EA hump"
        if (showTemperature) {
            return "The energy line is \(chartInput.currentEnergy.percentage) up the Y axis, \(suffix)"
        }
        return ""
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
                    peak: chartInput.initialPeak,
                    leftAsymptote: chartInput.leftAsymptote,
                    rightAsymptote: chartInput.rightAsymptote
                )
                .stroke()
                .foregroundColor(Styling.energyProfileCompleteBar)
                .frame(width: settings.chartSize, height: settings.chartSize)

                EnergyProfileChartShape(
                    peak: chartInput.reducedPeak,
                    leftAsymptote: chartInput.leftAsymptote,
                    rightAsymptote: chartInput.rightAsymptote
                )
                .stroke()
                .foregroundColor(.orangeAccent)
                .border(Color.black)
                .frame(width: settings.chartSize, height: settings.chartSize)
            }.frame(width: settings.chartSize, height: settings.chartSize)
        }
    }

    private var tempLine: some View {
        let curve = makeCurve(peak: chartInput.currentEnergy)
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
        let curve = makeCurve(peak: chartInput.reducedPeak)
        let startY = curve.absoluteY(absoluteX: 0)
        let midY = curve.absoluteY(absoluteX: settings.chartSize / 2)
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

    private var input: EnergyProfileReactionInput {
        order.energyProfileReactionInput
    }

    private func makeCurve(peak: CGFloat) -> BellCurve {
        BellCurve(
            peak: peak,
            leftAsymptote: chartInput.leftAsymptote,
            rightAsymptote: chartInput.rightAsymptote,
            frameWidth: settings.chartSize,
            frameHeight: settings.chartSize
        )
    }

    private var leftAsymptoteVerticalSpacer: CGFloat {
        asymptoteVerticalSpacer(x: 0)
    }

    private var rightAsymptoteVerticalSpacer: CGFloat {
        asymptoteVerticalSpacer(x: settings.chartSize)
    }

    private func asymptoteVerticalSpacer(x: CGFloat) -> CGFloat {
        let padding = settings.annotationMoleculeSize * 0.4
        let curve = makeCurve(peak: chartInput.reducedPeak)
        return curve.absoluteY(absoluteX: x) + padding
    }
}

fileprivate extension CGFloat {
    var percentage: String {
        "\((self * 100).str(decimals: 0))%"
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

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let curve = BellCurve(
            peak: peak,
            leftAsymptote: leftAsymptote,
            rightAsymptote: rightAsymptote,
            frameWidth: rect.width,
            frameHeight: rect.height
        )

        path.move(to: CGPoint(x: 0, y: curve.absoluteY(absoluteX: 0)))
        let dx = rect.width / points
        for x in stride(from: CGFloat(0), through: rect.width, by: dx) {
            let y = curve.absoluteY(absoluteX: x)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}

fileprivate struct BellCurve {

    let peak: CGFloat
    let leftAsymptote: CGFloat
    let rightAsymptote: CGFloat
    let frameWidth: CGFloat
    let frameHeight: CGFloat

    func absoluteY(absoluteX: CGFloat) -> CGFloat {
        let relativeX = absoluteX / frameWidth
        let y = relativeY(relativeX: relativeX)
        let absoluteFromTop = y * frameHeight
        return frameHeight - absoluteFromTop
    }

    private func relativeY(relativeX: CGFloat) -> CGFloat {
        let asymptote = relativeX < 0.5 ? leftAsymptote : rightAsymptote
        let height = peak - asymptote
        let exponent = -1 * pow((relativeX - 0.5), 2) * 30
        return (height * pow(CGFloat(Darwin.M_E), exponent)) + asymptote
    }
}

struct EnergyProfileChart_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileChart(
            settings: EnergyRateChartSettings(chartSize: 250),
            showTemperature: true,
            highlightTop: true,
            highlightBottom: true,
            moleculeHighlightColor: .white,
            order: .Second,
            chartInput: .init(
                shape: ReactionOrder.Second.energyProfileShapeSettings,
                temperature: 400,
                catalyst: .A
            )
        )
    }
}
