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
    let displayString: (Data) -> String

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
        .border(Color.black)
        .background(Color.white)
        .font(.system(size: height * 0.44))
        .minimumScaleFactor(0.8)
    }

    private func selection(
        _ option: Data
    ) -> some View {
        let selected = selection == option
        let background = selected ? Color.gray : Color.white
        let fontColor = selected ? Color.white : Color.black

        return Button(action: {
            if (selected) {
                isToggled = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(75)) {
                    isToggled = false
                }
                selection = option
            }
        }) {
            textBox(
                text: displayString(option)
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

    private var indicatorView: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
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
}

