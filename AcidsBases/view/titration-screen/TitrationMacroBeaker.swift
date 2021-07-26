//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationMacroBeaker: View {

    init(
        layout: TitrationScreenLayout,
        model: TitrationViewModel
    ) {
        self.layout = layout
        self.model = model
        self.beakerSettings = layout.common.adjustableBeakerSettings
    }

    let layout: TitrationScreenLayout
    let beakerSettings: AdjustableFluidBeakerSettings
    @ObservedObject var model: TitrationViewModel

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(alignment: .bottom, spacing: 0) {
                slider
                if model.beakerState == .macroscopic {
                    if UIAccessibility.isVoiceOverRunning {
                        macroscopicBeaker
                            .modifier(TitrationBeakerActionModifier(model: model))
                    } else {
                        macroscopicBeaker
                    }

                } else {
                    if UIAccessibility.isVoiceOverRunning {
                        microscopicBeaker
                            .modifier(TitrationBeakerActionModifier(model: model))
                    } else {
                        microscopicBeaker
                    }
                }
            }
            toggle
        }
        .padding(.bottom, layout.common.beakerBottomPadding)
    }

    private var toggle: some View {
        HStack {
            SelectionToggleText(
                text: "Microscopic",
                isSelected: model.beakerState == .microscopic,
                action: { model.beakerState = .microscopic }
            )

            SelectionToggleText(
                text: "Macroscopic",
                isSelected: model.beakerState == .macroscopic,
                action: { model.beakerState = .macroscopic }
            )
        }
        .font(.system(size: layout.common.toggleFontSize))
        .frame(height: layout.common.toggleHeight)
        .frame(
            minWidth: layout.common.beakerWidth,
            maxWidth: layout.common.beakerWidth + layout.common.sliderSettings.handleWidth
        )
        .minimumScaleFactor(0.1)
        .lineLimit(1)
        .background(Color.white)
        .colorMultiply(model.highlights.colorMultiply(for: nil))
    }

    private var slider: some View {
        CustomSlider(
            value: $model.rows,
            axis: beakerSettings.sliderAxis,
            orientation: .portrait,
            includeFill: true,
            settings: beakerSettings.sliderSettings,
            disabled: model.inputState != .setWaterLevel,
            useHaptics: true
        )
        .frame(
            width: beakerSettings.sliderSettings.handleWidth,
            height: beakerSettings.sliderHeight
        )
        .background(
            Color.white
                .padding(.horizontal, beakerSettings.sliderPadding)
                .padding(.top, beakerSettings.sliderPadding)
        )
        .colorMultiply(model.highlights.colorMultiply(for: .waterSlider))
        .accessibility(
            label: Text("Slider for number of rows of molecules in beaker")
        )
    }

    private var microscopicBeaker: some View {
        TitrationFilledBeaker(
            model: model
        )
        .frame(
            width: beakerSettings.beakerWidth,
            height: beakerSettings.beakerHeight
        )
        .colorMultiply(model.highlights.colorMultiply(for: nil))
    }

    private var macroscopicBeaker: some View {
        TitrationMacroscopicBeaker(
            layout: layout,
            model: model
        )
        .frame(
            width: beakerSettings.beakerWidth,
            height: beakerSettings.beakerHeight
        )
        .colorMultiply(model.highlights.colorMultiply(for: .macroscopicBeaker))
    }
}

private struct TitrationMacroscopicBeaker: View {

    init(layout: TitrationScreenLayout, model: TitrationViewModel) {
        self.layout = layout
        self.model = model
        self.strongModel = model.components.strongSubstancePreEPModel
        self.weakModel = model.components.weakSubstancePreEPModel
    }

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel
    @ObservedObject var strongModel: TitrationStrongSubstancePreEPModel
    @ObservedObject var weakModel: TitrationWeakSubstancePreEPModel

    var body: some View {
        FillableBeaker(
            waterColor: color.getRgb(at: colorInputFraction).color,
            waterHeight: layout.waterHeight(forRows: model.rows),
            highlightBeaker: true,
            settings: .init(beakerWidth: layout.common.beakerWidth)
        ) {
            EmptyView()
        }
        .accessibility(label: Text("Macroscopic view of liquid in beaker which changes color"))
        .accessibility(value: Text(accessibilityValue))
        .accessibility(addTraits: .updatesFrequently)
    }

    private var color: RGBEquation {
        LinearRGBEquation(
            initialX: 0,
            finalX: 1,
            initialColor: model.macroBeakerState.startColor,
            finalColor: model.macroBeakerState.endColor
        )
    }

    private var colorInputFraction: CGFloat {
        colorInputFractionEquation.getY(at: equationInput)
    }

    private var colorInputFractionEquation: Equation {
        if model.macroBeakerState == .indicator {
            return LinearEquation(x1: 0, y1: 0, x2: equationMaxInput, y2: 1)
        }

        let settings = AcidAppSettings.MacroBeaker.self
        let finalTitrantToAdd = settings.titrantToAddDuringSharpColorChange
        return SwitchingEquation.linear(
            initial: .zero,
            mid: CGPoint(
                x: equationMaxInput - CGFloat(finalTitrantToAdd),
                y: settings.colorTurningPointProgress
            ),
            final: CGPoint(x: equationMaxInput, y: 1)
        )
    }

    private var equationMaxInput: CGFloat {
        switch model.macroBeakerState {
        case .indicator: return CGFloat(model.maxIndicator)
        case .strongTitrant: return CGFloat(strongModel.maxTitrant)
        case .weakTitrant: return CGFloat(weakModel.maxTitrant)
        }
    }

    private var equationInput: CGFloat {
        switch model.macroBeakerState {
        case .indicator: return CGFloat(model.indicatorAdded)
        case .strongTitrant: return CGFloat(strongModel.titrantAdded)
        case .weakTitrant: return CGFloat(weakModel.titrantAdded)
        }
    }

    private var accessibilityValue: String {
        let start = "\(model.macroBeakerState.startColorName)"
        let end = "\(model.macroBeakerState.endColorName)"

        if colorInputFraction == 0 {
            return start
        } else if colorInputFraction == 1 {
            return end
        }

        let percentage = colorInputFraction.percentage
        return "\(percentage) between \(start) and \(end)"
    }
}

private struct TitrationFilledBeaker: View {

    init(model: TitrationViewModel) {
        self.model = model
        self.strongPrepModel = model.components.strongSubstancePreparationModel
        self.strongPreEPModel = model.components.strongSubstancePreEPModel
        self.strongPostEPModel = model.components.strongSubstancePostEPModel
        self.weakPrepModel = model.components.weakSubstancePreparationModel
        self.weakPreEPReaction = model.components.weakSubstancePreEPModel.beakerReactionModel
        self.weakPostEPModel = model.components.weakSubstancePostEPModel
    }

    @ObservedObject var model: TitrationViewModel

    @ObservedObject var strongPrepModel: TitrationStrongSubstancePreparationModel
    @ObservedObject var strongPreEPModel: TitrationStrongSubstancePreEPModel
    @ObservedObject var strongPostEPModel: TitrationStrongSubstancePostEPModel

    @ObservedObject var weakPrepModel: TitrationWeakSubstancePreparationModel
    @ObservedObject var weakPreEPReaction: ReactingBeakerViewModel<ExtendedSubstancePart>
    @ObservedObject var weakPostEPModel: TitrationWeakSubstancePostEPModel


    var body: some View {
        FilledBeaker(
            molecules: molecules,
            animatingMolecules: animatingMolecules,
            currentTime: equationInput,
            rows: model.rows
        )
    }

    private var molecules: [BeakerMolecules] {
        let isStrong = componentState.substance.isStrong
        switch componentState.phase {
        case .preparation where isStrong: return [strongPrepModel.primaryIonCoords]
        case .postEP where isStrong: return [strongPostEPModel.titrantMolecules]
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
        case .preEP where isStrong: return [strongPreEPModel.primaryIonCoords]
        case .postEP where isStrong: return []

        case .preparation: return []
        case .preEP: return []
        case .postEP: return []
        }
    }

    private var equationInput: CGFloat {
        let isStrong = componentState.substance.isStrong
        switch componentState.phase {
        case .preparation where isStrong: return 0
        case .preEP where isStrong: return CGFloat(strongPreEPModel.titrantAdded)
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

private struct TitrationBeakerActionModifier: ViewModifier {

    @ObservedObject var model: TitrationViewModel

    func body(content: Content) -> some View {
        content
            .modifyIf(model.inputState == .addSubstance, modifier: addSubstanceAction(model: model))
            .modifyIf(model.inputState == .addSubstance, modifier: addIndicatorAction(model: model))
            .modifyIf(model.inputState == .addSubstance, modifier: addTitrantAction(model: model))
    }
}

private func addIndicatorAction(model: TitrationViewModel) -> some ViewModifier {
        BeakerAccessibilityAddMultipleCountActions(
            actionName: { "Add \($0) indicator molecule to the beaker" },
            doAdd: model.accessibilityAddIndicator,
            firstCount: 5,
            secondCount: 20
        )
}

private func addTitrantAction(model: TitrationViewModel) -> some ViewModifier {
    BeakerAccessibilityAddMultipleCountActions(
        actionName: { "Add \($0) titrant molecules to the beaker" },
        doAdd: model.incrementTitrant,
        firstCount: 1,
        secondCount: 20
    )
}

private func addSubstanceAction(model: TitrationViewModel) -> some ViewModifier {
    let addSubstance = model.components.state.substance
    let name = model.substance.symbol.label
    return BeakerAccessibilityAddMultipleCountActions(
        actionName: { "Add \($0) \(name) molecules to the beaker" },
        doAdd: { model.increment(substance: addSubstance, count: $0) },
        firstCount: 5,
        secondCount: 15
    )
}


struct TitrationMacroBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            TitrationMacroBeaker(
                layout: .init(
                    common: .init(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                ),
                model: .init(
                    titrationPersistence: InMemoryTitrationInputPersistence(),
                    namePersistence: InMemoryNamePersistence()
                )
            )
        }
        .previewLayout(.iPhone8Landscape)
        .padding()
    }
}
