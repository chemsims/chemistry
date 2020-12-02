//
// Reactions App
//
  

import SwiftUI

struct HalfTime: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("t")
                .font(.system(size: EquationSettings.fontSize))
                .fixedSize()
            Text("1/2")
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(y: 10)
                .fixedSize()
        }
    }
}

struct Halftime_Previews: PreviewProvider {
    static var previews: some View {
        HalfTime()
    }
}
