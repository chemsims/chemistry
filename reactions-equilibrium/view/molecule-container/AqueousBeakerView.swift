//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AqueousBeakerView: View {

    @ObservedObject var model: AqueousReactionViewModel
    let settings: AqueousScreenLayoutSettings

    var body: some View {
        ZStack(alignment: .bottom) {
            beaker
            molecules
        }
        .frame(height: settings.height)
    }

    private var molecules: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: settings.sliderSettings.handleWidth)
            AddMoleculesView(
                model: model.addingMoleculesModel,
                inputState: model.inputState,
                topRowHeight: settings.moleculeContainerYPos,
                containerWidth: settings.moleculeContainerWidth,
                containerHeight: settings.moleculeContainerHeight,
                startOfWater: topOfWaterPosition,
                maxContainerY: maxContainerY,
                moleculeSize: settings.moleculeSize,
                topRowColorMultiply: model.highlightedElements.colorMultiply(for: .moleculeContainers),
                onDrag: { model.highlightedElements.clear() }
            )
            .frame(
                width: settings.beakerSettings.innerBeakerWidth - settings.moleculeSize
            )
            .mask(
                VStack(spacing: 0) {
                    Rectangle()
                        .frame(
                            width: settings.beakerWidth + (2 * settings.moleculeContainerHeight),
                            height: topOfWaterPosition
                        )
                    Spacer()
                }

            )
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
            .frame(
                width: settings.sliderSettings.handleWidth,
                height: settings.sliderHeight
            )
            .background(
                Color.white
                    .padding(.horizontal, -0.2 * settings.sliderSettings.handleWidth)
                    .padding(.top, -0.2 * settings.sliderSettings.handleWidth)
            )
            .colorMultiply(model.highlightedElements.colorMultiply(for: .waterSlider))

            FilledBeaker(
                molecules: [],
                animatingMolecules: model.components2.beakerMolecules.map(\.animatingMolecules),
                currentTime: model.currentTime,
                rows: model.rows
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
            .colorMultiply(model.highlightedElements.colorMultiply(for: nil))
        }
    }

    private var topOfWaterPosition: CGFloat {
        let topFromSlider = settings.sliderAxis.getPosition(at: model.rows)
        return settings.height - settings.sliderHeight + topFromSlider
    }

    private var maxContainerY: CGFloat {
        (settings.height - settings.beakerHeight) - settings.moleculeContainerHeight
    }
}

struct AddMoleculeWithLiquidBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            AqueousBeakerView(
                model: AqueousReactionViewModel(),
                settings: AqueousScreenLayoutSettings(geometry: geo)
            )
        }
        .previewLayout(.iPhone12ProMaxLandscape)
        .background(Color.gray.opacity(0.4))
    }
}
