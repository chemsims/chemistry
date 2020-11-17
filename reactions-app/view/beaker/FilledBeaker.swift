//
// Reactions App
//
  

import SwiftUI

struct FilledBeaker: View {

    let moleculesA: [GridCoordinate]
    let moleculesB: [GridCoordinate]
    let moleculeBOpacity: Double

    var body: some View {
        GeometryReader { geometry in
            makeView(using: BeakerSettings(geometry: geometry))
        }
    }

    private func makeView(using settings: BeakerSettings) -> some View {
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
            beakerFill(settings)
            EmptyBeaker(settings: settings)
        }
    }

    private func beakerFill(_ settings: BeakerSettings) -> some View {
        drawFill(
            MoleculeGridSettings(totalWidth: settings.innerBeakerWidth),
            beaker: settings
        )
        .frame(width: settings.innerBeakerWidth)
        .mask(
            BeakerBottomShape(
                cornerRadius: settings.outerBottomCornerRadius
            )
        )
    }

    private func drawFill(_ settings: MoleculeGridSettings, beaker: BeakerSettings) -> some View {
        ZStack {
            Styling.beakerLiquid
                .frame(height: settings.height)

            moleculeGrid(
                settings,
                color: Styling.moleculePlaceholder,
                coordinates: MoleculeGridSettings.fullGrid
            )


            moleculeGrid(
                settings,
                color: Styling.moleculeA,
                coordinates: moleculesA
            )

            moleculeGrid(
                settings,
                color: Styling.moleculeB,
                coordinates: moleculesB
            ).opacity(moleculeBOpacity)
        }
    }


    private func moleculeGrid(
        _ settings: MoleculeGridSettings,
        color: Color,
        coordinates: [GridCoordinate]
    ) -> some View {
        MoleculeGrid(
            settings: settings,
            coords: coordinates,
            color: color
        ).frame(height: settings.height)
    }
}

struct FilledBeaker_Previews: PreviewProvider {
    static var previews: some View {
        FilledBeaker(
            moleculesA: [
                GridCoordinate(col: 0, row: 0),
                GridCoordinate(col: 1, row: 1),
                GridCoordinate(col: 2, row: 2)
            ],
            moleculesB: [
                GridCoordinate(col: 2, row: 4),
                GridCoordinate(col: 5, row: 3),
                GridCoordinate(col: 14, row: 4)
            ],
            moleculeBOpacity: 0
        )
    }
}
