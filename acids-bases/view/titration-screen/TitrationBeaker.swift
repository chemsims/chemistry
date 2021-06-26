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
                strongSubstancePreparationModel: model.components.strongSubstancePreparationModel,
                strongSubstancePreEPModel: model.components.strongSubstancePreEPModel,
                strongSubstancePostEPModel: model.components.strongSubstancePostEPModel,
                weakPrepModel: model.components.weakSubstancePreparationModel,
                weakPreEPReaction: model.components.weakSubstancePreEPModel.beakerReactionModel,
                weakPostEPModel: model.components.weakSubstancePostEPModel
            )

            TitrationBeakerTools(
                layout: layout,
                model: model
            )
        }
    }
}

private struct TitrationBeakerTools: View {

    init(
        layout: TitrationScreenLayout,
        model: TitrationViewModel
    ) {
        self.layout = layout
        self.model = model
        self.shakeModel = model.shakeModel
        self.strongPrepModel = model.components.strongSubstancePreparationModel
        self.strongPreEPModel = model.components.strongSubstancePreEPModel
        self.strongPostEPModel = model.components.strongSubstancePostEPModel
        self.weakPrepModel = model.components.weakSubstancePreparationModel
        self.weakPreEPModel = model.components.weakSubstancePreEPModel
        self.weakPostEPModel = model.components.weakSubstancePostEPModel
        self.dropperEmitModel = model.dropperEmitModel
        self.buretteEmitModel = model.buretteEmitModel
    }

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel
    @ObservedObject var shakeModel: MultiContainerShakeViewModel<TitrationComponentState.Substance>

    @ObservedObject var strongPrepModel: TitrationStrongSubstancePreparationModel
    @ObservedObject var strongPreEPModel: TitrationStrongSubstancePreEPModel
    @ObservedObject var strongPostEPModel: TitrationStrongSubstancePostEPModel
    @ObservedObject var weakPrepModel: TitrationWeakSubstancePreparationModel
    @ObservedObject var weakPreEPModel: TitrationWeakSubstancePreEPModel
    @ObservedObject var weakPostEPModel: TitrationWeakSubstancePostEPModel

    let dropperEmitModel: MoleculeEmittingViewModel
    let buretteEmitModel: MoleculeEmittingViewModel

    private let emitAmount: Int = 5
    private let buretteEmitAmount = 10 // TODO - change this back

    var body: some View {
        ZStack {
            molecules

            phMeter

            dropper

            burette

            container
        }
        .frame(width: layout.toolStackWidth)
    }

    private var molecules: some View {
        TitrationToolsMoleculesView(
            layout: layout,
            rows: model.rows,
            buretteColor: buretteColor,
            dropperEmitModel: model.dropperEmitModel,
            buretteEmitModel: model.buretteEmitModel
        )
        .frame(width: layout.toolStackWidth, height: layout.common.height)
    }

    private var phMeter: some View {
        DraggablePhMeter(
            labelWhenIntersectingWater: pHString,
            layout: layout.common,
            initialPosition: layout.phMeterPosition,
            rows: model.rows
        )
    }

    private var dropper: some View {
        Dropper(
            isActive: model.inputState == .addIndicator,
            tubeFill: model.inputState == .addIndicator ? RGB.indicator.color : nil,
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
            fill: model.showTitrantFill ? buretteColor : nil,
            isActive: model.inputState == .addTitrant,
            onTap: {
                buretteEmitModel.addMolecule(
                    amount: buretteEmitAmount,
                    at: layout.buretteMoleculePosition,
                    bottomY: layout.common.topOfWaterPosition(rows: model.rows) + layout.buretteMoleculeSize
                )
            }
        )
        .frame(size: layout.buretteSize)
        .modifyIf(model.inputState == .setTitrantMolarity) {
            $0
                .slider(
                    value: titrantMolarity,
                    minValue: 0.1,
                    maxValue: 0.5,
                    length: 1.4 * layout.buretteSize.width
                )
        }
        .position(layout.burettePosition)
        .transition(.identity)
    }

    private var buretteColor: Color {
        let maxColor = titrant.maximumMolarityColor
        return LinearRGBEquation(
            initialX: AcidAppSettings.minTitrantMolarity,
            finalX: AcidAppSettings.maxTitrantMolarity,
            initialColor: maxColor.withOpacity(0.5),
            finalColor: maxColor
        ).getRgb(at: titrantMolarity.wrappedValue).color
    }

    private var titrant: Titrant {
        if model.components.state.substance.isStrong {
            return strongPrepModel.titrant
        }
        return weakPrepModel.titrant
    }

    private var container: some View {
        AcidAppShakingContainerView(
            models: shakeModel,
            layout: layout.common,
            initialLocation: layout.containerPosition,
            activeLocation: layout.activeContainerPosition,
            type: model.components.state.substance,
            label: model.substance.symbol,
            color: model.substance.color,
            rows: model.rows,
            disabled: model.inputState != .addSubstance
        )
    }

    // Titrant molarity can only be set in the preparation model, so we always use it as a binding
    private var titrantMolarity: Binding<CGFloat> {
        if model.components.state.substance.isStrong {
            return $strongPrepModel.titrantMolarity
        }
        return $weakPrepModel.titrantMolarity
    }

    private var pHString: TextLine {
        let pH = model.components.currentPH
        return "pH: \(pH.str(decimals: 1))"
    }
}

private extension TitrationBeakerTools {
    var currentPH: CGFloat {
        let isStrong = model.components.state.substance.isStrong

        switch model.components.state.phase {
        case .preparation where isStrong:
            return currentPH(
                strongPrepModel.equationData,
                CGFloat(strongPrepModel.substanceAdded)
            )
        case .preEP where isStrong:
            return currentPH(
                strongPreEPModel.equationData,
                CGFloat(strongPreEPModel.titrantAdded)
            )

        case .postEP where isStrong:
            return currentPH(
                strongPostEPModel.equationData,
                CGFloat(strongPostEPModel.titrantAdded)
            )

        case .preparation:
            return currentPH(
                weakPrepModel.equationData,
                CGFloat(weakPrepModel.substanceAdded)
            )
        case .preEP:
            return currentPH(
                weakPreEPModel.equationData,
                CGFloat(weakPreEPModel.titrantAdded)
            )

        case .postEP:
            return currentPH(
                weakPostEPModel.equationData,
                CGFloat(weakPostEPModel.titrantAdded)
            )
        }
    }

    private func currentPH(_ equationData: TitrationEquationData, _ input: CGFloat) -> CGFloat {
        equationData.pValues.value(for: .hydrogen).getY(at: input)
    }
}


private struct TitrationToolsMoleculesView: View {

    let layout: TitrationScreenLayout
    let rows: CGFloat
    let buretteColor: Color
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
            .foregroundColor(RGB.indicator.color)
    }

    private var buretteMolecules: some View {
        molecules(buretteEmitModel, size: layout.buretteMoleculeSize)
            .foregroundColor(buretteColor)
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
    @ObservedObject var strongSubstancePreparationModel: TitrationStrongSubstancePreparationModel
    @ObservedObject var strongSubstancePreEPModel: TitrationStrongSubstancePreEPModel
    @ObservedObject var strongSubstancePostEPModel: TitrationStrongSubstancePostEPModel

    @ObservedObject var weakPrepModel: TitrationWeakSubstancePreparationModel
    @ObservedObject var weakPreEPReaction: ReactingBeakerViewModel<ExtendedSubstancePart>
    @ObservedObject var weakPostEPModel: TitrationWeakSubstancePostEPModel

    var body: some View {
        AdjustableFluidBeaker(
            rows: $model.rows,
            molecules: molecules,
            animatingMolecules: animatingMolecules,
            currentTime: equationInput,
            settings: layout.common.adjustableBeakerSettings,
            canSetLevel: model.inputState == .setWaterLevel,
            beakerColorMultiply: .white,
            sliderColorMultiply: .white,
            beakerModifier: BeakerAccessibilityModifier()
        )
    }

    private var molecules: [BeakerMolecules] {
        let isStrong = componentState.substance.isStrong
        switch componentState.phase {
        case .preparation where isStrong: return [strongSubstancePreparationModel.primaryIonCoords]
        case .postEP where isStrong: return [strongSubstancePostEPModel.titrantMolecules]
        case .preEP where isStrong: return []

        case .preparation: return [weakPrepModel.substanceCoords]
        case .preEP: return weakPreEPReaction.molecules.map(\.molecules)
        case .postEP: return [weakPostEPModel.ionMolecules, weakPostEPModel.secondaryMolecules]
        }
    }

    private var animatingMolecules: [AnimatingBeakerMolecules] {
        let isStrong = componentState.substance.isStrong
        switch componentState.phase {
        case .preparation where isStrong: return []
        case .preEP where isStrong: return [strongSubstancePreEPModel.primaryIonCoords]
        case .postEP where isStrong: return []

        case .preparation: return weakPrepModel.ionCoords
        case .preEP: return []
        case .postEP: return []
        }
    }

    private var equationInput: CGFloat {
        let isStrong = componentState.substance.isStrong
        switch componentState.phase {
        case .preparation where isStrong: return 0
        case .preEP where isStrong: return CGFloat(strongSubstancePreEPModel.titrantAdded)
        case .postEP where isStrong: return 0

        case .preparation: return weakPrepModel.reactionProgress
        case .preEP: return 0
        case .postEP: return 0
        }
    }

    private var componentState: TitrationComponentState.State {
        model.components.state
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
