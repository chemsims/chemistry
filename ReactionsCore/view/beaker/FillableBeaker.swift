//
// Reactions App
//

import SwiftUI

/// A beaker where the provided view is placed inside the liquid.
///
/// Note that the provided view may be larger than the liquid dimensions. For example,
/// this can allow molecules to be added above the beaker, and fall inside the liquid
public struct FillableBeaker<Content: View>: View {

    let waterColor: Color
    let highlightBeaker: Bool
    let settings: FillableBeakerSettings
    let content: () -> Content

    public init(
        waterColor: Color,
        highlightBeaker: Bool,
        settings: FillableBeakerSettings,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.waterColor = waterColor
        self.highlightBeaker = highlightBeaker
        self.settings = settings
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .mask(beakerShape)
                .frame(height: settings.beakerHeight)
                .opacity(highlightBeaker ? 1 : 0)
            beakerTicks
            beakerFill
            EmptyBeaker(settings: settings.beaker)
                .frame(
                    width: settings.beakerWidth,
                    height: settings.beakerHeight
                )
        }
    }

    private var beakerFill: some View {
        Group {
            Rectangle()
                .frame(
                    height: settings.waterHeight
                )
                .foregroundColor(waterColor)

            content()
        }
        .frame(width: settings.beaker.innerBeakerWidth)
        .mask(
            BeakerBottomShape(
                cornerRadius: settings.beaker.outerBottomCornerRadius
            )
        )
        .colorMultiply(
            highlightBeaker ? .white : Styling.inactiveScreenElement
        )
    }

    private var beakerShape: some View {
        BeakerShape(
            lipHeight: settings.beaker.lipRadius,
            lipWidthLeft: settings.beaker.lipWidthLeft,
            lipWidthRight: settings.beaker.lipWidthLeft,
            leftCornerRadius: settings.beaker.outerBottomCornerRadius,
            rightCornerRadius: settings.beaker.outerBottomCornerRadius,
            bottomGap: 0,
            rightGap: 0
        )
    }

    private var beakerTicks: some View {
        BeakerTicks(
            numTicks: settings.beaker.numTicks,
            rightGap: settings.beaker.ticksRightGap,
            bottomGap: settings.beaker.ticksBottomGap,
            topGap: settings.beaker.ticksTopGap,
            minorWidth: settings.beaker.ticksMinorWidth,
            majorWidth: settings.beaker.ticksMajorWidth
        )
        .stroke(lineWidth: 1)
        .fill(Styling.beakerTicks)
        .frame(width: settings.beakerWidth, height: settings.beakerHeight)
    }
}

public struct FillableBeakerSettings {

    public let beakerWidth: CGFloat
    public let waterHeight: CGFloat

    public init(beakerWidth: CGFloat, waterHeight: CGFloat) {
        self.beakerWidth = beakerWidth
        self.waterHeight = waterHeight
    }

    public var beaker: BeakerSettings {
        BeakerSettings(width: beakerWidth, hasLip: true)
    }

    public var beakerHeight: CGFloat {
        BeakerSettings.heightToWidth * beakerWidth
    }
}

struct FillableBeaker_Previews: PreviewProvider {
    static var previews: some View {
        FillableBeaker(
            waterColor: .red,
            highlightBeaker: false,
            settings: FillableBeakerSettings(
                beakerWidth: 300,
                waterHeight: 130
            )
        ) {
            Circle()
                .frame(width: 40, height: 40)
        }
    }
}
