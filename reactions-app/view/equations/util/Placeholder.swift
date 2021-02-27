//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct Placeholder: View {

    let value: String?
    let emphasise: Bool

    public init(
        value: String?,
        emphasise: Bool = false
    ) {
        self.value = value
        self.emphasise = emphasise
    }

    var body: some View {
        PlaceholderTerm(
            value: value,
            emphasise: emphasise,
            boxWidth: EquationSettings.boxWidth,
            boxHeight: EquationSettings.boxHeight,
            boxPadding: EquationSettings.boxPadding
        )
    }
}
