//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AcidBasesScreenLayout {
    let geometry: GeometryProxy
    let verticalSizeClass: UserInterfaceSizeClass?
    let horizontalSizeClass: UserInterfaceSizeClass?

    var width: CGFloat {
        geometry.size.width
    }

    var height: CGFloat {
        geometry.size.height
    }

    var leftColumnWidth: CGFloat {
        0.33 * width
    }

    var rightColumnWidth: CGFloat {
        width - leftColumnWidth
    }

    var beakyBoxWidth: CGFloat {
        rightColumnWidth / 2
    }

    var beakyBoxHeight: CGFloat {
        0.35 * height
    }

    var chartColumnWidth: CGFloat {
        rightColumnWidth - beakyBoxWidth
    }

    var beakySettings: BeakyGeometrySettings {
        BeakyGeometrySettings(
            width: beakyBoxWidth,
            height: beakyBoxHeight
        )
    }

    var bottomRightTotalHeight: CGFloat {
        max(barChartSettings.totalHeight, beakyBoxHeight)
    }
}

// MARK: Beaker/slider geometry
extension AcidBasesScreenLayout {
    var beakerWidth: CGFloat {
        0.7 * leftColumnWidth
    }

    var beakerHeight: CGFloat {
        beakerWidth * BeakerSettings.heightToWidth
    }

    var beakerSettings: BeakerSettings {
        BeakerSettings(width: beakerWidth, hasLip: true)
    }

    var sliderSettings: SliderGeometrySettings {
        SliderGeometrySettings(handleWidth: 0.13 * beakerWidth)
    }

    var sliderHeight: CGFloat {
        0.8 * beakerHeight
    }

    // TODO - when bar chart is added, return x axis label height instead of 0
    var beakerBottomPadding: CGFloat {
        if verticalSizeClass.contains(.regular) {
            return 0 // chartSettings.xAxisLabelHeight
        }
        return 0
    }

    var moleculeSize: CGFloat {
        beakerSettings.innerBeakerWidth / CGFloat(MoleculeGridSettings.cols)
    }

    /// Returns the y position of the top of the water for the given number of `rows`, from the top of the screen
    func topOfWaterPosition(rows: CGFloat) -> CGFloat {
        let topFromSlider = sliderAxis.getPosition(at: rows)
        return height - sliderHeight + topFromSlider - beakerBottomPadding
    }

    /// Returns the water height for the given number of `rows`
    func waterHeight(rows: CGFloat) -> CGFloat {
        sliderHeight - sliderAxis.getPosition(at: rows)
    }

    private var sliderAxis: AxisPositionCalculations<CGFloat> {
        BeakerLiquidSliderAxis.axis(
            minRows: AcidAppSettings.minBeakerRows,
            maxRows: AcidAppSettings.maxBeakerRows,
            beakerWidth: beakerWidth,
            sliderHeight: sliderHeight
        )
    }
}

// MARK: PHScale geometry
extension AcidBasesScreenLayout {
    var phMeterSize: CGSize {
        CGSize(
            width: 0.3 * beakerWidth,
            height: 0.35 * beakerWidth
        )
    }

    var phMeterFontSize: CGFloat {
        0.06 * beakerWidth
    }
}

// MARK: Container geometry
extension AcidBasesScreenLayout {
    var containerSize: CGSize {
        let width = 0.1 * beakerWidth
        return CGSize(
            width: width,
            height: ParticleContainer.heightToWidth * width
        )
    }

    var containerFontSize: CGFloat {
        0.45 * containerSize.width
    }

    var containerShakeHalfYRange: CGFloat {
        2 * containerSize.width
    }

    var containerShakeHalfXRange: CGFloat {
        (beakerSettings.innerBeakerWidth - moleculeSize) / 2
    }
}

// MARK: Beaker tools geometry
extension AcidBasesScreenLayout {
    var beakerToolsLeadingPadding: CGFloat {
        0.05 * beakerWidth
    }

    var beakerToolsSpacing: CGFloat {
        0.07 * beakerWidth
    }
}

// MARK: Chart geometry
extension AcidBasesScreenLayout {
    var barChartSettings: BarChartGeometry {
        BarChartGeometry(
            chartWidth: chartSize,
            minYValue: 0,
            maxYValue: 1
        )
    }

    var chartSize: CGFloat {
        let totalAvailableWidth = chartColumnWidth
        let totalAvailableHeight = beakyBoxHeight

        let idealWidth = 0.9 * totalAvailableWidth
        let idealHeight = 0.9 * totalAvailableHeight

        return min(idealWidth, idealHeight)
    }

    var phChartSettings: TimeChartLayoutSettings {
        TimeChartLayoutSettings(
            xAxis: AxisPositionCalculations<CGFloat>(
                minValuePosition: 0.1 * chartSize,
                maxValuePosition: 0.9 * chartSize,
                minValue: 0,
                maxValue: 1
            ),
            yAxis: AxisPositionCalculations<CGFloat>(
                minValuePosition: 0.1 * chartSize,
                maxValuePosition: 0.9 * chartSize,
                minValue: 0,
                maxValue: 14
            ),
            haloRadius: 2 * chartHeadRadius,
            lineWidth: 0.3 * chartHeadRadius
        )
    }

    var phYAxisWidth: CGFloat {
        0.12 * chartSize
    }

    var phYAxisSpacing: CGFloat {
        0.03 * chartSize
    }

    var phAxis: ChartAxisShapeSettings {
        ChartAxisShapeSettings(chartSize: chartSize)
    }

    var chartHeadRadius: CGFloat {
        0.018 * chartSize
    }
}

// MARK: toggle geometry
extension AcidBasesScreenLayout {
    var toggleHeight: CGFloat {
        0.05 * height
    }
}
