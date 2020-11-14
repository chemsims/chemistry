//
// Reactions App
//
  

import SwiftUI

struct BarChartGeometrySettings {

    let chartWidth: CGFloat
    let maxConcentration: CGFloat
    let minConcentration: CGFloat

    let ticks = 10

    var maxValueGapToTop: CGFloat {
        0.25 * chartWidth
    }
    var zeroHeight: CGFloat {
        0.07 * chartWidth
    }

    var yAxisTickSize: CGFloat {
        0.05 * chartWidth
    }
    var barWidth: CGFloat {
        0.15 * chartWidth
    }
    var barAGapToAxis: CGFloat {
        0.2 * chartWidth
    }
    var labelDiameter: CGFloat {
        0.1 * chartWidth
    }
    var labelFontSize: CGFloat {
        0.1 * chartWidth
    }

    var barACenterX: CGFloat {
        chartWidth / 4
    }
    var barBCenterX: CGFloat {
        barACenterX * 3
    }
    
    var barMinHeight: CGFloat {
        tickDy / 5
    }

    var tickDy: CGFloat {
        chartWidth / CGFloat(ticks + 1)
    }

}
