//
// Reactions App
//
  

import SwiftUI

struct DoubleHeadedArrow: Shape {

    let arrowHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.size.width / 2
        path.addLines(
            [
                CGPoint(x: 0, y: arrowHeight),
                CGPoint(x: midX, y: 0),
                CGPoint(x: rect.size.width, y: arrowHeight)
            ]
        )
        path.move(to: CGPoint(x: midX, y: 0))
        path.addLine(to: CGPoint(x: midX, y: rect.size.height))

        path.move(to: CGPoint(x: 0, y: rect.size.height - arrowHeight))
        path.addLines([
            CGPoint(x: 0, y: rect.size.height - arrowHeight),
            CGPoint(x: midX, y: rect.size.height),
            CGPoint(x: rect.size.width, y: rect.size.height - arrowHeight)
        ])

        return path
    }
}

struct DoubleHeadedArrow_Previews: PreviewProvider {
    static var previews: some View {
        DoubleHeadedArrow(arrowHeight: 10)
            .frame(width: 20)
    }
}
