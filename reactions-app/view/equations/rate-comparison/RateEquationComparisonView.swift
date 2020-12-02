//
// Reactions App
//

import SwiftUI

struct RateEquationComparisonView: View {

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    private let naturalWidth: CGFloat = 381
    private let naturalHeight: CGFloat = 277

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledRateEquationComparisonView()
        }.frame(width: maxWidth, height: maxHeight)
    }
}

fileprivate struct UnscaledRateEquationComparisonView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            GeneralRateEquationView(order: 0) {
                ZeroOrderRateComparisonView()
            }
            GeneralRateEquationView(order: 1) {
                FirstOrderRateComparisonView()

            }
            GeneralRateEquationView(order: 2) {
                SecondOrderRateComparisonView()
            }
        }
    }

}

struct GeneralRateEquationView<Content: View>: View {

    let order: Int
    let content: () -> Content

    var body: some View {
        HStack(spacing: 25) {
            Text("Order: \(order)")
                .fixedSize()
            content()
        }
        .lineLimit(1)
        .font(.system(size: EquationSettings.fontSize))
        .minimumScaleFactor(1)
    }
}

fileprivate struct ZeroOrderRateComparisonView: View {

    var body: some View {
        GeneralRateComparisonEquation(
            dividerWidth: 130
        ) {
            HStack(spacing: 4) {
                A_t()
                FixedText("-")
                A_0()
            }
        }
    }
}

fileprivate struct SecondOrderRateComparisonView: View {
    var body: some View {
        GeneralRateComparisonEquation(
            dividerWidth: 217
        ) {
            HStack(spacing: 4) {
                inverse {
                    A_t()
                }
                FixedText("-")
                inverse {
                    A_0()
                }
            }
        }
    }

    private func inverse<Content: View>(aTerm: () -> Content) -> some View {
        HStack(spacing: 0) {
            Text("(1/")
                .fixedSize()
            aTerm()
            Text(")")
                .fixedSize()
        }
    }
}

fileprivate struct FirstOrderRateComparisonView: View {

    var body: some View {
        GeneralRateComparisonEquation(
            dividerWidth: 170
        ) {
            HStack(spacing: 0) {
                log {
                    A_t()
                }
                FixedText("-")
                log {
                    A_0()
                }
            }
        }
    }

    private func log<Content: View>(aTerm: () -> Content) -> some View {
        HStack(spacing: 0) {
            Text("ln")
                .fixedSize()
            aTerm()
        }
    }
}

fileprivate struct GeneralRateComparisonEquation<Content: View>: View {

    let dividerWidth: CGFloat
    let numerator:() -> Content

    var body: some View {
        HStack(spacing: 2) {
            Rate()
            VStack(spacing: 4) {
                numerator()
                Rectangle()
                    .frame(width: dividerWidth, height: 2)
                Time()
            }
        }
        .font(.system(size: EquationSettings.fontSize))
        .lineLimit(1)
    }
}

fileprivate struct Rate: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("k")
                .fixedSize()
            Text("=")
                .fixedSize()
        }
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

fileprivate struct BracketA: View {
    var body: some View {
        Text("[A")
            .fixedSize()
    }

}
fileprivate struct EndBracket: View {
    var body: some View {
        Text("]")
            .fixedSize()
    }
}

fileprivate struct Time: View {
    var body: some View {
        Text("t")
            .fixedSize()
    }
}

struct RateEquationComparisonView_Previews: PreviewProvider {
    static var previews: some View {

        UnscaledRateEquationComparisonView()
            .border(Color.red)
            .previewLayout(.fixed(width: 600, height: 600))

        RateEquationComparisonView(
            maxWidth: 300,
            maxHeight: 300
        ).previewLayout(.fixed(width: 512, height: 315))
    }
}
