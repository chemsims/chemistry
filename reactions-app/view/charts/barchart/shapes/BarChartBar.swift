//
// Reactions App
//
  

import SwiftUI

struct BarChartBarShape: Shape {

    let settings: BarChartGeometrySettings
    let concentrationEquation: Equation
    let barCenterX: CGFloat
    var currentTime: CGFloat

    var animatableData: CGFloat {
        get { currentTime }
        set { currentTime = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let maxBarHeight = settings.chartWidth - settings.tickDy - settings.maxValueGapToTop

        let leftX = barCenterX - (settings.barWidth / 2)
        let bottomY = settings.chartWidth - settings.tickDy

        let concentration = concentrationEquation.getY(at: currentTime)
        let dc = settings.maxConcentration - settings.minConcentration
        let valuePercentage = concentration / dc
        let barHeight = (valuePercentage * maxBarHeight) + settings.barMinHeight

        let topY = bottomY - barHeight

        path.addRect(
            CGRect(
                origin: CGPoint(x: leftX, y: topY),
                size: CGSize(width: settings.barWidth, height: barHeight)
            )
        )

        return path
    }
}
