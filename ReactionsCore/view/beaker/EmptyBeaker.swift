//
// ReactionsCore
//

import SwiftUI

public struct EmptyBeaker: View {

    let settings: BeakerSettings
    let color: Color

    public init(
        settings: BeakerSettings,
        color: Color = Styling.beakerOutline
    ) {
        self.settings = settings
        self.color = color
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            largeBeaker(settings)
                .stroke(lineWidth: 2)
                .fill(color)

            outerTone(settings)

            innerTone(settings)
        }
    }

    private func outerTone(_ settings: BeakerSettings) -> some View {
        largeBeaker(settings)
            .fill(Styling.beakerOuterTone)
            .mask(
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                    mediumBeaker(settings)
                }.compositingGroup().luminanceToAlpha()
            )
    }

    private func innerTone(_ settings: BeakerSettings) -> some View {
        mediumBeaker(settings)
            .fill(Styling.beakerInnerTone)
            .mask(
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                    smallBeaker(settings)
                }.compositingGroup().luminanceToAlpha()
        )
    }

    private func largeBeaker(_ settings: BeakerSettings) -> some Shape {
        BeakerShape(
            lipHeight: settings.lipRadius,
            lipWidthLeft: settings.lipWidthLeft,
            lipWidthRight: settings.lipWidthLeft,
            leftCornerRadius: settings.outerBottomCornerRadius,
            rightCornerRadius: settings.outerBottomCornerRadius,
            bottomGap: 0,
            rightGap: 0
        )
    }

    private func mediumBeaker(_ settings: BeakerSettings) -> some Shape {
        BeakerShape(
            lipHeight: settings.lipRadius,
            lipWidthLeft: settings.lipWidthLeft,
            lipWidthRight: settings.mediumBeakerRightLipWidth,
            leftCornerRadius: settings.innerLeftBottomCornerRadius,
            rightCornerRadius: settings.mediumBeakerRightCornerRadius,
            bottomGap: settings.innerBeakersBottomGap,
            rightGap: settings.mediumBeakerRightGap
        )
    }

    private func smallBeaker(_ settings: BeakerSettings) -> some Shape {
        BeakerShape(
            lipHeight: settings.lipRadius,
            lipWidthLeft: settings.lipWidthLeft,
            lipWidthRight: settings.smallBeakerRightLipWidth,
            leftCornerRadius: settings.innerLeftBottomCornerRadius,
            rightCornerRadius: settings.smallBeakerRightCornerRadius,
            bottomGap: settings.innerBeakersBottomGap,
            rightGap: settings.smallBeakerRightGap
        )
    }

}

public struct BeakerSettings {

    public static let heightToWidth: CGFloat = 1.1

    let width: CGFloat
    let hasLip: Bool

    public init(width: CGFloat, hasLip: Bool) {
        self.width = width
        self.hasLip = hasLip
    }

    public var lipRadius: CGFloat {
        hasLip ? width * 0.03 : 0
    }

    public var lipWidthLeft: CGFloat {
        hasLip ? width * 0.01 : 0
    }

    public var mediumBeakerRightLipWidth: CGFloat {
        lipWidthLeft * 9
    }

    public var smallBeakerRightLipWidth: CGFloat {
        mediumBeakerRightLipWidth
    }

    public var outerBottomCornerRadius: CGFloat {
        width * 0.1
    }

    public var mediumBeakerRightGap: CGFloat {
        hasLip ? lipWidthLeft * 5 : 0.15 * width
    }

    public var smallBeakerRightGap: CGFloat {
        hasLip ? 2 * mediumBeakerRightGap : 1.5 * mediumBeakerRightGap
    }

    public var innerLeftBottomCornerRadius: CGFloat {
        outerBottomCornerRadius
    }

    public var mediumBeakerRightCornerRadius: CGFloat {
        outerBottomCornerRadius * 1.5
    }

    public var smallBeakerRightCornerRadius: CGFloat {
        mediumBeakerRightCornerRadius * 1.2
    }

    public var innerBeakersBottomGap: CGFloat {
        width * 0.055
    }

    public var numTicks: Int {
        13
    }

    public var ticksBottomGap: CGFloat {
        innerBeakersBottomGap * 1.5
    }

    public var ticksMinorWidth: CGFloat {
        width * 0.075
    }

    public var ticksMajorWidth: CGFloat {
        ticksMinorWidth * 2
    }

    public var ticksTopGap: CGFloat {
        lipRadius * 4
    }

    public var ticksRightGap: CGFloat {
        lipRadius + mediumBeakerRightGap + mediumBeakerRightLipWidth
    }

    public var innerBeakerWidth: CGFloat {
        width - (2 * lipRadius) - (2 * lipWidthLeft)
    }
}

struct EmptyBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            EmptyBeaker(
                settings: BeakerSettings(width: geometry.size.width, hasLip: true)
            )
        }
        GeometryReader { geometry in
            EmptyBeaker(
                settings: BeakerSettings(width: geometry.size.width, hasLip: false)
            )
        }.padding(20)
    }
}
