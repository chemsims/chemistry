//
// Reactions App
//


import SwiftUI

struct BuyButton: View {

    let cornerRadius: CGFloat
    let sideColor: Color
    let faceColor: Color
    let text: String
    let action: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(sideColor)

                Button(action: action) {
                    face
                }
                .buttonStyle(BuyButtonStyle(
                    openOffset: -0.05 * geo.size.height,
                    closedOffset: -0.01 * geo.size.height
                ))
            }
        }
    }

    private var face: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(faceColor)

            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke()
                .foregroundColor(sideColor)

            Text(text)
        }
    }
}

private struct BuyButtonStyle: ButtonStyle {

    let openOffset: CGFloat
    let closedOffset: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .offset(y: configuration.isPressed ? closedOffset : openOffset)
    }
}

struct BuyButton_Previews: PreviewProvider {
    static var previews: some View {
        BuyButton(
            cornerRadius: 10,
            sideColor: .buyButtonBorder,
            faceColor: .buyButtonBackground,
            text: "Buy now",
            action: { }
        )
            .frame(width: 200, height: 50)
    }
}
