//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AddMoleculeWithLiquidBeaker: View {

    @ObservedObject var model: AqueousReactionViewModel
    let settings: AqueousScreenLayoutSettings

    var body: some View {
        VStack {
            molecules
            Spacer()
            beaker
        }
    }

    private var molecules: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: settings.sliderSettings.handleWidth)
            AddMoleculesView(
                model: model.addingMoleculesModel,
                containerWidth: settings.moleculeWidth,
                startOfWater: 280,
                maxContainerY: 200,
                moleculeSize: 20
            )
            .frame(width: settings.beakerWidth)
        }.zIndex(1)
    }

    private var beaker: some View {
        HStack(alignment: .bottom, spacing: 0) {
            CustomSlider(
                value: $model.rows,
                axis: settings.sliderAxis,
                orientation: .portrait,
                includeFill: true,
                settings: settings.sliderSettings,
                disabled: !model.canSetLiquidLevel
            )
            .frame(width: settings.sliderSettings.handleWidth, height: settings.sliderHeight)

            FilledBeaker(
                molecules: model.components.nonAnimatingMolecules,
                animatingMolecules: model.components.animatingMolecules,
                currentTime: model.currentTime,
                rows: model.rows
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
        }
    }
}

struct AddMoleculeWithLiquidBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            AddMoleculeWithLiquidBeaker(
                model: AqueousReactionViewModel(),
                settings: AqueousScreenLayoutSettings(geometry: geo)
            )
        }.previewLayout(.iPhone12ProMaxLandscape)
    }
}
