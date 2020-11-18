//
// Reactions App
//
  

import SwiftUI

struct SubscriptView: View {

    let settings: EquationGeometrySettings
    let main: String
    let subscriptComponent: String

    var body: some View {
        HStack(spacing: 0) {
            Text(main)
                .font(.system(size: settings.fontSize))

            Text(subscriptComponent)
                .font(.system(size: settings.subscriptFontSize))
                .offset(y: -settings.subscriptBaselineOffset)
        }
    }
}

