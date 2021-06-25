//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationEquationView: View {
    typealias Term = TitrationEquationTerm
    let data: TitrationEquationData
    let equationSet: TitrationEquationSet
    let equationInput: CGFloat
    @Environment(\.titrationEquationLayout) var layout

    var body: some View {
        GeometryReader { geo in
            ScaledView(
                naturalWidth: Self.naturalWidth,
                naturalHeight: Self.naturalHeight,
                maxWidth: geo.size.width,
                maxHeight: geo.size.height
            ) {
                sizedBody
            }
            .frame(size: geo.size)
        }
    }

    fileprivate static let naturalWidth: CGFloat = 1100
    fileprivate static let naturalHeight: CGFloat = 600
}

private extension TitrationEquationView {

    var sizedBody: some View {
        HStack(alignment: .top, spacing:40) {
            column(equations: equationSet.left)
            column(equations: equationSet.right)
        }
        .font(.system(size: layout.fontSize))
        .minimumScaleFactor(layout.minScaleFactor)
        .lineLimit(1)
        .environment(\.titrationEquationInput, equationInput)
    }

    private func column(equations: [TitrationEquation]) -> some View {
        VStack(spacing: 30) {
            ForEach(equations) { equation in
                getView(forEquation: equation)
            }
        }
    }
}


extension TitrationEquationView {

    @ViewBuilder
    private func getView(forEquation equation: TitrationEquation) -> some View {
        switch equation {
        case let .filled(underlying):
            getFilledView(forEquation: underlying)

        case let .concentrationToMolesOverVolume(
            concentration,
            moles,
            firstVolume,
            secondVolume
        ): ConcentrationToMolesOverVolumeDefinition(
            data: data,
            concentration: concentration.term,
            moles: moles.term,
            firstVolume: firstVolume.term,
            secondVolume: secondVolume.term
        )

        case let .concentrationToMolesDifferenceOverVolume(
            concentration,
            subtractingMoles,
            fromMoles,
            firstVolume,
            secondVolume
        ): ConcentrationToMolesDifferenceOverVolumeDefinition(
            data: data,
            concentration: concentration.term,
            subtractingMoles: subtractingMoles.term,
            fromMoles: fromMoles.term,
            firstVolume: firstVolume.term,
            secondVolume: secondVolume.term
        )

        case let .kToConcentration(
                kValue,
                firstNumeratorConcentration,
                secondNumeratorConcentration,
                denominatorConcentration
        ): KToConcentrationDefinition(
            data: data,
            kValue: kValue.term,
            firstNumeratorConcentration: firstNumeratorConcentration.term,
            secondNumeratorConcentration: secondNumeratorConcentration.term,
            denominatorConcentration: denominatorConcentration.term
        )

        case let .kW(kA, kB):
            KaKbRelationDefinition(data: data, firstKValue: kA.term, secondKValue: kB.term)

        case let .molesDifference(
                difference,
                subtracting,
                from
        ): MolesDifferenceDefinition(
            data: data,
            molesDifference: difference.term,
            subtractingMoles: subtracting.term,
            fromMoles: from.term
        )

        case let .molesToConcentration(
                moles,
                concentration,
                volume
        ): MolesToConcentrationDefinition(
            data: data,
            moles: moles.term,
            concentration: concentration.term,
            volume: volume.term
        )

        case let .molesToMolarity(
                moles,
                volume,
                molarity
        ): MolesToMolarityDefinition(
            data: data,
            moles: moles.term,
            volume: volume.term,
            molarity: molarity.term
        )

        case let .pConcentration(
                pValue,
                concentration
        ): PLogConcentrationDefinition(
            data: data,
            pValue: pValue.term,
            concentration: concentration.term
        )

        case let .pLogComplementConcentration(
                pValue,
                concentration
        ): PLogComplementConcentrationDefinition(
            data: data,
            pH: pValue.term,
            concentration: concentration.term
        )

        case let .pKLog(
                pConcentration,
                pK,
                numeratorConcentration,
                denominatorConcentration
        ): PConcentrationDefinition(
            data: data,
            resultPValue: pConcentration.term,
            pkValue: pK.term,
            numeratorConcentration: numeratorConcentration.term,
            denominatorConcentration: denominatorConcentration.term
        )

        case let .pSum(firstPValue, secondPValue):
            PHSumDefinition(
                data: data,
                firstPValue: firstPValue.term,
                secondPValue: secondPValue.term
            )

        case let .pToLogK(pValue, kValue):
            PLogKValueDefinition(
                data: data,
                pValue: pValue.term,
                kValue: kValue.term
            )
        }
    }

    @ViewBuilder
    private func getFilledView(forEquation equation: TitrationEquation) -> some View {
        switch equation {
        case .filled:
            let _ = {
                print("Ignoring nested filled equation view")
            }()
            EmptyView()

        case let .concentrationToMolesOverVolume(
            concentration,
            moles,
            firstVolume,
            secondVolume
        ): ConcentrationToMolesOverVolumeFilled(
            data: data,
            concentration: concentration,
            moles: moles,
            firstVolume: firstVolume,
            secondVolume: secondVolume
        )

        case let .concentrationToMolesDifferenceOverVolume(
            concentration,
            subtractingMoles,
            fromMoles,
            firstVolume,
            secondVolume
        ): ConcentrationToMolesDifferenceOverVolumeFilled(
            data: data,
            concentration: concentration,
            subtractingMoles: subtractingMoles,
            fromMoles: fromMoles,
            firstVolume: firstVolume,
            secondVolume: secondVolume
        )

        case let .kToConcentration(
                kValue,
                firstNumeratorConcentration,
                secondNumeratorConcentration,
                denominatorConcentration
        ): KToConcentrationFilled(
            data: data,
            kValue: kValue,
            firstNumeratorConcentration: firstNumeratorConcentration,
            secondNumeratorConcentration: secondNumeratorConcentration,
            denominatorConcentration: denominatorConcentration
        )

        case let .kW(kA, kB):
            KaKbRelationFilled(
                data: data,
                firstKValue: kA,
                secondKValue: kB
            )

        case let .molesDifference(
                difference,
                subtracting,
                from
        ): MolesDifferenceFilled(
            data: data,
            molesDifference: difference,
            subtractingMoles: subtracting,
            fromMoles: from
        )

        case let .molesToConcentration(
                moles,
                concentration,
                volume
        ): MolesToConcentrationFilled(
            data: data,
            moles: moles,
            concentration: concentration,
            volume: volume
        )

        case let .molesToMolarity(
                moles,
                volume,
                molarity
        ): MolesToMolarityFilled(
            data: data,
            moles: moles,
            volume: volume,
            molarity: molarity
        )

        case let .pConcentration(
                pValue,
                concentration
        ): PLogConcentrationFilled(
            data: data,
            pValue: pValue,
            concentration: concentration
        )

        case let .pLogComplementConcentration(
                pValue,
                concentration
        ): PLogComplementConcentrationDefinitionFilled(
            data: data,
            pValue: pValue,
            concentration: concentration
        )

        case let .pKLog(
                pConcentration,
                pK,
                numeratorConcentration,
                denominatorConcentration
        ): PConcentrationFilled(
            data: data,
            resultPValue: pConcentration,
            pkValue: pK,
            numeratorConcentration: numeratorConcentration,
            denominatorConcentration: denominatorConcentration
        )

        case let .pSum(firstPValue, secondPValue):
            PHSumFilled(
                data: data,
                firstPValue: firstPValue,
                secondPValue: secondPValue
            )

        case let .pToLogK(pValue, kValue):
            PLogKValueFilled(
                data: data,
                pValue: pValue,
                kValue: kValue
            )
        }
    }
}

struct TitrationEquationView_Previews: PreviewProvider {
    static var previews: some View {
        TitrationEquationView(
            data: .preview,
            equationSet: .weakAcidAtEp,
            equationInput: 0
        )
        .sizedBody // We use the non-scaled view in the preview to check the natural size is correct
        .border(Color.red)
        .previewLayout(.fixed(width: TitrationEquationView.naturalWidth, height: TitrationEquationView.naturalHeight))
    }
}
