//
// Reactions App
//
  

import SwiftUI

struct BarChartBarShape: Shape {

    let settings: BarChartGeometrySettings
    let concentrationEquation: ConcentrationEquation
    let barCenterX: CGFloat
    var currentTime: CGFloat

    var animatableData: CGFloat {
        get { currentTime }
        set { currentTime = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let tickDy = settings.chartWidth / CGFloat(settings.ticks + 1)

        let maxBarHeight = settings.chartWidth - tickDy - settings.maxValueGapToTop

        let leftX = barCenterX - (settings.barWidth / 2)
        let bottomY = settings.chartWidth - settings.tickSize

        let concentration = concentrationEquation.getConcentration(at: currentTime)
        let dc = settings.maxConcentration - settings.minConcentration
        let valuePercentage = concentration / dc
        let barHeight = valuePercentage * maxBarHeight

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
