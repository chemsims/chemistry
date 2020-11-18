//
// Reactions App
//
  

import SwiftUI

struct SubscriptView: View {

    let main: String
    let subscriptComponent: String
    let mainFontSize: CGFloat
    let subscriptFontSize: CGFloat
    let subscriptBaselineOffset: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            Text(main)
                .font(.system(size: mainFontSize))

            Text(subscriptComponent)
                .font(.system(size: subscriptFontSize))
                .offset(y: -subscriptBaselineOffset)
        }
    }
}

