//
// Reactions App
//
  

import CoreGraphics

struct TimeChartGeometrySettings {
    let chartSize: CGFloat
    let verticalTicks = 10
    let horizontalTicks = 10
    var tickSize: CGFloat {
        0.04 * chartSize
    }
    var gapFromMaxTickToChart: CGFloat {
        0.24 * chartSize
    }
    var sliderHandleWidth: CGFloat {
        0.16 * chartSize
    }
    var sliderHandleThickness: CGFloat {
        0.16 * chartSize
    }
    var sliderMinValuePadding: CGFloat {
        0.1 * chartSize
    }
    var sliderMaxValuePadding: CGFloat {
        0.28 * chartSize
    }
    var yLabelWidth: CGFloat {
        0.32 * chartSize
    }
    var handleThickness: CGFloat {
        0.08 * chartSize
    }
    var handleCornerRadius: CGFloat {
        handleThickness * 0.25
    }
    var labelFontSize: CGFloat {
        0.06 * chartSize
    }

}
