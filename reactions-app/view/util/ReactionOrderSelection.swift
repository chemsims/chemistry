//
// Reactions App
//
  

import SwiftUI

struct ReactionOrderSelection: View {

    @Binding var isToggled: Bool
    @Binding var selection: ReactionOrder
    let height: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            selectionView
                .opacity(isToggled ? 1 : 0)
            indicatorView
        }
        .lineLimit(1)
        .frame(width: height, alignment: .trailing)
    }

    private var selectionView: some View {
        VStack(spacing: 0) {
            textBox(
                text: "Choose a reaction"
            ).border(Color.black)
            VStack(spacing: 0) {
                selection(reaction: .Zero)
                selection(reaction: .First)
                selection(reaction: .Second)
            }
            .compositingGroup()
            .shadow(radius: height * 0.07)
        }
        .border(Color.black)
        .background(Color.white)
        .font(.system(size: height * 0.44))
        .minimumScaleFactor(0.8)
    }

    private var indicatorView: some View {
        ZStack {
            Rectangle()
                .stroke()
            Button(action: { isToggled.toggle() }) {
                Image(systemName: "chevron.up")
                    .animation(.linear)
                    .font(.system(size: height * 0.6))
                    .rotationEffect(isToggled ? .degrees(180) : .zero)
                    .animation(.spring(response: 0.3))
            }.buttonStyle(NavButtonButtonStyle())
        }.frame(
            width: height,
            height: height
        ).foregroundColor(.black)
    }

    private func selection(
        reaction: ReactionOrder
    ) -> some View {
        let selected = selection == reaction
        let background = selected ? Color.gray : Color.white
        let fontColor = selected ? Color.white : Color.black

        return Button(action: {
            if (selected) {
                isToggled = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(75)) {
                    isToggled = false
                }   

                selection = reaction
            }
        }) {
            textBox(
                text: "\(reaction.string) Order Reactions"
            )
            .background(background)
            .foregroundColor(fontColor)
        }
    }

    private func textBox(
        text: String
    ) -> some View {
        Text(text)
            .padding(.leading, height * 0.2)
            .padding(.trailing, height * 0.2)
            .frame(
                width: 8 * height,
                height: height,
                alignment: .leading
            )
    }
}

fileprivate extension ReactionOrder {
    var string: String {
        switch (self) {
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
