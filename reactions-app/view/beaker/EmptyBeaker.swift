//
// Reactions App
//
  

import SwiftUI

struct EmptyBeaker: View {

    let settings: BeakerSettings

    var body: some View {
        ZStack(alignment: .topLeading) {
            largeBeaker(settings)
                .stroke(lineWidth: 2)
                .fill(Color.darkGray)

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

struct LargeBeaker: View {
    let settings: BeakerSettings

    var body: some View {
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
}

struct BeakerSettings {

    static let heightToWidth: CGFloat = 1.1

    let geometry: GeometryProxy

    var lipRadius: CGFloat {
        geometry.size.width * 0.03
    }

    var lipWidthLeft: CGFloat {
        geometry.size.width * 0.01
    }

    var mediumBeakerRightLipWidth: CGFloat {
        lipWidthLeft * 9
    }

    var smallBeakerRightLipWidth: CGFloat {
        mediumBeakerRightLipWidth
    }

    var outerBottomCornerRadius: CGFloat {
        geometry.size.width * 0.1
    }

    var mediumBeakerRightGap: CGFloat {
        lipWidthLeft * 5
    }

    var smallBeakerRightGap: CGFloat {
        mediumBeakerRightGap * 2
    }

    var innerLeftBottomCornerRadius: CGFloat {
        outerBottomCornerRadius
    }

    var mediumBeakerRightCornerRadius: CGFloat {
        outerBottomCornerRadius * 1.5
    }

    var smallBeakerRightCornerRadius: CGFloat {
        mediumBeakerRightCornerRadius * 1.2
    }

    var innerBeakersBottomGap: CGFloat {
        geometry.size.height * 0.05
    }

    var numTicks: Int {
        13
    }

    var ticksBottomGap: CGFloat {
        innerBeakersBottomGap * 1.5
    }

    var ticksMinorWidth: CGFloat {
        geometry.size.width * 0.075
    }

    var ticksMajorWidth: CGFloat {
        ticksMinorWidth * 2
    }

    var ticksTopGap: CGFloat {
        lipRadius * 4
    }

    var ticksRightGap: CGFloat {
        lipRadius + mediumBeakerRightGap + mediumBeakerRightLipWidth
    }

    var innerBeakerWidth: CGFloat {
        geometry.size.width - (2 * lipRadius) - (2 * lipWidthLeft)
    }
}


struct EmptyBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
                EmptyBeaker(
                    settings: BeakerSettings(geometry: geometry)
                )
        }
    }
}
