//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferRightStack: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel
    @ObservedObject var weakModel: BufferWeakSubstanceComponents

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            selectionToggle
            Spacer(minLength: 0)
            terms
            Spacer(minLength: 0)
            beaker
        }
    }

    private var selectionToggle: some View {
        DropDownSelectionView(
            title: "Choose a substance",
            options: model.availableSubstances,
            isToggled: $model.substanceSelectionIsToggled,
            selection: $weakModel.substance,
            height: layout.common.toggleHeight,
            animation: nil,
            displayString: { $0.symbol },
            label: { $0.symbol },
            disabledOptions: [],
            onSelection: model.next
        )
        .frame(height: layout.common.toggleHeight, alignment: .top)
        .zIndex(1)
    }

    private var terms: some View {
        SwitchingBufferEquationView(
            model: model,
            weakSubstanceModel: model.weakSubstanceModel,
            saltModel: model.saltModel,
            strongSubstanceModel: model.strongSubstanceModel
        )
        .frame(size: layout.equationSize)
    }

    private var beaker: some View {
        BeakyBox(
            statement: model.statement,
            next: model.next,
            back: model.back,
            nextIsDisabled: !model.canGoNext,
            settings: layout.common.beakySettings
        )
    }
}

private struct SwitchingBufferEquationView: View {

    @ObservedObject var model: BufferScreenViewModel
    @ObservedObject var weakSubstanceModel: BufferWeakSubstanceComponents
    @ObservedObject var saltModel: BufferSaltComponents
    @ObservedObject var strongSubstanceModel: BufferStrongSubstanceComponents

    var body: some View {
        BufferEquationView(
            progress: progress,
            state: model.equationState,
            data: data
        )
    }

    private var progress: CGFloat {
        switch model.phase {
        case .addWeakSubstance: return weakSubstanceModel.progress
        case .addSalt: return CGFloat(saltModel.substanceAdded)
        case .addStrongSubstance: return CGFloat(strongSubstanceModel.substanceAdded)
        }
    }

    private var data: BufferEquationData {
        switch model.phase {
        case .addWeakSubstance: return weakSubstanceModel.equationData
        case .addSalt: return saltModel.equationData
        case .addStrongSubstance: return strongSubstanceModel.equationData
        }
    }
}

struct BufferRightStack_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            HStack {
                Spacer()
                BufferRightStack(
                    layout: BufferScreenLayout(
                        common: AcidBasesScreenLayout(
                            geometry: geo,
                            verticalSizeClass: nil,
                            horizontalSizeClass: nil
                        )
                    ),
                    model: BufferScreenViewModel(),
                    weakModel: BufferScreenViewModel().weakSubstanceModel
                )
            }
        }
        .padding()
        .previewLayout(.iPhone8Landscape)
    }
}
