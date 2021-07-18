//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ConcentrationPlaceholder: View {

    let concentration: CGFloat
    let showValue: Bool

    var body: some View {
        Group {
            if showValue {
                if parts == nil {
                    PlaceholderTerm(
                        value: nonScientificValue,
                        emphasise: true
                    )
                } else {
                    filledValue(parts: parts!)
                }
            } else {
                PlaceholderTerm(value: nil)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibility(value: Text(accessibilityValue))
        .font(.system(size: EquationSizing.fontSize))
        .frame(
            width: 1.5 * EquationSizing.boxWidth,
            height: EquationSizing.boxHeight,
            alignment: .leading
        )
    }

    private var nonScientificValue: String {
        concentration.str(decimals: 2)
    }

    private var accessibilityValue: String {
        if !showValue {
            return "Placeholder"
        }
        if parts != nil {
            return TextLineUtil.scientific(value: concentration).label
        }
        return nonScientificValue
    }

    private var parts: (String, String)? {
        TextLineUtil.scientificComponents(value: concentration)
    }

    private func filledValue(parts: (String, String)) -> some View {
        Group {
            Text(parts.0) +
            Text(parts.1)
                .font(.system(size: EquationSizing.subscriptFontSize))
                .baselineOffset(10)
        }
        .foregroundColor(.orangeAccent)
    }
}

struct ConcentrationPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ConcentrationPlaceholder(
                concentration: 1.23e-120, showValue: true
            )
            .minimumScaleFactor(0.5)


            ConcentrationPlaceholder(
                concentration: 1e-120, showValue: false
            )
        }
    }
}
