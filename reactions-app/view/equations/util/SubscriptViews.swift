//
// Reactions App
//
  

import SwiftUI

struct T_1: View {

    let uppercase: Bool
    init(uppercase: Bool = false) {
        self.uppercase = uppercase
    }

    var body: some View {
        TSubscript(
            uppercase: uppercase,
            subscriptValue: "1"
        )
    }
}

struct T_2: View {

    let uppercase: Bool
    init(uppercase: Bool = false) {
        self.uppercase = uppercase
    }

    var body: some View {
        TSubscript(
            uppercase: uppercase,
            subscriptValue: "2"
        )
    }
}

fileprivate struct TSubscript: View {
    let uppercase: Bool
    let subscriptValue: String

    var body: some View {
        HStack(spacing: 0) {
            Text(uppercase ? "T" : "t")
                .fixedSize()
                .font(.system(size: EquationSettings.fontSize))
            Text(subscriptValue)
                .offset(y: 12)
                .font(.system(size: EquationSettings.subscriptFontSize))
                .fixedSize()
        }
    }

}

struct SubscriptViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            T_1()
            T_2()
        }
    }
}
