//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationRightStack: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel
    @ObservedObject var strongSubstancePreparationModel: TitrationStrongSubstancePreparationModel
    @ObservedObject var strongSubstancePreEPModel: TitrationStrongSubstancePreEPModel
    @ObservedObject var strongSubstancePostEPModel: TitrationStrongSubstancePostEPModel
    @ObservedObject var weakPreparationModel: TitrationWeakSubstancePreparationModel
    @ObservedObject var weakPreEPModel: TitrationWeakSubstancePreEPModel
    @ObservedObject var weakPostEPModel: TitrationWeakSubstancePostEPModel

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            topStack
                .zIndex(1)

            Spacer(minLength: 0)

            TitrationEquationView(
                equationState: model.equationState,
                data: equationData,
                equationInput: equationInput
            )
            .frame(size: layout.equationSize)
            .colorMultiply(model.highlights.colorMultiply(for: nil))
            .accessibilityElement(children: .contain)

            Spacer(minLength: 0)

            BeakyBox(
                statement: model.statement,
                next: model.next,
                back: model.back,
                nextIsDisabled: !model.canGoNext,
                settings: layout.common.beakySettings
            )
        }
    }

    private var topStack: some View {
        HStack(alignment: .top, spacing: 0) {
            reactionDefinition
            toggles
        }
    }

    private var reactionDefinition: some View {
        ReactionDefinitionView(
            reaction: model.substance.titrationReactionDefinition,
            fontSize: layout.common.reactionDefinitionFontSize,
            circleSize: layout.common.reactionDefinitionCircleSize
        )
        .frame(size: layout.reactionDefinitionSize)
        .colorMultiply(model.highlights.colorMultiply(for: nil))
    }

    private var toggles: some View {
        VStack(alignment: .trailing, spacing: layout.branchMenuVSpacing) {
            BranchMenu(layout: layout.common.branchMenu)
                .zIndex(1)
            selectionView
        }
        .padding(.trailing, layout.togglesTrailingPadding)
    }

    private var selectionView: some View {
        DropDownSelectionView(
            title: "Choose a substance",
            options: model.availableSubstances,
            isToggled: $model.substanceSelectionIsToggled,
            selection: $model.substance,
            height: layout.common.toggleHeight,
            animation: nil,
            displayString: { $0.symbol },
            label: { $0.chargedSymbol.text.label },
            disabledOptions: [],
            onSelection: model.next
        )
        .frame(height: layout.common.toggleHeight, alignment: .top)
        .disabled(model.inputState != .selectSubstance)
        .colorMultiply(model.highlights.colorMultiply(for: .reactionSelection))
    }

    private var equationData: TitrationEquationData {
        let isStrong = model.components.state.substance.isStrong

        switch model.components.state.phase {
        case .preparation where isStrong: return strongSubstancePreparationModel.equationData
        case .preEP where isStrong: return strongSubstancePreEPModel.equationData
        case .postEP where isStrong: return strongSubstancePostEPModel.equationData

        case .preparation: return weakPreparationModel.equationData
        case .preEP: return weakPreEPModel.equationData
        case .postEP: return weakPostEPModel.equationData
        }
    }

    private var equationInput: CGFloat {
        let isStrong = model.components.state.substance.isStrong

        switch model.components.state.phase {
        case .preparation where isStrong: return CGFloat(strongSubstancePreparationModel.substanceAdded)
        case .preEP where isStrong: return CGFloat(strongSubstancePreEPModel.titrantAdded)
        case .postEP where isStrong: return CGFloat(strongSubstancePostEPModel.titrantAdded)

        case .preparation: return weakPreparationModel.reactionProgress
        case .preEP: return CGFloat(weakPreEPModel.titrantAdded)
        case .postEP: return CGFloat(weakPostEPModel.titrantAdded)
        }
    }
}

extension TitrationRightStack {
    init(
        layout: TitrationScreenLayout,
        model: TitrationViewModel
    ) {
        self.init(
            layout: layout,
            model: model,
            strongSubstancePreparationModel: model.components.strongSubstancePreparationModel,
            strongSubstancePreEPModel: model.components.strongSubstancePreEPModel,
            strongSubstancePostEPModel: model.components.strongSubstancePostEPModel,
            weakPreparationModel: model.components.weakSubstancePreparationModel,
            weakPreEPModel: model.components.weakSubstancePreEPModel,
            weakPostEPModel: model.components.weakSubstancePostEPModel
        )
    }
}
