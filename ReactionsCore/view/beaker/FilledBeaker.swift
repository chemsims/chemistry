//
// ReactionsCore
//

import SwiftUI

public struct FilledBeaker: View {

    let molecules: [BeakerMolecules]
    let animatingMolecules: [AnimatingBeakerMolecules]
    let currentTime: CGFloat?
    let reactionPair: ReactionPairDisplay
    let outlineColor: Color
    let rows: CGFloat

    @available(*, deprecated, message: "Use other initializer")
    public init(
        moleculesA: [GridCoordinate],
        concentrationB: Equation?,
        currentTime: CGFloat?,
        reactionPair: ReactionPairDisplay,
        outlineColor: Color = Styling.beakerOutline,
        rows: CGFloat = CGFloat(MoleculeGridSettings.rows)
    ) {
        let molecule = BeakerMolecules(
            coords: moleculesA,
            color: reactionPair.reactant.color
        )
        self.molecules = [molecule]

        let animating = concentrationB.map { cB in
            [
                AnimatingBeakerMolecules(
                    molecules: molecule,
                    fractionToDraw: concentrationB!
                )
            ]
        }

        self.animatingMolecules = animating ?? []
        self.currentTime = currentTime
        self.reactionPair = reactionPair
        self.outlineColor = outlineColor
        self.rows = rows
    }

    public init(
        molecules: [BeakerMolecules],
        animatingMolecules: [AnimatingBeakerMolecules],
        currentTime: CGFloat,
        rows: CGFloat = CGFloat(MoleculeGridSettings.rows)
    ) {
        self.molecules = molecules
        self.animatingMolecules = animatingMolecules
        self.currentTime = currentTime
        self.reactionPair = ReactionType.A.display
        self.outlineColor = Styling.beakerOutline
        self.rows = rows
    }

    public var body: some View {
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
//        .updatingAccessibilityValue(
//            x: currentTime ?? 0,
//            format: valueForTime
//        )
    }

    // TODO 
    private var reactant: String {
        reactionPair.reactant.name
    }

    private var product: String {
        reactionPair.product.name
    }

    // TODO
//    private func valueForTime(_ time: CGFloat) -> String {
//        let total = moleculesA.count
//        let bFraction = concentrationB?.getY(at: time) ?? 0
//        let countOfB = Int(CGFloat(total) * bFraction)
//        let countOfA = total - countOfB
//        return "\(countOfA) \(reactant) molecules, \(countOfB) \(product) molecules"
//    }

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
                .frame(height: settings.height(for: rows))

            moleculeGrid(
                settings,
                color: Styling.moleculePlaceholder,
                coordinates: MoleculeGridSettings.grid(rows: Int(ceil(rows)))
            )

            ForEach(0..<molecules.count, id: \.self) { i in
                moleculeGrid(
                    settings,
                    color: molecules[i].color,
                    coordinates: molecules[i].coords
                )
            }

            if currentTime != nil {
                ForEach(0..<animatingMolecules.count, id: \.self) { i in
                    AnimatingMoleculeGrid(
                        settings: settings,
                        coords: animatingMolecules[i].molecules.coords,
                        color: animatingMolecules[i].molecules.color,
                        fractionOfCoordsToDraw: animatingMolecules[i].fractionToDraw,
                        currentTime: currentTime!
                    )
                    .frame(height: settings.height(for: rows))
                }
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
        )
        .frame(height: settings.height(for: rows))
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

        FilledBeaker(
            molecules: [
                BeakerMolecules(
                    coords: [
                        GridCoordinate(col: 0, row: 0),
                        GridCoordinate(col: 1, row: 1),
                        GridCoordinate(col: 2, row: 2)
                    ],
                    color: .orangeAccent
                ),
                BeakerMolecules(
                    coords: [
                        GridCoordinate(col: 0, row: 1),
                        GridCoordinate(col: 1, row: 2),
                        GridCoordinate(col: 2, row: 3)
                    ],
                    color: .black
                )
            ],
            animatingMolecules: [],
            currentTime: 0,
            rows: 10
        )
    }
}
