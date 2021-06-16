//
// Reactions App
//

import SwiftUI
import ReactionsCore

private typealias EquationState = BufferScreenViewModel.EquationState

struct BufferEquationView: View {

    let progress: CGFloat
    let state: BufferScreenViewModel.EquationState
    let data: BufferEquationData

    var body: some View {
        GeometryReader { geo in
            SizedBufferEquationView(
                progress: progress,
                state: state,
                data: data
            )
            .scaledToFit(
                inWidth: geo.size.width,
                inHeight: geo.size.height,
                naturalSize: CGSize(
                    width: NaturalWidth,
                    height: NaturalHeight
                )
            )
            .frame(size: geo.size)
        }
    }
}

struct BufferEquationData {
    let substance: AcidOrBase
    let kA: CGFloat
    let kB: CGFloat
    let concentration: SubstanceValue<Equation>
    let pKa: CGFloat
    let pH: Equation
    let pOH: Equation

    init(
        substance: AcidOrBase,
        concentration: SubstanceValue<Equation>,
        pH: Equation
    ) {
        self.substance = substance
        self.kA = substance.kA
        self.kB = substance.kB
        self.pKa = substance.pKA
        self.concentration = concentration
        self.pH = pH
        self.pOH = ConstantEquation(value: 14) - pH
    }
}

private struct SizedBufferEquationView: View {

    let progress: CGFloat
    let state: EquationState
    let data: BufferEquationData

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            row0
            row1
            row2
            row3
        }
        .frame(width: leftColWidth + spacerWidth + rightColWidth)
        .font(.system(size: EquationSizing.fontSize))
        .minimumScaleFactor(0.5)
    }

    private var row0: some View {
        HStack(spacing: 0) {
            KADefinition(
                substance: data.substance,
                state: state,
                fixedK: state.isAcid ? data.kA : data.kB
            )
            .frame(width: leftColWidth, alignment: .leading)

            Spacer()

            if state.showPKEquations {
                PKADefinition(state: state)
                    .frame(width: rightColWidth, alignment: .leading)
            }

            if state.showPhSumAtTop {
                phSumDefinition
            }
        }
    }

    private var row1: some View {
        HStack(spacing: 0) {
            KAFilled(
                substance: data.substance,
                state: state,
                kValue: state.isAcid ? data.kA : data.kB,
                concentration: data.concentration,
                progress: progress
            )
            .frame(width: leftColWidth, alignment: .leading)

            Spacer()

            if state.showPKEquations {
                PKAFilled(
                    showTerms: state.showAllTerms,
                    pKAValue: data.pKa,
                    kaValue: data.kA
                )
                .frame(width: rightColWidth, alignment: .leading)
            }

            if state.showPhSumAtTop {
                phSumFilled
            }
        }
    }

    private var row2: some View {
        HStack(spacing: 0) {
            PHDefinition(substance: data.substance, state: state)
                .frame(width: leftColWidth, alignment: .leading)

            Spacer()

            if state.showKwEquations {
                KWDefinition()
                    .frame(width: rightColWidth, alignment: .leading)
            }

            if state.showPhSumAtBottom {
                phSumDefinition
            }
        }
    }

    private var row3: some View {
        HStack {
            PHFilled(
                state: state,
                progress: progress,
                pKAValue: data.pKa,
                phEquation: data.pH,
                secondaryIonConcentration: data.concentration.secondaryIon,
                substanceConcentration: data.concentration.substance
            )
            .frame(width: leftColWidth, alignment: .leading)

            Spacer()

            if state.showKwEquations  {
                KWFilled(
                    showTerms: state.showAllTerms,
                    progress: progress,
                    kAValue: data.kA,
                    kBValue: data.kB
                )
                .frame(width: rightColWidth, alignment: .leading)
            }

            if state.showPhSumAtBottom {
                phSumFilled
            }
        }
    }

    private var phSumDefinition: some View {
        PHSumDefinition()
            .frame(width: rightColWidth, alignment: .leading)
    }

    private var phSumFilled: some View {
        PHSumFilled(
            showTerms: state.showAllTerms,
            progress: progress,
            pHEquation: data.pH,
            pOHEquation: data.pOH
        )
        .frame(width: rightColWidth, alignment: .leading)
    }
}

private struct KADefinition: View {

    let substance: AcidOrBase
    let state: EquationState
    let fixedK: CGFloat

    var body: some View {
        HStack(spacing: hStackSpacing) {
            FixedText(state.kTerm)
                .leftColElement()
            FixedText("=")
            if state.isSummary {
                FixedText(TextLineUtil.scientificString(value: fixedK))
            } else {
                fraction
            }
        }
    }

    private var fraction: some View {
        VStack(spacing: 3) {
            HStack(spacing: 1) {
                ForEach(substance.productParts) { part in
                    ChargedSymbolView(symbol: substance.chargedSymbol(ofPart: part))
                }
            }
            Rectangle()
                .frame(width: 110, height: 2)
            FixedText("[\(substance.symbol)]")
        }
    }
}

private struct PKADefinition: View {

    let state: EquationState

    var body: some View {
        HStack(spacing: hStackSpacing) {
            FixedText("p\(state.kTerm)")
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
            FixedText("-log(\(state.kTerm))")
        }
    }
}

private struct KAFilled: View {
    let substance: AcidOrBase
    let state: EquationState
    let kValue: CGFloat
    let concentration: SubstanceValue<Equation>
    let progress: CGFloat

    var body: some View {
        HStack(spacing: hStackSpacing) {
            if state.isSummary {
                FixedText(state.kTerm)
                    .leftColElement()
            } else {
                kAView
            }
            FixedText("=")
            if state.isSummary {
                FixedText(kValue.str(decimals: 2))
            } else {
                fraction
            }
        }
    }

    private var kAView: some View {
        PlaceholderTextLine(
            value: state.showAllTerms ? TextLineUtil.scientific(value: kValue).emphasised() : nil,
            expandedWidth: largeBoxWidth
        )
        .frame(width: largeBoxWidth, alignment: .trailing)
    }

    private var fraction: some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) {
                ForEach(substance.productParts) { part in
                    concentration(part, state.showIonConcentration)
                }
            }
            Rectangle()
                .frame(width: 150, height: 2)
            concentration(.substance, state.showSubstanceConcentration)
        }
    }

    private func concentration(
        _ part: SubstancePart,
        _ show: Bool
    ) -> some View {
        HStack(spacing: 0) {
            FixedText("(")
            AnimatingNumberPlaceholder(
                showTerm: show,
                progress: progress,
                equation: concentration.value(for: part),
                formatter: { "\($0.str(decimals: 2))"}
            )
            .frame(
                width: EquationSizing.boxWidth,
                height: EquationSizing.boxHeight
            )
            FixedText(")")
        }
    }
}

private struct PKAFilled: View {

    let showTerms: Bool
    let pKAValue: CGFloat
    let kaValue: CGFloat

    var body: some View {
        HStack(spacing: hStackSpacing) {
            pka
            FixedText("=")
            ka
        }
    }

    private var pka: some View {
        PlaceholderTerm(
            value: showTerms ? pKAValue.str(decimals: 2) : nil
        )
    }

    private var ka: some View {
        HStack(spacing: 1) {
            FixedText("-log(")
            PlaceholderTextLine(
                value: showTerms ? TextLineUtil.scientific(value: kaValue).emphasised() : nil,
                expandedWidth: largeBoxWidth
            )
            FixedText(")")
        }
    }
}

private struct AnimatingScientificText: View {

    let showTerm: Bool
    let progress: CGFloat
    let equation: Equation

    var body: some View {
        AnimatingNumberPlaceholder(
            showTerm: showTerm,
            progress: progress,
            equation: equation,
            formatter: TextLineUtil.scientificString
        )
        .frame(
            width: largeBoxWidth,
            height: EquationSizing.boxHeight
        )
    }
}

private struct PHDefinition: View {

    let substance: AcidOrBase
    let state: EquationState

    var body: some View {
        HStack(spacing: hStackSpacing) {
            FixedText("pH")
                .leftColElement()
            FixedText("=")
            FixedText("p\(state.kTerm)")
                .frame(width: EquationSizing.boxWidth)
            FixedText("+")
            log
        }
    }

    private var log: some View {
        HStack(spacing: 1) {
            FixedText("log")
            FixedText("(")
                .scaleEffect(y: largeParenScale)
            VStack(spacing: 1) {
                ChargedSymbolView(symbol: substance.chargedSymbol(ofPart: .secondaryIon))
                    .frame(width: EquationSizing.boxWidth)
                Rectangle()
                    .frame(width: 55, height: 2)
                ChargedSymbolView(symbol: substance.chargedSymbol(ofPart: .substance))
                    .frame(width: EquationSizing.boxWidth)
            }
            FixedText(")")
                .scaleEffect(y: largeParenScale)
        }
    }
}

private struct KWDefinition: View {
    var body: some View {
        HStack(spacing: hStackSpacing) {
            FixedText("Kw")
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
            FixedText("Ka")
            FixedText("x")
            FixedText("Kb")
        }
    }
}

private struct PHFilled: View {

    let state: EquationState
    let progress: CGFloat
    let pKAValue: CGFloat
    let phEquation: Equation
    let secondaryIonConcentration: Equation
    let substanceConcentration: Equation

    var body: some View {
        HStack(spacing: hStackSpacing) {
            element(phEquation, state.showAllTerms)
                .leftColElement()
            FixedText("=")
            PlaceholderTerm(
                value: state.showAllTerms ? pKAValue.str(decimals: 2) : nil
            )
            FixedText("+")
            log
        }
    }

    private var log: some View {
        HStack(spacing: 1) {
            FixedText("log")
            FixedText("(")
                .scaleEffect(y: largeParenScale)
            VStack(spacing: 1) {
                sizedElement(
                    secondaryIonConcentration,
                    state.showIonConcentration
                )
                Rectangle()
                    .frame(width: 55, height: 2)
                sizedElement(
                    substanceConcentration,
                    state.showSubstanceConcentration
                )
            }
            FixedText(")")
                .scaleEffect(y: largeParenScale)
        }
    }

    private func sizedElement(_ equation: Equation, _ show: Bool) -> some View {
        element(equation, show)
            .frame(width: EquationSizing.boxWidth, height: EquationSizing.boxHeight)
    }

    private func element(_ equation: Equation, _ show: Bool) -> some View {
        AnimatingNumberPlaceholder(
            showTerm: show,
            progress: progress,
            equation: equation,
            formatter: { $0.str(decimals: 2) }
        )
    }
}

private struct KWFilled: View {

    let showTerms: Bool
    let progress: CGFloat
    let kAValue: CGFloat
    let kBValue: CGFloat

    var body: some View {
        HStack(spacing: hStackSpacing) {
            kw
              .frame(width: EquationSizing.boxWidth)
            FixedText("=")
            term(kAValue)
            FixedText("x")
            term(kBValue)
        }
    }

    private var kw: some View {
        HStack(spacing: 0) {
            FixedText("10")
            FixedText("-14")
                .font(.system(size: EquationSizing.subscriptFontSize))
                .offset(y: -10)
        }
    }

    private func term(_ value: CGFloat) -> some View {
        PlaceholderTextLine(
            value: showTerms ? TextLineUtil.scientific(value: value).emphasised() : nil,
            expandedWidth: largeBoxWidth
        )
    }
}

private struct PHSumDefinition: View {
    var body: some View {
        HStack(spacing: hStackSpacing) {
            FixedText("14")
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
            FixedText("pH")
                .frame(width: EquationSizing.boxWidth)
            FixedText("+")
            FixedText("pOH")
                .frame(width: EquationSizing.boxWidth)
        }
    }
}

private extension View {
    // Places element in box width frame so that the content is
    // centered within that width, and then place it in the full width
    func leftColElement() -> some View {
        self
            .frame(
                width: EquationSizing.boxWidth,
                height: EquationSizing.boxHeight
            )
            .frame(width: largeBoxWidth, alignment: .trailing)
    }
}

private extension EquationState {
    var showSubstanceConcentration: Bool {
        if showIonConcentration {
            return true
        }
        switch self {
        case .weakAcidWithSubstanceConcentration,
             .weakBaseWithSubstanceConcentration:
            return true
        default: return false
        }
    }

    var showIonConcentration: Bool {
        switch self {
        case .weakAcidWithAllConcentration,
             .weakAcidFilled,
             .acidSummary,
             .weakBaseFilled,
             .baseSummary,
             .weakBaseWithAllConcentration:
            return true
        default: return false

        }
    }

    var showAllTerms: Bool {
        showAllAcidTerms || showAllBaseTerms
    }

    private var showAllAcidTerms: Bool {
        switch self {
        case .weakAcidFilled, .acidSummary: return true
        default: return false
        }
    }

    private var showAllBaseTerms: Bool {
        switch self {
        case .weakBaseFilled, .baseSummary: return true
        default: return false
        }
    }

    var showPKEquations: Bool {
        switch self {
        case .acidSummary, .baseSummary: return false
        default: return true
        }
    }

    var showKwEquations: Bool {
        switch self {
        case .weakAcidBlank,
             .weakAcidWithSubstanceConcentration,
             .weakAcidWithAllConcentration,
             .weakAcidFilled:
            return true
        default: return false
        }
    }

    var showPhSumAtBottom: Bool {
        !isAcid && !showPhSumAtTop
    }

    var showPhSumAtTop: Bool {
        self == .baseSummary
    }

    var isSummary: Bool {
        switch self {
        case .acidSummary, .baseSummary: return true
        default: return false
        }
    }

    var kTerm: String {
        isAcid ? "Ka" : "Kb"
    }

    var isAcid: Bool {
        switch self {
        case .weakAcidBlank,
             .weakAcidFilled,
             .weakAcidWithAllConcentration,
             .weakAcidWithSubstanceConcentration,
             .acidSummary:
            return true
        default: return false
        }
    }
}

private struct PHSumFilled: View {

    let showTerms: Bool
    let progress: CGFloat
    let pHEquation: Equation
    let pOHEquation: Equation

    var body: some View {
        HStack(spacing: hStackSpacing) {
            FixedText("14")
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
            term(pHEquation)
            FixedText("+")
            term(pOHEquation)
        }
    }

    private func term(_ equation: Equation) -> some View {
        AnimatingNumberPlaceholder(
            showTerm: showTerms,
            progress: progress,
            equation: equation,
            formatter: { $0.str(decimals: 2) }
        )
        .frame(width: EquationSizing.boxWidth)
    }
}

private let hStackSpacing: CGFloat = 5
private let largeBoxWidth: CGFloat = 2 * EquationSizing.boxWidth
private let leftColWidth: CGFloat = 350
private let rightColWidth: CGFloat = 440
private let spacerWidth: CGFloat = 150
private let largeParenScale: CGFloat = 2

private let NaturalWidth: CGFloat = 950
private let NaturalHeight: CGFloat = 400

struct BufferEquationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            equation(
                state: .weakAcidFilled,
                substance: .weakAcids[0]
            )
            equation(
                state: .weakBaseBlank,
                substance: .weakBases[0]
            )
        }
        .previewLayout(.sizeThatFits)
    }

    private static var allStates: some View {
        ForEach(BufferScreenViewModel.EquationState.allCases.indices.prefix(1)) { i in
            let state = BufferScreenViewModel.EquationState.allCases[i]
            VStack(spacing: 5) {
                Text(state.rawValue)
                equation(state: state)
            }
            .previewLayout(.sizeThatFits)
        }
    }

    private static func equation(
        state: BufferScreenViewModel.EquationState,
        substance: AcidOrBase = .strongAcids.first!
    ) -> some View {
        SizedBufferEquationView(
            progress: 1,
            state: state,
            data: BufferEquationData(
                substance: substance,
                concentration: SubstanceValue(builder: { _ in
                    ConstantEquation(value: 0.1)
                }),
                pH: ConstantEquation(value: 7)
            )
        )
        .previewLayout(.sizeThatFits)
        .border(Color.black)
        .frame(width: NaturalWidth, height: NaturalHeight)
        .border(Color.red)
    }
}
