//
// Reactions App
//

import SwiftUI

struct RateEquationComparisonView: View {

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    private let naturalWidth: CGFloat = 414
    private let naturalHeight: CGFloat = 275

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
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
        }.frame(width: maxWidth, height: maxHeight)
    }
}

struct GeneralRateEquationView<Content: View>: View {

    let order: Int
    let content: () -> Content

    var body: some View {
        HStack(spacing: 25) {
            Text("Order: \(order)")
                .lineLimit(1)
                .font(.system(size: RateEquationSizes.fontSize))
                .frame(width: 112, alignment: .leading)
            content()
        }
    }
}

fileprivate struct ZeroOrderRateComparisonView: View {

    var body: some View {
        GeneralRateComparisonEquation(
            dividerWidth: 130
        ) {
            HStack(spacing: 4) {
                A_t()
                Minus()
                A_0()
            }
        }
    }
}

fileprivate struct FirstOrderRateComparisonView: View {
    var body: some View {
        GeneralRateComparisonEquation(
            dividerWidth: 217
        ) {
            HStack(spacing: 4) {
                inverse {
                    A_t()
                }
                Minus()
                inverse {
                    A_0()
                }
            }
        }
    }

    private func inverse<Content: View>(aTerm: () -> Content) -> some View {
        HStack(spacing: 0) {
            Text("(1/")
                .frame(width: 36)
            aTerm()
            Text(")")
                .frame(width: 17)
        }
    }
}

fileprivate struct SecondOrderRateComparisonView: View {

    var body: some View {
        GeneralRateComparisonEquation(
            dividerWidth: 170
        ) {
            HStack(spacing: 0) {
                log {
                    A_t()
                }
                Minus()
                log {
                    A_0()
                }
            }
        }
    }

    private func log<Content: View>(aTerm: () -> Content) -> some View {
        HStack(spacing: 0) {
            Text("ln")
                .frame(width: 25)
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
        .font(.system(size: RateEquationSizes.fontSize))
        .lineLimit(1)
    }
}

fileprivate struct Rate: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("k")
                .frame(width: 21)

            Text("=")
                .frame(width: 19)
        }
    }
}

fileprivate struct A_t: View {
    var body: some View {
        HStack(spacing: 1) {
            BracketA()
            Text("t")
                .font(.system(size: RateEquationSizes.subscriptFontSize))
                .offset(y: 9)
                .frame(width: 10)
            EndBracket()
        }
    }
}

struct A_0: View {
    var body: some View {
        HStack(spacing: 1) {
            BracketA()
            Text("0")
                .font(.system(size: RateEquationSizes.subscriptFontSize))
                .offset(y: 9)
                .frame(width: 15)
            EndBracket()
        }
    }
}

fileprivate struct BracketA: View {
    var body: some View {
        Text("[A")
            .frame(width: 32)
    }

}
fileprivate struct EndBracket: View {
    var body: some View {
        Text("]")
            .frame(width: 8)
    }
}

fileprivate struct Minus: View {
    var body: some View {
        Text("-")
            .frame(width: 12)
    }
}

fileprivate struct Time: View {
    var body: some View {
        Text("t")
            .frame(width: 14)
    }
}

struct RateEquationSizes {

    static let fontSize: CGFloat = 30
    static let subscriptFontSize: CGFloat = 22

    private static let orderStringSpacing: CGFloat = 10
    private static let orderStringWidth: CGFloat = 112
    private static let orderStringHeight: CGFloat = 35

    private static let zeroOrderWidth: CGFloat = 224
    private static let zeroOrderHeight: CGFloat = 81

    static let zeroOrderTotalWidth = totalWidth(equationWidth: zeroOrderWidth)
    static let zeroOrderTotalHeight = totalHeight(equationHeight: zeroOrderHeight)


    static func totalWidth(equationWidth: CGFloat) -> CGFloat {
        orderStringWidth + orderStringSpacing + equationWidth
    }

    static func totalHeight(equationHeight: CGFloat) -> CGFloat {
        max(equationHeight, orderStringHeight)
    }

}

struct RateEquationComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        RateEquationComparisonView(
            maxWidth: 200,
            maxHeight: 200
        ).previewLayout(.fixed(width: 512, height: 315))
    }
}
