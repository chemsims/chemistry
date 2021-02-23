//
// Reactions App
//


import SwiftUI
import ReactionsCore

struct AqueousReactionScreen: View {

    let model: AqueousReactionViewModel

    var body: some View {
        GeometryReader { geometry in
            AqueousReactionScreenWithSettings(
                model: model,
                settings: AqueousScreenLayoutSettings(geometry: geometry)
            )
        }
    }
}

private struct AqueousReactionScreenWithSettings: View {

    @ObservedObject var model: AqueousReactionViewModel
    let settings: AqueousScreenLayoutSettings

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                molecules
                Spacer()
                beaker
            }
            Text("Concentration is \(model.concentrationA.str(decimals: 3))")
            Spacer()
            BeakyBox(
                statement: [],
                next: {},
                back: {},
                nextIsDisabled: false,
                verticalSpacing: 1,
                bubbleWidth: 100,
                bubbleHeight: 100,
                beakyHeight: 100,
                fontSize: 20,
                navButtonSize: 20,
                bubbleStemWidth: 10
            )
        }
    }

    private var molecules: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: settings.sliderSettings.handleWidth)
            HStack(spacing: settings.moleculeSpacing) {
                ForEach(AqueousMolecule.allCases, id: \.rawValue) { molecule in
                    Image(molecule.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: settings.moleculeWidth)
                        .onTapGesture {
                            model.incrementAMolecules()
                        }

                }
            }
        }
    }

    private var beaker: some View {
        HStack(alignment: .bottom, spacing: 0) {
            CustomSlider(
                value: $model.rows,
                axis: settings.sliderAxis,
                orientation: .portrait,
                includeFill: true,
                settings: settings.sliderSettings
            )
            .frame(width: settings.sliderSettings.handleWidth, height: settings.sliderHeight)

            FilledBeaker(
                moleculesA: model.moleculesA,
                concentrationB: nil,
                currentTime: nil,
                reactionPair: ReactionType.A.display,
                rows: model.rows
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
        }
    }
}

struct AqueousScreenLayoutSettings {
    let geometry: GeometryProxy
    var width: CGFloat {
        geometry.size.width
    }

    var beakerWidth: CGFloat {
        0.25 * width
    }

    var beakerHeight: CGFloat {
        beakerWidth * BeakerSettings.heightToWidth
    }

    var sliderHeight: CGFloat {
        0.8 * beakerHeight
    }

    var sliderSettings: SliderGeometrySettings {
        SliderGeometrySettings(handleWidth: 0.13 * beakerWidth)
    }
}

extension AqueousScreenLayoutSettings {
    var moleculeWidth: CGFloat {
        0.15 * beakerWidth
    }

    var moleculeSpacing: CGFloat {
        0.1 * beakerWidth
    }
}

extension AqueousScreenLayoutSettings {
    var sliderAxis: AxisPositionCalculations<CGFloat> {
        let innerBeakerWidth = BeakerSettings(width: beakerWidth).innerBeakerWidth
        let grid = MoleculeGridSettings(totalWidth: innerBeakerWidth)

        func posForRows(_ rows: CGFloat) -> CGFloat {
            sliderHeight - grid.height(for: CGFloat(rows))
        }

        let minRow = CGFloat(AqueousReactionSettings.minRows)
        let maxRow = CGFloat(AqueousReactionSettings.maxRows)

        return AxisPositionCalculations(
            minValuePosition: posForRows(minRow),
            maxValuePosition: posForRows(maxRow),
            minValue: minRow,
            maxValue: maxRow
        )
    }
}

struct AqueousReactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        AqueousReactionScreen(model: AqueousReactionViewModel())
            .previewLayout(.iPhoneSELandscape)
    }
}
