//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationBeaker: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            TitrationBeakerMolecules(
                layout: layout,
                model: model,
                components: model.components
            )

            molecules

            TitrationBeakerTools(
                layout: layout,
                model: model,
                components: model.components,
                shakeModel: model.shakeModel,
                dropperEmitModel: model.dropperEmitModel,
                buretteEmitModel: model.buretteEmitModel
            )
        }
    }

    private var molecules: some View {
        TitrationToolsMoleculesView(
            layout: layout,
            rows: model.rows,
            dropperEmitModel: model.dropperEmitModel,
            buretteEmitModel: model.buretteEmitModel
        )
        .frame(width: layout.toolStackWidth, height: layout.common.height)
    }
}

private struct TitrationBeakerTools: View {
    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel
    @ObservedObject var components: TitrationComponents
    @ObservedObject var shakeModel: MultiContainerShakeViewModel<TitrationViewModel.TempMolecule>

    let dropperEmitModel: MoleculeEmittingViewModel
    let buretteEmitModel: MoleculeEmittingViewModel

    private let emitAmount: Int = 5

    var body: some View {
        ZStack {
            phMeter

            dropper

            burette

            container
        }
        .frame(width: layout.toolStackWidth)
    }

    private var phMeter: some View {
        DraggablePhMeter(
            labelWhenIntersectingWater: "pH: 7",
            layout: layout.common,
            initialPosition: layout.phMeterPosition,
            rows: model.rows
        )
    }

    private var dropper: some View {
        Dropper(
            isActive: model.inputState == .addIndicator,
            tubeFill: nil,
            onTap: {
                dropperEmitModel.addMolecule(
                    amount: emitAmount,
                    at: layout.dropperMoleculePosition,
                    bottomY:
                        layout.common.topOfWaterPosition(rows: model.rows) + layout.dropperMoleculeSize
                )
            }
        )
        .frame(size: layout.dropperSize)
        .position(layout.dropperPosition)
    }

    private var burette: some View {
        Burette(
            fill: nil,
            isActive: model.inputState == .addTitrant,
            onTap: {
                buretteEmitModel.addMolecule(
                    amount: emitAmount,
                    at: layout.buretteMoleculePosition,
                    bottomY: layout.common.topOfWaterPosition(rows: model.rows) + layout.buretteMoleculeSize
                )
            }
        )
        .frame(size: layout.buretteSize)
        .position(layout.burettePosition)
    }

    private var container: some View {
        AcidAppShakingContainerView(
            models: shakeModel,
            layout: layout.common,
            initialLocation: layout.containerPosition,
            activeLocation: layout.activeContainerPosition,
            type: .A,
            label: "HCl",
            color: .purple,
            rows: model.rows,
            disabled: model.inputState != .addSubstance
        )
    }
}

private struct TitrationToolsMoleculesView: View {

    let layout: TitrationScreenLayout
    let rows: CGFloat
    @ObservedObject var dropperEmitModel: MoleculeEmittingViewModel
    @ObservedObject var buretteEmitModel: MoleculeEmittingViewModel

    var body: some View {
        ZStack {
            dropperMolecules
            buretteMolecules
        }
    }

    private var dropperMolecules: some View {
        molecules(dropperEmitModel, size: layout.dropperMoleculeSize)
            .foregroundColor(.purple)
    }

    private var buretteMolecules: some View {
        molecules(buretteEmitModel, size: layout.buretteMoleculeSize)
            .foregroundColor(.red)
    }

    private func molecules(
        _ model: MoleculeEmittingViewModel,
        size: CGFloat
    ) -> some View {
        ForEach(model.molecules) { molecule in
            Circle()
                .frame(square: size)
                .position(molecule.position)
        }
        .mask(
            VStack(spacing: 0) {
                Rectangle()
                    .frame(
                        width: layout.common.beakerWidth,
                        height: layout.common.topOfWaterPosition(rows: rows)
                    )
                Spacer()
            }
        )
    }
}

private extension TitrationScreenLayout {
    var buretteMoleculeSize: CGFloat {
        0.75 * common.moleculeSize
    }

    var dropperMoleculeSize: CGFloat {
        0.65 * common.moleculeSize
    }

    var dropperSize: CGSize {
        let width = 0.35 * availableWidthForDropperAndBurette
        let height = width / Dropper.aspectRatio
        return CGSize(width: width, height: height)
    }

    var buretteSize: CGSize {
        let width = availableWidthForDropperAndBurette - dropperSize.width
        let height = 1.7 * width
        return CGSize(width: width, height: height)
    }

    var phMeterPosition: CGPoint {
        CGPoint(
            x: common.phMeterSize.width / 2,
            y: toolsBottomY - (common.phMeterSize.height / 2)
        )
    }

    // TODO - enforce dropper is above water
    var dropperPosition: CGPoint {
        position(
            elementSize: dropperSize,
            previousElementSize: common.phMeterSize,
            previousElementPosition: phMeterPosition
        )
    }

    var dropperMoleculePosition: CGPoint {
        CGPoint(x: dropperPosition.x, y: dropperPosition.y + (dropperSize.height / 2))
    }

    var burettePosition: CGPoint {
        position(
            elementSize: buretteSize,
            previousElementSize: dropperSize,
            previousElementPosition: dropperPosition
        )
    }

    var buretteMoleculePosition: CGPoint {
        CGPoint(x: buretteTubeCenterX, y: burettePosition.y + (buretteSize.height / 2))
    }

    private var buretteTubeCenterX: CGFloat {
        let buretteLeadingX = burettePosition.x - (buretteSize.width / 2)
        let tubeXFromLeading = Burette.Geometry.tubeCenterX(frameWidth: buretteSize.width)
        return buretteLeadingX + tubeXFromLeading
    }

    var containerPosition: CGPoint {
        position(
            elementSize: common.containerSize,
            previousElementSize: buretteSize,
            previousElementPosition: burettePosition
        )
    }

    var activeContainerPosition: CGPoint {
        CGPoint(
            x: common.beakerWaterCenterX,
            y: toolsBottomY - 10
        )
    }

    var toolStackWidth: CGFloat {
        common.beakerWidth + common.sliderSettings.handleWidth
    }

    private func position(
        elementSize: CGSize,
        previousElementSize: CGSize,
        previousElementPosition: CGPoint
    ) -> CGPoint {
        let previousTrailing = previousElementPosition.x + (previousElementSize.width / 2)
        return CGPoint(
            x: previousTrailing + common.beakerToolsSpacing + (elementSize.width / 2),
            y: toolsBottomY - (elementSize.height / 2)
        )
    }

    private var toolsBottomY: CGFloat {
        common.height - common.beakerHeight - 50
    }

    private var availableWidthForDropperAndBurette: CGFloat {
        toolStackWidth - (3 * common.beakerToolsSpacing) - common.containerSize.width - common.phMeterSize.width
    }
}

private struct TitrationBeakerMolecules: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel
    @ObservedObject var components: TitrationComponents

    var body: some View {
        AdjustableFluidBeaker(
            rows: $model.rows,
            molecules: [components.substanceCoords],
            animatingMolecules: components.ionCoords,
            currentTime: 0,
            settings: layout.common.adjustableBeakerSettings,
            canSetLevel: model.inputState == .setWaterLevel,
            beakerColorMultiply: .white,
            sliderColorMultiply: .white,
            beakerModifier: BeakerAccessibilityModifier()
        )
    }
}

// TODO
private struct BeakerAccessibilityModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

struct TitrationBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            TitrationBeaker(
                layout: TitrationScreenLayout(
                    common: AcidBasesScreenLayout(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                ),
                model: TitrationViewModel()
            )
        }
        .padding()
        .previewLayout(.iPhone8Landscape)
    }
}
