//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationRightStack: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel


    var body: some View {
        VStack(spacing: 0) {
            Text("equation")
            Spacer(minLength: 0)
            BeakyBox(
                statement: model.statement,
                next: { },
                back: { },
                nextIsDisabled: false,
                settings: layout.common.beakySettings
            )
        }
    }
}
