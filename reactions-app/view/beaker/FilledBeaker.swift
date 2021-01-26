//
// Reactions App
//
  

import SwiftUI

struct FilledBeaker: View {

    let moleculesA: [GridCoordinate]
    let concentrationB: Equation?
    let currentTime: CGFloat?
    let reactionPair: ReactionPairDisplay
    let outlineColor: Color
    init(
        moleculesA: [GridCoordinate],
        concentrationB: Equation?,
        currentTime: CGFloat?,
        reactionPair: ReactionPairDisplay,
        outlineColor: Color = Styling.beakerOutline
    ) {
        self.moleculesA = moleculesA
        self.concentrationB = concentrationB
        self.currentTime = currentTime
        self.reactionPair = reactionPair
        self.outlineColor = outlineColor
    }

    var body: some View {
        GeometryReader { geometry in
            makeView(
                using: BeakerSettings(width: geometry.size.width)
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibility(
            label: Text(
                "Beaker showing a grid of molecules of \(reactant) and \(product) in liquid"
            )
        )
        .updatingAccessibilityValue(
            x: currentTime ?? 0,
            format: valueForTime
        )
    }

    private var reactant: String {
        reactionPair.reactant.name
    }

    private var product: String {
        reactionPair.product.name
    }

    private func valueForTime(_ time: CGFloat) -> String {
        let total = moleculesA.count
        let bFraction = concentrationB?.getY(at: time) ?? 0
        let countOfB = Int(CGFloat(total) * bFraction)
        let countOfA = total - countOfB
        return "\(countOfA) \(reactant) molecules, \(countOfB) \(product) molecules"
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
            EmptyBeaker(settings: settings, color: outlineColor)
        }.background(
            Color.white.mask(
                BeakerShape(
                    lipHeight: settings.lipRadius,
                    lipWidthLeft: settings.lipWidthLeft,
                    lipWidthRight: settings.lipWidthLeft,
                    leftCornerRadius: settings.outerBottomCornerRadius,
                    rightCornerRadius: settings.outerBottomCornerRadius,
                    bottomGap: 0,
                    rightGap: 0
                )
            )
        )
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
                color: reactionPair.reactant.color,
                coordinates: moleculesA
            )

            if (currentTime != nil && concentrationB != nil) {
                AnimatingMoleculeGrid(
                    settings: settings,
                    coords: moleculesA,
                    color: reactionPair.product.color,
                    fractionOfCoordsToDraw: concentrationB!,
                    currentTime: currentTime!
                )
                .frame(height: settings.height)
            }
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
            concentrationB: ConstantEquation(value: 0),
            currentTime: 0,
            reactionPair: ReactionType.A.display
        )
    }
}
