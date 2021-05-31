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
                        value: concentration.str(decimals: 2),
                        emphasise: true
                    )
                } else {
                    filledValue(parts: parts!)
                }
            } else {
                PlaceholderTerm(value: nil)
            }
        }
        .font(.system(size: EquationSizing.fontSize))
        .frame(
            width: 1.5 * EquationSizing.boxWidth,
            height: EquationSizing.boxHeight,
            alignment: .leading
        )
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
