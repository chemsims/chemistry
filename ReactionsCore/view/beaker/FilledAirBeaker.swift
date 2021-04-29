//
// Reactions App
//

import SwiftUI

public struct FilledAirBeaker: View {

    let molecules: [BeakerMolecules]
    let animatingMolecules: [AnimatingBeakerMolecules]
    let currentTime: CGFloat
    let rows: CGFloat

    public init(
        molecules: [BeakerMolecules],
        animatingMolecules: [AnimatingBeakerMolecules],
        currentTime: CGFloat,
        rows: CGFloat
    ) {
        self.molecules = molecules
        self.animatingMolecules = animatingMolecules
        self.currentTime = currentTime
        self.rows = rows
    }

    public var body: some View {
        GeometryReader { geo in
            FilledAirBeakerWithSettings(
                molecules: molecules,
                animatingMolecules: animatingMolecules,
                currentTime: currentTime,
                rows: rows,
                settings: BeakerSettings(width: geo.size.width, hasLip: false)
            )
        }
    }
}

private struct FilledAirBeakerWithSettings: View {

    let molecules: [BeakerMolecules]
    let animatingMolecules: [AnimatingBeakerMolecules]
    let currentTime: CGFloat
    let rows: CGFloat
    let settings: BeakerSettings

    let sealYOffset: CGFloat
    let sealSettings: FilledAirSealSettings

    init(
        molecules: [BeakerMolecules],
        animatingMolecules: [AnimatingBeakerMolecules],
        currentTime: CGFloat,
        rows: CGFloat,
        settings: BeakerSettings
    ) {
        self.molecules = molecules
        self.animatingMolecules = animatingMolecules
        self.currentTime = currentTime
        self.rows = rows
        self.settings = settings
        self.sealSettings = FilledAirSealSettings(width: settings.width)

        let grid = MoleculeGridSettings(totalWidth: settings.width)
        self.sealYOffset = -grid.height(for: rows)
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            GeneralFluidBeaker(
                molecules: molecules,
                animatingMolecules: animatingMolecules,
                currentTime: currentTime,
                rows: rows,
                fluidColor: Styling.beakerAir,
                placeholderColor: Styling.airMoleculePlaceholder,
                includeTicks: false,
                drawFromTop: false,
                settings: settings
            )
            seal
                .offset(y: sealYOffset)
        }
        .accessibilityElement(children: .combine)
        .accessibility(label: Text(label))
    }

    private var label: String {
        let base = AccessibilityLabelUtil.beakerGridLabel(
            molecules: molecules,
            animatingMolecules: animatingMolecules,
            fluid: "air"
        )
        return "\(base) with a pressure seal on top"
    }

    private var seal: some View {
        VStack(spacing: 0) {
            Group {
                Rectangle()
                    .frame(
                        width: sealSettings.handleWidth,
                        height: sealSettings.handleHeight
                    )
                Rectangle()
                    .frame(height: sealSettings.thickPadHeight)
            }
            .foregroundColor(Color.gray)
            Rectangle()
                .frame(height: sealSettings.thinPadHeight)
            Rectangle()
                .frame(height: sealSettings.thickPadHeight)
                .foregroundColor(Color.gray)
        }
        .compositingGroup().opacity(0.8)
    }
}

public struct FilledAirSealSettings {

    let width: CGFloat

    var handleWidth: CGFloat {
        0.05 * width
    }

    var handleHeight: CGFloat {
        1.8 * handleWidth
    }

    var thickPadHeight: CGFloat {
        1.2 * handleHeight
    }

    var thinPadHeight: CGFloat {
        0.15 * thickPadHeight
    }

    var midSealPosition: CGFloat {
        thickPadHeight + (thinPadHeight / 2)
    }
}

struct FilledAirBeaker_Previews: PreviewProvider {
    static var previews: some View {
        FilledAirBeaker(
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
            rows: 10.5
        ).padding(10)
    }
}
