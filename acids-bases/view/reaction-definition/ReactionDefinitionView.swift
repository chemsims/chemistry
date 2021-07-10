//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ReactionDefinitionView: View {

    let leftTerms: [Term]
    let rightTerms: [Term]
    let fontSize: CGFloat
    let circleSize: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            row(showTerms: true)
            row(showTerms: false)
        }
    }

    private func row(showTerms: Bool = true) -> some View {
        HStack(spacing: 5) {
            concatTerms(leftTerms, showTerms: showTerms)
            arrow
                .opacity(showTerms ? 1 : 0)
            concatTerms(rightTerms, showTerms: showTerms)
        }
    }

    private func concatTerms(
        _ terms: [Term],
        showTerms: Bool = true
    ) -> some View {
        VStack {
            HStack(alignment: .top, spacing : 2) {
                if terms.count > 1 {
                    termView(terms.first!, showTerm: showTerms)
                }
                ForEach(terms.indices.dropFirst(1), id: \.self) { i in
                    plus
                        .opacity(showTerms ? 1 : 0)
                    termView(terms[i], showTerm: showTerms)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var arrow: some View {
        FixedText("⇌")
            .font(.system(size: 1.2 * fontSize))
    }

    private var plus: some View {
        FixedText("+")
            .font(.system(size: fontSize))
    }

    private func termView(_ term: Term, showTerm: Bool = true) -> some View {
        TextLinesView(line: term.name, fontSize: fontSize)
            .opacity(showTerm ? 1 : 0)
            .overlay(termOverlay(term, showTerm: showTerm), alignment: .top)
    }

    @ViewBuilder
    private func termOverlay(_ term: Term, showTerm: Bool) -> some View {
        if showTerm {
            EmptyView()
        } else {
            Circle()
                .foregroundColor(term.color)
                .frame(square: circleSize)
        }
    }

    struct Term {
        let name: TextLine
        let color: Color
    }
}

struct AcidReactionDefinition {
    let leftTerms: [Term]
    let rightTerms: [Term]

    struct Term {
        let name: TextLine
        let color: Color
    }
}

struct ReactionDefinitionView_Previews: PreviewProvider {
    static var previews: some View {
        ReactionDefinitionView(
            leftTerms: [
                .init(name: "A", color: .red),
                .init(name: "H_2_O", color: .purple)
            ],
            rightTerms: [
                .init(name: "OH", color: .orange),
                .init(name: "K", color: .blue)
            ],
            fontSize: 20,
            circleSize: 20
        )
        .frame(height: 60)
        .minimumScaleFactor(0.5)
    }
}
