//
// Reactions App
//
  

import SwiftUI

struct A_0: View {
    var body: some View {
        HStack(spacing: 1) {
            BracketA()
            Text("0")
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(y: 9)
                .fixedSize()
            EndBracket()
        }.minimumScaleFactor(1)
    }
}

struct A_t: View {
    var body: some View {
        HStack(spacing: 1) {
            BracketA()
            Text("t")
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(y: 9)
                .fixedSize()
            EndBracket()
        }
    }
}

fileprivate struct BracketA: View {
    var body: some View {
        FixedText("[A")
    }

}
fileprivate struct EndBracket: View {
    var body: some View {
        FixedText("]")
    }
}

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
        }.minimumScaleFactor(1)
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
