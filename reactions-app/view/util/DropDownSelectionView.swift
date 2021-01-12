//
// Reactions App
//
  

import SwiftUI

struct DropDownSelectionView<Data: Identifiable & Equatable>: View {

    let title: String
    let options: [Data]
    @Binding var isToggled: Bool
    @Binding var selection: Data
    let height: CGFloat
    let animation: Animation?
    let displayString: (Data) -> String
    let disabledOptions: [Data]
    let onSelection: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            selectionView
                .opacity(isToggled ? 1 : 0)
            indicatorView
        }
        .lineLimit(1)
        .frame(width: height, alignment: .trailing)
    }

    private let width: CGFloat = 1

    private var selectionView: some View {
        VStack(spacing: 0) {
            textBox(text: title)
                .border(Color.black)
            VStack(spacing: 0) {
                ForEach(options) { option in
                    selection(option)
                }
            }
            .compositingGroup()
            .shadow(radius: height * 0.07)
        }
        .border(Color.black, width: width)
        .background(Color.white)
        .font(.system(size: height * 0.44))
        .minimumScaleFactor(0.8)
    }

    private func selection(
        _ option: Data
    ) -> some View {
        let selected = selection == option
        let background = selected ? Color.gray : Color.white

        return Button(action: {
            onSelection?()
            if (selected) {
                isToggled = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(75)) {
                    isToggled = false
                }
                withAnimation(reduceMotion ? nil : animation) {
                    selection = option
                }
            }
        }) {
            textBox(
                text: displayString(option)
            )
            .background(background)
            .foregroundColor(fontColor(option))
        }
        .disabled(disabledOptions.contains(option))
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

    private var indicatorView: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
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
        )
        .foregroundColor(.black)
        .border(Color.black, width: width)
        .offset(x: -width)
    }

    private func fontColor(_ option: Data) -> Color {
        let disabled = disabledOptions.contains(option)
        let selected = selection == option
        if (selected) {
            return .white
        }
        return disabled ? Color.gray : Color.black
    }
}

struct DropDownSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
//            Rectangle()

            DropDownSelectionView(
                title: "foo",
                options: ReactionOrder.allCases,
                isToggled: .constant(true),
                selection: .constant(.Zero),
                height: 30,
                animation: nil,
                displayString: { "\($0)"},
                disabledOptions: [.First],
                onSelection: nil
            )
        }
        .previewLayout(.fixed(width: 700, height: 200))
    }
}

