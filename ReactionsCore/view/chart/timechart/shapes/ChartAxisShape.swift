//
// Reactions App
//

import SwiftUI

public struct ChartAxisShape: Shape {
    public let settings: ChartAxisShapeSettings

    public init(
        settings: ChartAxisShapeSettings
    ) {
        self.settings = settings
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addRect(rect)
        let dy = (rect.height - settings.gapToTop) / CGFloat(settings.verticalTicks)
        for i in 1...settings.verticalTicks {
            let distanceFromBottom = CGFloat(i) * dy
            let y = rect.height - distanceFromBottom
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: settings.tickSize, y: y))
        }

        let dx = (rect.width - settings.gapToSide) / CGFloat(settings.horizontalTicks)
        for i in 1...settings.horizontalTicks {
            let x = CGFloat(i) * dx
            path.move(to: CGPoint(x: x, y: rect.height))
            path.addLine(to: CGPoint(x: x, y: rect.height - settings.tickSize))
        }
        return path
    }

}

struct ChartAxisShape_Previews: PreviewProvider {
    static var previews: some View {
        ChartAxisShape(
            settings: ChartAxisShapeSettings(
                verticalTicks: 10,
                horizontalTicks: 10,
                tickSize: 10,
                gapToTop: 100,
                gapToSide: 100
            )
        )
        .stroke()
        .frame(width: 350, height: 350)
    }
}
