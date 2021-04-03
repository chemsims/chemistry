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
