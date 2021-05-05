//
// Reactions App
//

import SwiftUI

public struct DropDownSelectionView<Data: Identifiable & Equatable>: View {

    let title: String
    let options: [Data]
    @Binding var isToggled: Bool
    @Binding var selection: Data
    let height: CGFloat
    let animation: Animation?
    let displayString: (Data) -> TextLine
    let label: (Data) -> String
    let disabledOptions: [Data]
    let onSelection: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool

    public init(
        title: String,
        options: [Data],
        isToggled: Binding<Bool>,
        selection: Binding<Data>,
        height: CGFloat,
        animation: Animation?,
        displayString: @escaping (Data) -> String,
        label: @escaping (Data) -> String,
        disabledOptions: [Data],
        onSelection: (() -> Void)?
    ) {
        self.title = title
        self.options = options
        self._isToggled = isToggled
        self._selection = selection
        self.height = height
        self.animation = animation
        self.displayString = {
            TextLine(stringLiteral: displayString($0))
        }
        self.label = label
        self.disabledOptions = disabledOptions
        self.onSelection = onSelection
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            selectionView
                .opacity(isToggled ? 1 : 0)
            indicatorView
                .accessibility(sortPriority: 2)
        }
        .lineLimit(1)
        .frame(width: height, alignment: .trailing)
        .accessibilityElement(children: .contain)
    }

    private let width: CGFloat = 1
    private var fontSize: CGFloat {
        height * 0.44
    }

    private var selectionView: some View {
        VStack(spacing: 0) {
            textBox(text: TextLine(stringLiteral: title), color: .black)
                .border(Color.black)
                .accessibility(addTraits: .isHeader)
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
        .accessibilityElement(children: .contain)
    }

    private func selection(
        _ option: Data
    ) -> some View {
        let selected = selection == option
        let background = selected ? Color.gray : Color.white

        return Button(action: {
            if selected {
                isToggled = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(75)) {
                    isToggled = false
                }
                withAnimation(reduceMotion ? nil : animation) {
                    selection = option
                }
            }
            onSelection?()
        }) {
            textBox(
                text: displayString(option),
                color: fontColor(option)
            )
            .background(background)
            .accessibility(addTraits: selected ? .isSelected : [])
            .accessibility(label: Text(label(option)))
        }
        .disabled(disabledOptions.contains(option))
    }

    private func textBox(
        text: TextLine,
        color: Color
    ) -> some View {
        TextLinesView(line: text, fontSize: fontSize, color: color)
            .padding(.leading, height * 0.2)
            .padding(.trailing, height * 0.2)
            .frame(
                width: 8 * height,
                height: height,
                alignment: .leading
            )
    }

    private var indicatorView: some View {
        let label = "\(isToggled ? "close" : "open") selection to \(title)"
        return ZStack {
            Button(action: { isToggled.toggle() }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.white)

                    Image(systemName: "chevron.up")
                        .animation(.linear)
                        .font(.system(size: height * 0.6))
                        .rotationEffect(isToggled ? .degrees(180) : .zero)
                        .animation(reduceMotion ? nil : .spring(response: 0.3))
                }
                .accessibilityElement()
                .accessibility(label: Text(label))
            }
            .buttonStyle(NavButtonButtonStyle())
        }
        .frame(
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
        if selected {
            return .white
        }
        return disabled ? Color.gray : Color.black
    }
}

struct DropDownSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            DropDownSelectionView(
                title: "foo",
                options: TempEnum.allCases,
                isToggled: .constant(true),
                selection: .constant(.A),
                height: 30,
                animation: nil,
                displayString: { "\($0.rawValue)"},
                label: { "\($0)"},
                disabledOptions: [.B],
                onSelection: nil
            )
        }
        .previewLayout(.fixed(width: 700, height: 200))
    }

    private enum TempEnum: String, CaseIterable, Identifiable {
        case A, B, C
        case D = "D^2^"

        var id: String {
            rawValue
        }
    }
}
