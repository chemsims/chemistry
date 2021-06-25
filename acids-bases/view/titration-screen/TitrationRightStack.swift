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
        VStack(spacing: 0) {
            TitrationEquationView(
                data: equationData,
                equationSet: model.equationState.equationSet
            )
            Spacer(minLength: 0)
            BeakyBox(
                statement: model.statement,
                next: model.next,
                back: model.back,
                nextIsDisabled: model.nextIsDisabled,
                settings: layout.common.beakySettings
            )
        }
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
