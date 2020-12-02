//
// Reactions App
//
  

import SwiftUI

struct C_1: View {

    var body: some View {
        SubscriptView(
            mainValue: "c",
            subscriptValue: "1"
        )
    }
}

struct C_2: View {

    var body: some View {
        SubscriptView(
            mainValue: "c",
            subscriptValue: "2"
        )
    }
}

struct T_1: View {

    let uppercase: Bool
    init(uppercase: Bool = false) {
        self.uppercase = uppercase
    }

    var body: some View {
        SubscriptView(
            mainValue: uppercase ? "T" : "t",
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
        SubscriptView(
            mainValue: uppercase ? "T" : "t",
            subscriptValue: "2"
        )
    }
}

fileprivate struct SubscriptView: View {
    let mainValue: String
    let subscriptValue: String

    var body: some View {
        HStack(spacing: 0) {
            Text(mainValue)
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
            C_1()
            C_2()
        }
    }
}
