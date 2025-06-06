//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ReactionOrderSelection: View {

    @Binding var isToggled: Bool
    @Binding var selection: ReactionOrder
    let height: CGFloat

    var body: some View {
        DropDownSelectionView(
            title: "Choose a reaction",
            options: ReactionOrder.allCases,
            isToggled: $isToggled,
            selection: $selection,
            height: height,
            animation: Animation.easeOut(duration: 0.75),
            displayString: { TextLine(toString($0)) },
            label: toString,
            disabledOptions: [],
            onSelection: nil
        )
    }

    private func toString(_ order: ReactionOrder) -> String {
        "\(order.string) Order Reactions"
    }
}

fileprivate extension ReactionOrder {
    var string: String {
        switch self {
        case .Zero: return "Zero"
        case .First: return "First"
        case .Second: return "Second"
        }
    }
}

struct ReactionOrderSelection_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Spacer()
            Wrapper()
        }
    }

    struct Wrapper: View {
        @State var isToggled = true
        @State var selectedOrder = ReactionOrder.Zero

        var body: some View {
            ReactionOrderSelection(
                isToggled: $isToggled,
                selection: $selectedOrder,
                height: 50
            )
        }
    }
}
