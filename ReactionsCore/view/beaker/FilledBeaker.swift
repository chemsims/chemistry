//
// ReactionsCore
//

import SwiftUI

public struct FilledBeaker: View {

    let molecules: [BeakerMolecules]
    let animatingMolecules: [AnimatingBeakerMolecules]
    let currentTime: CGFloat
    let outlineColor: Color
    let rows: CGFloat

    public init(
        molecules: [BeakerMolecules],
        animatingMolecules: [AnimatingBeakerMolecules],
        currentTime: CGFloat,
        rows: CGFloat = CGFloat(MoleculeGridSettings.rows)
    ) {
        self.molecules = molecules
        self.animatingMolecules = animatingMolecules
        self.currentTime = currentTime
        self.outlineColor = Styling.beakerOutline
        self.rows = rows
    }

    public var body: some View {
        GeometryReader { geo in
            GeneralFluidBeaker(
                molecules: molecules,
                animatingMolecules: animatingMolecules,
                currentTime: currentTime,
                rows: rows,
                fluidColor: Styling.beakerLiquid,
                placeholderColor: Styling.moleculePlaceholder,
                includeTicks: true,
                drawFromTop: true,
                settings: BeakerSettings(width: geo.size.width, hasLip: true)
            )
            .accessibility(
                label: Text(label)
            )
        }
    }

    private var label: String {
        let labels = molecules.map(\.label) + animatingMolecules.map(\.molecules.label)
        let sortedLabels = labels.sorted()
        if sortedLabels.isEmpty {
            return "Beaker showing an empty grid of molecules"
        }

        let moleculeStrings = StringUtil.combineStringsWithFinalAnd(sortedLabels)

        return "Beaker showing a grid of molecules of \(moleculeStrings) in liquid"
    }
}

struct GeneralFluidBeaker: View {

    let molecules: [BeakerMolecules]
    let animatingMolecules: [AnimatingBeakerMolecules]
    let currentTime: CGFloat
    let reactionPair: ReactionPairDisplay = ReactionType.A.display
    let outlineColor: Color = Styling.beakerOutline
    let rows: CGFloat
    let fluidColor: Color
    let placeholderColor: Color
    let includeTicks: Bool
    let drawFromTop: Bool
    let settings: BeakerSettings

    public var body: some View {
        mainContent
        .accessibilityElement(children: .ignore)
        .updatingAccessibilityValue(
            x: currentTime,
            format: valueForTime
        )
    }

    private func valueForTime(_ time: CGFloat) -> String {
        let currentAnimatingMolecules = animatingMolecules.map {
            $0.fractioned.coords(at: time)
        }

        let allMolecules = molecules.map(\.coords) + currentAnimatingMolecules

        let visibleMolecules = Array(
            GridCoordinate.uniqueGridCoordinates(coords: allMolecules.reversed()).reversed()
        )

        let labels = molecules.map(\.label) + animatingMolecules.map(\.molecules.label)

        let labelWithCount = labels.enumerated().map { (index, label) -> (String, Int) in
            let count = visibleMolecules[index].count
            return (label, count)
        }

        let sorted = labelWithCount.sorted(by: { $0.0 < $1.0 })
        let counts = sorted.map { (label, count) in
            "\(count) of \(label)"
        }
        if counts.isEmpty {
            return ""
        }
        return counts.dropFirst().reduce(counts.first!) { $0 + ", \($1)" }
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            if includeTicks {
                BeakerTicks(
                    numTicks: settings.numTicks,
                    rightGap: settings.ticksRightGap,
                    bottomGap: settings.ticksBottomGap,
                    topGap: settings.ticksTopGap,
                    minorWidth: settings.ticksMinorWidth,
                    majorWidth: settings.ticksMajorWidth
                )
                .stroke(lineWidth: 1)
                .fill(Styling.beakerTicks)
            }

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
            fluidColor
                .frame(height: settings.height(for: rows))

            moleculeGrid(
                settings,
                color: placeholderColor,
                coordinates: MoleculeGridSettings.grid(rows: Int(ceil(rows)))
            )

            ForEach(0..<molecules.count, id: \.self) { i in
                moleculeGrid(
                    settings,
                    color: molecules[i].color,
                    coordinates: molecules[i].coords
                )
            }

            ForEach(0..<animatingMolecules.count, id: \.self) { i in
                AnimatingMoleculeGrid(
                    settings: settings,
                    coords: animatingMolecules[i].molecules.coords,
                    color: animatingMolecules[i].molecules.color,
                    drawFromTop: drawFromTop,
                    fractionOfCoordsToDraw: animatingMolecules[i].fractionToDraw,
                    currentTime: currentTime
                )
                .frame(height: settings.height(for: rows))
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
            color: color,
            drawFromTop: drawFromTop
        )
        .frame(height: settings.height(for: rows))
    }
}

struct FilledBeaker_Previews: PreviewProvider {
    static var previews: some View {
        FilledBeaker(
            molecules: [
                BeakerMolecules(
                    coords: [
                        GridCoordinate(col: 0, row: 0),
                        GridCoordinate(col: 1, row: 1),
                        GridCoordinate(col: 2, row: 2)
                    ],
                    color: .orangeAccent,
                    label: "A"
                ),
                BeakerMolecules(
                    coords: [
                        GridCoordinate(col: 0, row: 1),
                        GridCoordinate(col: 1, row: 2),
                        GridCoordinate(col: 2, row: 3)
                    ],
                    color: .black,
                    label: "B"
                )
            ],
            animatingMolecules: [],
            currentTime: 0,
            rows: 10
        )
    }
}
