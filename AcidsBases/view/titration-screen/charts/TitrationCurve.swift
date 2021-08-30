//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationCurve: View {

    let layout: TitrationScreenLayout
    let state: TitrationComponentState.State
    @ObservedObject var strongPreEPModel: TitrationStrongSubstancePreEPModel
    @ObservedObject var strongPostEPModel: TitrationStrongSubstancePostEPModel
    @ObservedObject var weakPreEPModel: TitrationWeakSubstancePreEPModel
    @ObservedObject var weakPostEPModel: TitrationWeakSubstancePostEPModel

    var body: some View {
        VStack(
            alignment: .trailing,
            spacing: layout.common.chartXAxisVSpacing
        ) {
            HStack(
                alignment: .top,
                spacing: layout.common.chartYAxisHSpacing
            ) {
                Text("pH")
                    .rotationEffect(.degrees(-90))
                    .frame(
                        width: layout.common.chartYAxisWidth,
                        height: layout.common.chartSize
                    )
                    .accessibility(hidden: true)

                plotArea
                    .frame(square: layout.common.chartSize)
            }
            Text("Titrant added")
                .frame(
                    width: layout.common.chartSize,
                    height: layout.common.chartXAxisHeight
                )
                .accessibility(hidden: true)
        }
        .font(.system(size: layout.common.chartLabelFontSize))
        .lineLimit(1)
        .minimumScaleFactor(0.2)
        .accessibilityElement(children: .contain)
        .accessibility(label: Text("Chart showing titrant added vs pH"))
    }

    private var description: String {
        guard showData else {
            return ""
        }
        let initialPh = phEquation.getY(at: 0)
        let finalPh = phEquation.getY(at: maxEquationInput)

        let isIncreasing = initialPh < finalPh

        let increases = isIncreasing ? "increases" : "decreases"
        let increasing = isIncreasing ? "increasing" : "decreasing"
        let jump = isIncreasing ? "jump" : "drop"

        return """
        Line description: pH \(increases) slowly until a very steep \(jump) through the equivalence \
        point. After the \(jump), pH continues \(increasing) slowly.
        """
    }

    private var currentPointAccessibilityValue: String {
        guard showData else {
            return "no data"
        }
        let perc = (equationInput / maxEquationInput).percentage
        let pH = phEquation.getY(at: equationInput).str(decimals: 2)
        return "\(perc) along x axis, pH \(pH)"
    }

    private var plotArea: some View {
        ZStack {

            lineAccessibilityElement
                .accessibility(sortPriority: 3)
            if showData {
                currentPointAccessibilityElement
                    .accessibility(sortPriority: 2)
            }


            TimeChartView(
                data: data,
                initialTime: 0,
                currentTime: .constant(equationInput),
                finalTime: maxEquationInput,
                canSetCurrentTime: false,
                settings: .init(
                    xAxis: xAxis,
                    yAxis: yAxis,
                    haloRadius: layout.common.haloRadius,
                    lineWidth: 0.4
                ),
                axisSettings: layout.common.chartAxis
            )

            annotation
        }
    }

    private var lineAccessibilityElement: some View {
        Rectangle()
            .foregroundColor(.white)
            .accessibility(label: Text(showData ? description : "no data"))
    }

    private var currentPointAccessibilityElement: some View {
        Rectangle()
            .foregroundColor(.white)
            .accessibility(label: Text("Current position on chart"))
            .accessibility(value: Text(currentPointAccessibilityValue))
            .accessibility(addTraits: .updatesFrequently)
    }

    private var titrantAddedDashes: [(label: String, titrantAdded: Int)] {
        if showAnnotations && showData {
            let mid = (label: "equivalence point", titrantAdded: preEPReaction.maxTitrant)
            let max = (label: "maximum titrant", titrantAdded: preEPReaction.maxTitrant + postEPReaction.maxTitrant)
            let equality = equalityTitrant.map { (label: "max buffer capacity", titrantAdded: $0) }
            return [equality].compactMap(identity) + [mid, max]
        }
        return []
    }

    private var preEPReaction: TitrationReactionModel {
        if state.substance.isStrong {
            return strongPreEPModel
        }
        return weakPreEPModel
    }

    private var postEPReaction: TitrationReactionModel {
        if state.substance.isStrong {
            return strongPostEPModel
        }
        return weakPostEPModel
    }

    private var annotation: some View {
        ZStack {
            ForEach(titrantAddedDashes, id: \.titrantAdded) { dash in
                dashedLine(at: dash.titrantAdded, label: dash.label)
            }
        }
    }

    private func dashedLine(
        at titrantAdded: Int,
        label: String
    ) -> some View {
        let x = xAxis.getPosition(at: CGFloat(titrantAdded))

        let percent = (CGFloat(titrantAdded) / maxEquationInput).percentage
        let pH = phEquation.getY(at: CGFloat(titrantAdded)).str(decimals: 2)

        return Path { p in
            p.addLines(
                [
                    .init(x: x, y: 0),
                    .init(x: x, y: layout.common.chartSize)
                ]
            )
        }
        .stroke(style: layout.common.chartDashedLineStyle)
        .foregroundColor(.orangeAccent)
        .accessibility(label: Text("Vertical dashed line for \(label)"))
        .accessibility(value: Text("\(percent) along x axis, intersects line at pH \(pH)"))
    }

    private var data: [TimeChartDataLine] {
        if showData {
            return [
                TimeChartDataLine(
                    equation: phEquation,
                    headColor: .purple,
                    haloColor: nil,
                    headRadius: layout.common.chartHeadRadius
                )
            ]
        }
        return []
    }

    private var showData: Bool {
        state.phase == .preEP || state.phase == .postEP
    }

    private var yAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.9 * layout.common.chartSize,
            maxValuePosition: 0.1 * layout.common.chartSize,
            minValue: 0,
            maxValue: 14
        )
    }

    private var xAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.1 * layout.common.chartSize,
            maxValuePosition: 0.9 * layout.common.chartSize,
            minValue: 0,
            maxValue: maxEquationInput
        )
    }

    private var phEquation: Equation {
        SwitchingEquation(
            thresholdX: CGFloat(preEPReaction.maxTitrant),
            underlyingLeft: preEPReaction.pH,
            underlyingRight: PostEquivalencePointPHEquation(
                underlying: postEPReaction.pH,
                equivalencePointTitrant: preEPReaction.maxTitrant
            )
        )
    }

    private var maxEquationInput: CGFloat {
        CGFloat(preEPReaction.maxTitrant) + CGFloat(postEPReaction.maxTitrant)
    }

    private var equationInput: CGFloat {
        if state.phase == .preEP {
            return CGFloat(preEPReaction.titrantAdded)
        }
        return CGFloat(postEPReaction.titrantAdded + preEPReaction.maxTitrant)
    }

    private var equalityTitrant: Int? {
        state.substance.isStrong ? nil : weakPreEPModel.titrantAtMaxBufferCapacity
    }

    private var showAnnotations: Bool {
        !state.substance.isStrong
    }
}

private struct PostEquivalencePointPHEquation: Equation {
    let underlying: Equation

    /// Titrant added at the equivalence point
    let equivalencePointTitrant: Int

    func getY(at x: CGFloat) -> CGFloat {
        underlying.getY(at: x - CGFloat(equivalencePointTitrant))
    }
}


struct TitrationPhChart_Previews: PreviewProvider {

    static var model = TitrationViewModel(
        titrationPersistence: InMemoryTitrationInputPersistence(),
        namePersistence: InMemoryNamePersistence.shared
    )
    static var components: TitrationComponentState {
        model.components
    }

    static var previews: some View {
        GeometryReader { geo in
            TitrationCurve(
                layout: .init(
                    common: .init(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                ),
                state: .init(
                    substance: .strongAcid,
                    phase: .preparation
                ),
                strongPreEPModel: components.strongSubstancePreEPModel,
                strongPostEPModel: components.strongSubstancePostEPModel,
                weakPreEPModel: components.weakSubstancePreEPModel,
                weakPostEPModel: components.weakSubstancePostEPModel
            )
        }
        .previewLayout(.iPhone8Landscape)
    }
}
