//
// Reactions App
//

import SwiftUI

public struct MainMenuPanel: Shape {

    let tabWidth: CGFloat
    let tabHeight: CGFloat
    let cornerRadius: CGFloat

    public init(tabWidth: CGFloat, tabHeight: CGFloat, cornerRadius: CGFloat) {
        self.tabWidth = tabWidth
        self.tabHeight = tabHeight
        self.cornerRadius = cornerRadius
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let height = rect.size.height
        let width = rect.size.width

        let panelWidth = width - tabWidth
        let panelHeight = height - tabHeight
        let tabHeight = height - panelHeight

        path.addLines([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: height),
            CGPoint( x: panelWidth - cornerRadius, y: height)
        ])

        // Bottom right
        path.addQuadCurve(
            to: CGPoint(x: panelWidth, y: height - cornerRadius),
            control: CGPoint(x: panelWidth, y: height)
        )

        path.addLine(to: CGPoint(x: panelWidth, y: tabHeight + cornerRadius))

        // Tab left corner
        path.addQuadCurve(
            to: CGPoint(x: panelWidth + cornerRadius, y: tabHeight),
            control: CGPoint(x: panelWidth, y: tabHeight)
        )

        path.addLine(to: CGPoint(x: width - cornerRadius, y: tabHeight))

        // Tab right corner
        path.addQuadCurve(
            to: CGPoint(x: width, y: tabHeight - cornerRadius),
            control: CGPoint(x: width, y: tabHeight)
        )

        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))

        return path
    }

}

struct MainMenuPanel_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuPanel(
            tabWidth: 100,
            tabHeight: 130,
            cornerRadius: 20
        )
    }
}
