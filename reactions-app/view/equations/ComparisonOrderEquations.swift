//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderRateComparisonView: View {

    private let fontSize: CGFloat = 30
    private let subscriptFontSize: CGFloat = 22

    var body: some View {
        HStack(spacing: 2) {
            Text("k")
                .frame(width: 21)
            Text("=")
                .frame(width: 19)
            VStack(spacing: 4) {
                HStack(spacing: 5) {
                    HStack(spacing: 1) {
                        bracketA
                        Text("t")
                            .font(.system(size: subscriptFontSize))
                            .offset(y: 9)
                            .frame(width: 10)
                        endBracket
                    }

                    Text("-")
                        .frame(width: 12)

                    HStack(spacing: 1) {
                        bracketA
                        Text("0")
                            .font(.system(size: subscriptFontSize))
                            .offset(y: 9)
                            .frame(width: 15)
                        endBracket
                    }
                }
                Rectangle()
                    .frame(width: 180, height: 2)
                Text("t")
                    .frame(width: 14)
            }
        }
        .font(.system(size: fontSize))
    }

    private var bracketA: some View {
        Text("[A")
            .frame(width: 32)
    }
    private var endBracket: some View {
        Text("]")
            .frame(width: 8)
    }
}

struct ComparisonOrderEquations_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ZeroOrderRateComparisonView()
                .scaleEffect(x: 1, y: 1)
        }.previewLayout(.fixed(width: 575, height: 312))

    }
}
