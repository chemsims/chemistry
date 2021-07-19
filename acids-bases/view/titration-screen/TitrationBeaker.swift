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
            TitrationMacroBeaker(
                layout: layout,
                model: model
            )
            .accessibility(sortPriority: 1)

            TitrationBeakerTools(
                layout: layout,
                model: model
            )
            .accessibility(sortPriority: 2)
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

    private let dropperEmitAmount = 5
    private let buretteEmitAmount = 1
    private let buretteFastEmitAmount = 6

    var body: some View {
        ZStack {
            // We add the backgrounds before the molecules, otherwise the
            // highlights would cover part of the molecules
            buretteBackground
            indicatorBackground

            Group {
                molecules

                phMeter
                    .accessibility(sortPriority: 5)
            }
            .colorMultiply(model.highlights.colorMultiply(for: nil))

            dropper
                .accessibility(sortPriority: 4)
//
            burette
                .accessibility(sortPriority: 3)

            container
                .accessibility(sortPriority: 2)
        }
        .frame(width: layout.toolStackWidth)
        .accessibilityElement(children: .contain)
    }

    private var molecules: some View {
        TitrationToolsMoleculesView(
            layout: layout,
            rows: model.rows,
            buretteColor: buretteColor,
            dropperEmitModel: model.dropperEmitModel,
            buretteEmitModel: model.buretteEmitModel
        )
        .frame(
            width: layout.toolStackWidth,
            height: layout.common.height
        )
    }

    private var phMeter: some View {
        DraggablePhMeter(
            pHEquation: currentPH.0,
            pHEquationInput: currentPH.1,
            shouldShowLabelWhenInWater: model.showPhString,
            layout: layout.common,
            initialPosition: layout.phMeterPosition,
            rows: model.rows,
            beakerDistanceFromBottomOfScreen: layout.common.toggleHeight
        )
    }

    private var dropper: some View {
        Dropper(
            isActive: model.inputState == .addIndicator,
            tubeFill: model.showIndicatorFill ? RGB.indicator.color : nil,
            fillPercent: model.dropperFillPercent,
            onTap: {
                dropperEmitModel.addMolecule(
                    amount: dropperEmitAmount,
                    at: layout.dropperMoleculePosition,
                    bottomY:
                        layout.topOfWaterPosition(forRows: model.rows) + layout.dropperMoleculeSize
                )
            }
        )
        .frame(size: layout.dropperSize)
        .colorMultiply(model.highlights.colorMultiply(for: .indicator))
        .position(layout.dropperPosition)
        .accessibilityElement(children: .combine)
        .accessibility(label: Text("Indicator dropper"))
        .accessibility(hint: Text("Adds indicator into the beaker"))
    }

    private var burette: some View {
        Burette(
            fill: model.showTitrantFill ? buretteColor : nil,
            isActive: model.inputState == .addTitrant,
            onTap: { speed in
                let emitAmount = speed == .fast ? buretteFastEmitAmount : buretteEmitAmount
                buretteEmitModel.addMolecule(
                    amount: emitAmount,
                    at: layout.buretteMoleculePosition,
                    bottomY: layout.common.topOfWaterPosition(rows: model.rows) + layout.buretteMoleculeSize
                )
            },
            accessibilityActionName: { speed in
                let amount = speed == .fast ? buretteFastEmitAmount : buretteEmitAmount
                let molecules = amount == 1 ? "molecule" : "molecules"
                return "Add \(amount) titrant \(molecules) to the beaker"
            }
        )
        .frame(size: layout.buretteSize)
        .modifyIf(model.inputState == .setTitrantMolarity) {
            $0
                .slider(
                    value: titrantMolarity,
                    minValue: AcidAppSettings.minTitrantMolarity,
                    maxValue: AcidAppSettings.maxTitrantMolarity,
                    accessibilityLabel: "Slider for titrant molarity",
                    length: layout.buretteSliderLengthToBuretteWidth * layout.buretteSize.width
                )
        }
        .colorMultiply(model.highlights.colorMultiply(for: .burette))
        .position(layout.burettePosition)
        .transition(.identity)
    }

    private var buretteBackground: some View {
        elementBackground(.burette, size: layout.buretteSize, position: layout.burettePosition)
    }

    private var indicatorBackground: some View {
        elementBackground(.indicator, size: layout.dropperSize, position: layout.dropperPosition)
    }

    private func elementBackground(
        _ element: TitrationScreenElement,
        size: CGSize,
        position: CGPoint
    ) -> some View {
        Rectangle()
            .foregroundColor(.white)
            .colorMultiply(model.highlights.colorMultiply(for: element))
            .frame(size: size.scaled(by: 1.1))
            .position(position)
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
        let textLine = model.substance.chargedSymbol(ofPart: .substance).text
        return AcidAppShakingContainerView(
            models: shakeModel,
            layout: layout.common,
            initialLocation: layout.containerPosition,
            activeLocation: layout.activeContainerPosition,
            type: model.components.state.substance,
            label: textLine,
            accessibilityName: textLine.label,
            color: model.substance.color,
            topOfWaterPosition: layout.topOfWaterPosition(
                forRows: model.rows
            ),
            disabled: model.inputState != .addSubstance,
            includeContainerBackground: model.highlights.highlight(.container),
            onActivateContainer: { _ in
                model.highlights.clear()
            }
        )
        .colorMultiply(model.highlights.colorMultiply(for: .container))
    }

    // Titrant molarity can only be set in the preparation model, so we always use it as a binding
    private var titrantMolarity: Binding<CGFloat> {
        if model.components.state.substance.isStrong {
            return $strongPrepModel.titrantMolarity
        }
        return $weakPrepModel.titrantMolarity
    }
}

private extension TitrationBeakerTools {
    var currentPH: (Equation, CGFloat) {
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

    private func currentPH(_ equationData: TitrationEquationData, _ input: CGFloat) -> (Equation, CGFloat) {
        (equationData.pValues.value(for: .hydrogen), input)
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
                        height: layout.topOfWaterPosition(forRows: rows)
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
        let availableHeight = 0.95 * toolsBottomY
        let maxBuretteHeight = availableHeight - buretteTooltipHeight

        let height = min(1.7 * buretteWidth, maxBuretteHeight)
        return CGSize(width: buretteWidth, height: height)
    }

    private var buretteWidth: CGFloat {
        availableWidthForDropperAndBurette - dropperSize.width
    }

    private var buretteTooltipHeight: CGFloat {
        let sliderLength = buretteSliderLengthToBuretteWidth * buretteWidth
        return SliderOverlay.tooltipDepth(forLength: sliderLength, position: .top)
    }

    var buretteSliderLengthToBuretteWidth: CGFloat {
        1.4
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
        let beakerTotalHeight = common.beakerBottomPadding + common.beakerHeight + common.toggleHeight
        let availableHeight = common.height - beakerTotalHeight

        return 0.8 * availableHeight
    }

    private var availableWidthForDropperAndBurette: CGFloat {
        toolStackWidth - (3 * common.beakerToolsSpacing) - common.containerSize.width - common.phMeterSize.width
    }

    private var totalBeakerHeight: CGFloat {
        common.beakerHeight + common.toggleHeight
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
                model: TitrationViewModel(
                    titrationPersistence: InMemoryTitrationInputPersistence(),
                    namePersistence: InMemoryNamePersistence()
                )
            )
        }
        .padding()
        .previewLayout(.iPhone8Landscape)
    }
}
