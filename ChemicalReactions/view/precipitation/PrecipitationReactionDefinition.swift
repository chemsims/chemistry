//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PrecipitationReactionDefinition: View {

    let reaction: PrecipitationReaction
    let showMetal: Bool
    let fontSize: CGFloat

    var body: some View {
        HStack(spacing: 4) {
            unknownReactant
            knownReactant
            FixedText("➝")
            product
            secondaryProduct
        }
    }

    private var unknownReactant: some View {
        TextLinesView(
            line: reaction.unknownReactant.nameWithState(showMetal: showMetal),
            fontSize: fontSize
        )
    }

    private var knownReactant: some View {
        TextLinesView(
            line: reaction.knownReactant.nameWithState,
            fontSize: fontSize
        )
    }

    private var product: some View {
        TextLinesView(
            line: reaction.product.nameWithState,
            fontSize: fontSize
        )
    }

    private var secondaryProduct: some View {
        TextLinesView(
            line: reaction.secondaryProduct.nameWithState(showMetal: showMetal),
            fontSize: fontSize
        )
    }
}
