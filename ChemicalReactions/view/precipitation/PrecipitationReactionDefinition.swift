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
        }
    }

    private var unknownReactant: some View {
        TextLinesView(
            line: showMetal ? reaction.unknownReactant.knownDisplay : reaction.unknownReactant.unknownDisplay,
            fontSize: fontSize
        )
    }

    private var knownReactant: some View {
        TextLinesView(
            line: reaction.knownReactant.display,
            fontSize: fontSize
        )
    }

    private var product: some View {
        TextLinesView(
            line: reaction.product.display,
            fontSize: fontSize
        )
    }
}

//struct PrecipitationReactionDefinition_Previews: PreviewProvider {
//    static var previews: some View {
//        PrecipitationReactionDefinition()
//    }
//}
