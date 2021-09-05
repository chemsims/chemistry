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
    let highlights: HighlightedElements<BufferScreenElement>

    var body: some View {
        GeometryReader { geo in
            SizedBufferEquationView(
                progress: progress,
                state: state,
                data: data,
                highlights: highlights
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
    let highlights: HighlightedElements<BufferScreenElement>

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
            .highlighted(
                element: .kEquation,
                highlights: highlights,
                insets: .withDefaults(
                    leading: largeBoxExtraSize,
                    trailing: -20
                )
            )
            .frame(width: leftColWidth, alignment: .leading)
            .accessibilityElement(children: .contain)
            .accessibility(sortPriority: 10)

            Spacer()

            if state.showPKEquations {
                PKADefinition(state: state)
                    .highlighted(
                        element: .pKEquation,
                        highlights: highlights,
                        insets: .withDefaults(trailing: -10)
                    )
                    .frame(width: rightColWidth, alignment: .leading)
                    .accessibilityElement(children: .contain)
                    .accessibility(sortPriority: 5)
            }

            if state.showPhSumAtTop {
                phSumDefinition
                    .accessibility(sortPriority: 5)
            }
        }
    }

    private var row1: some View {
        HStack(spacing: 0) {
            KAFilled(
                substance: data.substance,
                state: state,
                kValue: state.isAcid ? data.kA : data.kB,
                pKAValue: data.pKa,
                concentration: data.concentration,
                progress: progress
            )
            .frame(width: leftColWidth, alignment: .leading)
            .colorMultiply(noHighlight)
            .accessibilityElement(children: .contain)
            .accessibility(sortPriority: 9)

            Spacer()

            if state.showPKEquations {
                PKAFilled(
                    state: state,
                    showTerms: state.showAllTerms,
                    pKAValue: data.pKa,
                    kaValue: data.kA
                )
                .frame(width: rightColWidth, alignment: .leading)
                .colorMultiply(noHighlight)
                .accessibility(sortPriority: 4)
            }

            if state.showPhSumAtTop {
                phSumFilled
                    .accessibility(sortPriority: 4)
            }
        }
    }

    private var row2: some View {
        HStack(spacing: 0) {
            PHDefinition(substance: data.substance, state: state)
                .frame(width: leftColWidth, alignment: .leading)
                .highlighted(
                    element: .hasselbalchEquation,
                    highlights: highlights,
                    insets: .withDefaults(leading: largeBoxExtraSize)
                )
                .accessibilityElement(children: .contain)
                .accessibility(sortPriority: 8)

            Spacer()

            if state.showKwEquations {
                KWDefinition()
                    .frame(width: rightColWidth, alignment: .leading)
                    .highlighted(
                        element: .kWEquation,
                        highlights: highlights,
                        insets: .withDefaults(trailing: 220)
                    )
                    .accessibilityElement(children: .contain)
                    .accessibility(sortPriority: 3)
            }

            if state.showPhSumAtBottom {
                phSumDefinition
                    .accessibility(sortPriority: 3)
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
                substanceConcentration: data.concentration.substance,
                substance: data.substance
            )
            .frame(width: leftColWidth, alignment: .leading)
            .colorMultiply(noHighlight)
            .accessibilityElement(children: .contain)
            .accessibility(sortPriority: 7)

            Spacer()

            if state.showKwEquations  {
                KWFilled(
                    showTerms: state.showAllTerms,
                    progress: progress,
                    kAValue: data.kA,
                    kBValue: data.kB
                )
                .frame(width: rightColWidth, alignment: .leading)
                .colorMultiply(noHighlight)
                .accessibilityElement(children: .contain)
                .accessibility(sortPriority: 2)
            }

            if state.showPhSumAtBottom {
                phSumFilled
                    .accessibility(sortPriority: 2)
            }
        }
    }

    private var phSumDefinition: some View {
        PHSumDefinition()
            .frame(width: rightColWidth, alignment: .leading)
            .accessibilityElement(children: .contain)
    }

    private var phSumFilled: some View {
        PHSumFilled(
            showTerms: state.showAllTerms,
            progress: progress,
            pHEquation: data.pH,
            pOHEquation: data.pOH
        )
        .frame(width: rightColWidth, alignment: .leading)
        .colorMultiply(noHighlight)
        .accessibilityElement(children: .contain)
    }

    private var noHighlight: Color {
        highlights.colorMultiply(for: nil)
    }
}

private extension View {

    func highlighted(
        element: BufferScreenElement?,
        highlights: HighlightedElements<BufferScreenElement>,
        insets: EdgeInsets = .withDefaults()
    ) -> some View {
        self.modifier(
            BufferEquationHighlightModifier(
                element: element,
                highlights: highlights,
                insets: insets
            )
        )
    }
}

private struct BufferEquationHighlightModifier: ViewModifier {

    let element: BufferScreenElement?
    let highlights: HighlightedElements<BufferScreenElement>
    let insets: EdgeInsets

    func body(content: Content) -> some View {
        content
            .background(Color.white.padding(insets))
            .colorMultiply(highlights.colorMultiply(for: element))
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
                TextLinesView(line: TextLineUtil.scientific(value: fixedK), fontSize: EquationSizing.fontSize)
                    .fixedSize()
            } else {
                fraction
            }
        }
        .frame(height: 2 * EquationSizing.boxHeight + 8)
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
    }

    private var label: String {
        if state.isSummary {
            return "\(state.kTerm) = \(TextLineUtil.scientific(value: fixedK).label)"
        }
        let numeratorLabel = concatLabels(substance.productParts)
        let denomLabel = substance.symbol.label

        return "\(state.kTerm) = \(numeratorLabel) divided by \(denomLabel)"
    }

    private func concatLabels(_ parts: [SubstancePart]) -> String {
        let labels = parts.map { substance.chargedSymbol(ofPart: $0).text.label }
        return StringUtil.combineStrings(labels, separator: " times ")
    }

    private var fraction: some View {
        VStack(spacing: 3) {
            HStack(alignment: .top, spacing: 1) {
                ForEach(substance.productParts) { part in
                    ChargedSymbolView(symbol: substance.chargedSymbol(ofPart: part))
                }
            }
            Rectangle()
                .frame(width: 115, height: 2)
            ChargedSymbolView(
                symbol: substance.chargedSymbol(ofPart: .substance)
            )
        }
        .frame(height: 100)
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
        .accessibilityElement(children: .ignore)
        .accessibilityParsedLabel("p\(state.kTerm) = minus log of \(state.kTerm)")
    }
}

private struct KAFilled: View {
    let substance: AcidOrBase
    let state: EquationState
    let kValue: CGFloat
    let pKAValue: CGFloat
    let concentration: SubstanceValue<Equation>
    let progress: CGFloat

    var body: some View {
        HStack(spacing: hStackSpacing) {
            if state.isSummary {
                FixedText("pKa")
                    .leftColElement()
            } else {
                kAView
                    .accessibility(sortPriority: 5)
            }

            FixedText("=")
                .accessibility(sortPriority: 4)

            if state.isSummary {
                FixedText(pKAValue.str(decimals: 3))
            } else {
                fraction
                    .accessibility(sortPriority: 1)
            }
        }
        .frame(height: 2 * EquationSizing.boxHeight + 8)
        .modifyIf(state.isSummary) {
            $0
                .accessibilityElement(children: .ignore)
                .accessibilityParsedLabel("pKa = \(pKAValue.str(decimals: 3))")
        }
    }

    private var kAView: some View {
        PlaceholderTextLine(
            value: state.showAllTerms ? TextLineUtil.scientific(value: kValue).emphasised() : nil,
            expandedWidth: largeBoxWidth
        )
        .accessibilityParsedLabel(state.kTerm)
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
                .frame(width: 270, height: 2)
                .accessibility(label: Text("divide by"))
            concentration(.substance, state.showSubstanceConcentration)
        }
    }

    private func concentration(
        _ part: SubstancePart,
        _ show: Bool
    ) -> some View {
        HStack(spacing: 0) {
            FixedText("(")
                .accessibility(hidden: true)
            ScientificTextLinePlaceholder(
                showValue: show,
                equationInput: progress,
                equation: concentration.value(for: part)
            )
            FixedText(")")
                .accessibility(hidden: true)
        }
        .accessibility(
            label: Text("concentration of \(substance.chargedSymbol(ofPart: part).text.label)")
        )
    }
}

private struct PKAFilled: View {

    let state: EquationState
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
        .accessibilityParsedLabel("p\(state.kTerm)")
    }

    private var ka: some View {
        HStack(spacing: 1) {
            FixedText("-log(")
                .accessibility(label: Text("minus log"))
            PlaceholderTextLine(
                value: showTerms ? TextLineUtil.scientific(value: kaValue).emphasised() : nil,
                expandedWidth: largeBoxWidth
            )
            .accessibilityParsedLabel(state.kTerm)
            FixedText(")")
                .accessibility(hidden: true)
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
        .frame(height: 80)
        .accessibilityElement(children: .ignore)
        .accessibilityParsedLabel(label)
    }

    private var label: String {
        let numer = substance.chargedSymbol(ofPart: .secondaryIon).text.label
        let denom = substance.symbol.label
        return "pH = p\(state.kTerm) + log of \(numer) divide by \(denom) "
    }

    private var log: some View {
        HStack(spacing: 1) {
            FixedText("log")
            FixedText("(")
                .scaleEffect(y: largeParenScale)
            VStack(spacing: 1) {
                ChargedSymbolView(
                    symbol: substance.chargedSymbol(ofPart: .secondaryIon)
                )
                Rectangle()
                    .frame(width: 55, height: 2)
                ChargedSymbolView(
                    symbol: substance.chargedSymbol(ofPart: .substance)
                )
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
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Kw = Ka times Kb"))
    }
}

private struct PHFilled: View {

    let state: EquationState
    let progress: CGFloat
    let pKAValue: CGFloat
    let phEquation: Equation
    let secondaryIonConcentration: Equation
    let substanceConcentration: Equation
    let substance: AcidOrBase

    var body: some View {
        HStack(spacing: hStackSpacing) {
            element(phEquation, state.showAllTerms)
                .leftColElement()
                .accessibilityParsedLabel("pH")
                .accessibility(sortPriority: 10)

            FixedText("=")
                .accessibility(sortPriority: 9)

            PlaceholderTerm(
                value: state.showAllTerms ? pKAValue.str(decimals: 2) : nil
            )
            .accessibilityParsedLabel("p\(state.kTerm)")
            .accessibility(sortPriority: 8)

            FixedText("+")
                .accessibility(sortPriority: 7)

            log
        }
    }

    private var log: some View {
        HStack(spacing: 1) {
            FixedText("log")
                .accessibility(sortPriority: 7)

            FixedText("(")
                .scaleEffect(y: largeParenScale)
                .accessibility(hidden: true)

            VStack(spacing: 1) {
                concentration(
                    secondaryIonConcentration,
                    state.showIonConcentration
                )
                .accessibility(label: Text("Concentration of \(substance.chargedSymbol(ofPart: .secondaryIon).text.label)"))

                Rectangle()
                    .frame(width: 85, height: 2)
                    .accessibility(label: Text("divide by"))

                concentration(
                    substanceConcentration,
                    state.showSubstanceConcentration
                )
                .accessibility(label: Text("Concentration of \(substance.symbol.label)"))
            }

            FixedText(")")
                .scaleEffect(y: largeParenScale)
                .accessibility(hidden: true)
        }
    }

    private func concentration(_ equation: Equation, _ show: Bool) -> some View {
        ScientificTextLinePlaceholder(
            showValue: show,
            equationInput: progress,
            equation: equation
        )
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
                .accessibility(label: Text("Ka"))

            FixedText("x")
                .accessibility(label: Text("times"))

            term(kBValue)
                .accessibility(label: Text("Kb"))
        }
    }

    private var kw: some View {
        HStack(spacing: 0) {
            FixedText("10")
            FixedText("-14")
                .font(.system(size: EquationSizing.subscriptFontSize))
                .offset(y: -10)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Kw"))
        .accessibility(value: Text("10 to the power of minus 14"))
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
        .accessibilityElement(children: .ignore)
        .accessibilityParsedLabel("14 = pH + pOH")
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
        case .acidWithSubstanceConcentration,
             .baseWithSubstanceConcentration:
            return true
        default: return false
        }
    }

    var showIonConcentration: Bool {
        switch self {
        case .acidWithAllConcentration,
             .acidFilled,
             .acidSummary,
             .baseFilled,
             .baseSummary,
             .baseWithAllConcentration:
            return true
        default: return false

        }
    }

    var showAllTerms: Bool {
        showAllAcidTerms || showAllBaseTerms
    }

    private var showAllAcidTerms: Bool {
        switch self {
        case .acidFilled, .acidSummary: return true
        default: return false
        }
    }

    private var showAllBaseTerms: Bool {
        switch self {
        case .baseFilled, .baseSummary: return true
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
        case .acidBlank,
             .acidWithSubstanceConcentration,
             .acidWithAllConcentration,
             .acidFilled:
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
        case .acidBlank,
             .acidFilled,
             .acidWithAllConcentration,
             .acidWithSubstanceConcentration,
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
                .accessibilityParsedLabel("pH")
            FixedText("+")
            term(pOHEquation)
                .accessibilityParsedLabel("pOH")
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

private struct ScientificTextLinePlaceholder: View {

    let showValue: Bool
    let equationInput: CGFloat
    let equation: Equation

    var body: some View {
        if showValue {
            AnimatingTextLine(
                x: equationInput,
                equation: equation,
                fontSize: EquationSizing.fontSize,
                formatter: formatter
            )
            .frame(
                width: largeBoxWidth,
                height: EquationSizing.boxHeight
            )
        } else {
            PlaceholderTerm(value: nil)
                .frame(
                    width: largeBoxWidth,
                    height: EquationSizing.boxHeight
                )
                .accessibility(value: Text("Place-holder"))
        }
    }

    private func formatter(value: CGFloat) -> TextLine {
        EquationTermFormatter.scientific(
            threshold: 0.01,
            nonScientificDecimalPlaces: 3
        ).format(value).emphasised()
    }
}

private let hStackSpacing: CGFloat = 5
private let largeBoxWidth: CGFloat = 2 * EquationSizing.boxWidth
private let leftColWidth: CGFloat = 510
private let rightColWidth: CGFloat = 440
private let spacerWidth: CGFloat = 50
private let largeParenScale: CGFloat = 2

private let largeBoxExtraSize: CGFloat = largeBoxWidth - EquationSizing.boxWidth

private let NaturalWidth: CGFloat = leftColWidth + spacerWidth + rightColWidth
private let NaturalHeight: CGFloat = 440

struct BufferEquationView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            equation(
                state: .baseWithAllConcentration,
                substance: .weakAcids[0]
            )

            equation(
                state: .baseWithAllConcentration,
                substance: .weakBases[2]
            )
        }
        .previewLayout(.sizeThatFits)
    }

    private static var allStates: some View {
        ForEach(BufferScreenViewModel.EquationState.allCases, id: \.id) { state in
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
            ),
            highlights: .init(elements: [.hasselbalchEquation])
        )
        .previewLayout(.sizeThatFits)
        .border(Color.black)
        .frame(width: NaturalWidth, height: NaturalHeight)
        .border(Color.red)
        .background(Styling.inactiveScreenElement)
    }
}

private extension BufferScreenViewModel.EquationState {
    var id: Int {
        Self.allCases.firstIndex(of: self)!
    }
}
