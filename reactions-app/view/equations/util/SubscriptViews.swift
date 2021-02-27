//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct A_0: View {
    var body: some View {
        BracketSubscript(mainValue: "A", subscriptValue: "0")
    }
}

struct A_t: View {
    var body: some View {
        BracketSubscript(mainValue: "A", subscriptValue: "t")
    }
}

struct BracketSubscript: View {
    let mainValue: String
    let subscriptValue: String

    var body: some View {
        HStack(spacing: 1) {
            FixedText("[\(mainValue)")
            Text(subscriptValue)
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(y: 9)
                .fixedSize()
            EndBracket()
        }.minimumScaleFactor(1)
    }
}

private struct BracketA: View {
    var body: some View {
        FixedText("[A")
    }

}
private struct EndBracket: View {
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

private struct SubscriptView: View {
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
