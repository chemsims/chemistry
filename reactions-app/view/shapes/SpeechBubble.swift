//
// Reactions App
//
  

import SwiftUI

struct SpeechBubble: View {
    var body: some View {
        SpeechBubbleShape()
            .fill(Color.mediumGray)
            .frame(width: 220, height: 200)
    }
}

struct SpeechBubbleShape: Shape {

    private let cornerRadius = 30

    private let stemWidth: CGFloat = 50
    private let stemBaseToBottom: CGFloat = 50
    private let stemHeight: CGFloat = 40
    private let stemCornerRadius: CGFloat = 10

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let size = CGSize(width: bubbleWidth(in: rect), height: rect.size.height)
        let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
        path.addRoundedRect(in: CGRect(origin: .zero, size: size), cornerSize: cornerSize)
        addStem(in: rect, using: &path)
        return path
    }

    private func addStem(in rect: CGRect, using path: inout Path)  {
        let bottomY = rect.height - stemBaseToBottom
        let leftX = bubbleWidth(in: rect)
        let bottomLeft = CGPoint(x: leftX, y: bottomY)
        let topRight = CGPoint(x: rect.width, y: bottomY - stemHeight)
        let topLeftPreCurve = CGPoint(x: leftX + stemCornerRadius, y: bottomY - stemHeight)

        path.move(to: bottomLeft)
        path.addLines([topRight, topLeftPreCurve])

        let topLeft = CGPoint(x: leftX, y: bottomY - stemHeight - stemCornerRadius)
        let control = CGPoint(x: leftX, y: bottomY - stemHeight)
        path.addQuadCurve(to: topLeft, control: control)

        path.addLine(to: bottomLeft)
        path.closeSubpath()
    }

    private func bubbleWidth(in rect: CGRect) -> CGFloat {
        max(rect.width / 2, rect.width - stemWidth)
    }

}

struct SpeechBubble_Previews: PreviewProvider {
    static var previews: some View {
        SpeechBubble()
    }
}
