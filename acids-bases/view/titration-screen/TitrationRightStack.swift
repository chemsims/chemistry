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
        switch model.reactionPhase {
        case .strongSubstancePreparation: return strongSubstancePreparationModel.equationData
        case .strongSubstancePreEP: return strongSubstancePreEPModel.equationData
        case .strongSubstancePostEP:
            return strongSubstancePostEPModel.equationData
        }
    }
}
