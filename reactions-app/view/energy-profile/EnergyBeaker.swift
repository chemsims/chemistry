//
// Reactions App
//
  

import SwiftUI

struct EnergyBeaker: View {

    let extraSpeed: CGFloat

    var body: some View {
        GeometryReader { geometry in
            makeView(
                settings: BeakerSettings(geometry: geometry)
            )
        }
    }

    private func makeView(settings: BeakerSettings) -> some View {
        ZStack(alignment: .bottom) {
            BeakerTicks(
                numTicks: settings.numTicks,
                rightGap: settings.ticksRightGap,
                bottomGap: settings.ticksBottomGap,
                topGap: settings.ticksTopGap,
                minorWidth: settings.ticksMinorWidth,
                majorWidth: settings.ticksMajorWidth
            )
            .stroke(lineWidth: 1)
            .fill(Color.darkGray.opacity(0.5))
            makeMolecules(settings: settings)
                .mask(
                    BeakerBottomShape(
                        cornerRadius: settings.outerBottomCornerRadius
                    )
                )
            EmptyBeaker(settings: settings)
        }
    }

    private func makeMolecules(settings: BeakerSettings) -> some View {
        MoleculeEneregyUIViewRepresentable(
            width: settings.innerBeakerWidth,
            height: settings.geometry.size.height * 0.4,
            speed: extraSpeed
        ).frame(
            width: settings.innerBeakerWidth,
            height: settings.geometry.size.height * 0.4
        )
    }
}

struct EnergyBeaker_Previews: PreviewProvider {
    static var previews: some View {
        EnergyBeaker(extraSpeed: 0)
            .frame(height: 400)
    }
}
