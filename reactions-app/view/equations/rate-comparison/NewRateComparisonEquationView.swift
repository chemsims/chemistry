//
// Reactions App
//
  

import SwiftUI

struct ReactionComparisonZeroOrderEquation: View {
    let rate: String
    let k: String
    let concentration: String
    let time: String
    let a0: String

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        ScaledView(
            naturalWidth: EquationSizes.width,
            naturalHeight: EquationSizes.height,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledZeroOrderEquation(
                rate: rate,
                k: k,
                concentration: concentration,
                time: time,
                a0: a0
            ).frame(width: maxWidth, height: maxHeight)
        }
    }
}

struct ReactionComparisonFirstOrderEquation: View {
    let rate: String
    let k: String
    let concentration: String
    let time: String
    let a0: String

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        ScaledView(
            naturalWidth: EquationSizes.width,
            naturalHeight: EquationSizes.height,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledFirstOrderEquation(
                rate: rate,
                k: k,
                concentration: concentration,
                time: time,
                a0: a0
            ).frame(width: maxWidth, height: maxHeight)
        }
    }
}
struct ReactionComparisonSecondOrderEquation: View {
    let rate: String
    let k: String
    let concentration: String
    let time: String
    let a0: String

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        ScaledView(
            naturalWidth: EquationSizes.width,
            naturalHeight: EquationSizes.height,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledSecondOrderEquation(
                rate: rate,
                k: k,
                concentration: concentration,
                time: time,
                a0: a0
            ).frame(width: maxWidth, height: maxHeight)
        }
    }
}


fileprivate struct UnscaledZeroOrderEquation: View {

    let rate: String
    let k: String
    let concentration: String
    let time: String
    let a0: String

    var body: some View {
        GeneralEquation(
            order: 0,
            rate: rate,
            k: k,
            concentration: concentration,
            spacerWidth: 113
        ) {
            HStack(spacing: 4) {
                VStack(alignment: .leading, spacing: 5) {
                    aEquation
                    aFilled
                }
            }
        }
    }

    private var aEquation: some View {
        HStack(spacing: 4) {
            A_t()
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")
            A_0()
            FixedText("-")
            FixedText("kt")
        }
    }

    private var aFilled: some View {
        HStack(spacing: 4) {
            VaryingText(concentration)
            FixedText("=")
            FixedText(a0)
            FixedText("-")
            FixedText(k)
            VaryingText(time, withParens: true, widthFactor: 0.8)
        }
    }
}

fileprivate struct UnscaledFirstOrderEquation: View {

    let rate: String
    let k: String
    let concentration: String
    let time: String
    let a0: String

    var body: some View {
        GeneralEquation(
            order: 1,
            rate: rate,
            k: k,
            concentration: concentration,
            spacerWidth: 145
        ) {
            VStack(alignment: .leading, spacing: 5) {
                aEquation
                aFilled
            }
        }
    }

    private var aEquation: some View {
        HStack(spacing: 4) {
            A_t()
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")
            A_0()
            FixedText("e")
            FixedText("kt")
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(y: -12)
        }
    }

    private var aFilled: some View {
        HStack(spacing: 4) {
            VaryingText(concentration)
            FixedText("=")
            FixedText(a0)
            FixedText("/")
            FixedText("e")
            HStack(spacing: 0) {
                FixedText(k)
                VaryingText("\(time)", withParens: true, widthFactor: 0.55)
            }
            .font(.system(size: EquationSettings.subscriptFontSize))
            .offset(y: -10)
        }
    }
}

fileprivate struct UnscaledSecondOrderEquation: View {

    let rate: String
    let k: String
    let concentration: String
    let time: String
    let a0: String

    var body: some View {
        GeneralEquation(
            order: 2,
            rate: rate,
            k: k,
            concentration: concentration,
            spacerWidth: 23
        ) {
            VStack(alignment: .leading, spacing: 5) {
                aEquation
                aFilled
            }
        }
    }

    private var aEquation: some View {
        HStack(spacing: 10) {
            HStack(spacing: 3) {
                A_t()
                    .frame(width: EquationSettings.boxWidth)
                FixedText("=")
                A_0()
                FixedText("/")
                HStack(spacing: 1) {
                    A_0()
                    FixedText("kt")
                }
            }
            FixedText("+")
            FixedText("1")
        }
    }

    private var aFilled: some View {
        HStack(spacing: 10) {
            HStack(spacing: 3) {
                VaryingText(concentration)
                FixedText("=")
                FixedText(a0)
                FixedText("/")
                HStack(spacing: 1) {
                    FixedText(a0)
                    FixedText("(\(k))")
                    VaryingText(time, withParens: true, widthFactor: 0.65)
                }
            }
            FixedText("+")
            FixedText("1")
        }
    }
}

fileprivate struct GeneralEquation<Content: View>: View {

    let order: Int
    let rate: String
    let k: String
    let concentration: String
    let spacerWidth: CGFloat
    let lhs: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            FixedText("Order: \(order)")
                .font(.system(size: EquationSettings.fontSize, weight: .bold))
            HStack {
                lhs()
                Spacer()
                    .frame(width: spacerWidth)
                VStack(alignment: .leading, spacing: 5) {
                    filledRate
                    blankRate
                }
            }
        }.font(.system(size: EquationSettings.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(1)
    }

    private var filledRate: some View {
        HStack(spacing: 4) {
            FixedText("Rate")
                .frame(width: EquationSettings.boxWidth * 1.2)
            FixedText("=")
            FixedText("k")
            FixedText("[A]")
            FixedText("\(order)")
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(y: -10)
        }
    }

    private var blankRate: some View {
        HStack(spacing: 4) {
            VaryingText(rate, widthFactor: 1.2)
            FixedText("=")
            FixedText(k)
            VaryingText(concentration, withParens: true)
            FixedText("\(order)")
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(y: -10)
        }
    }
}

fileprivate struct VaryingText: View {

    let value: String
    let alignment: Alignment
    let withParens: Bool
    let widthFactor: CGFloat

    init(
        _ value: String,
        alignment: Alignment = .center,
        withParens: Bool = false,
        widthFactor: CGFloat = 1
    ) {
        self.value = value
        self.alignment = alignment
        self.withParens = withParens
        self.widthFactor = widthFactor
    }

    var body: some View {
        HStack(spacing: 0) {
            if (withParens) {
                FixedText("(")
            }
            FixedText(value)
                .frame(width: EquationSettings.boxWidth * widthFactor, alignment: alignment)
                .foregroundColor(.orangeAccent)
            if (withParens) {
                FixedText(")")
            }

        }
    }
}

fileprivate struct EquationSizes {
    static let width: CGFloat = 700
    static let height: CGFloat = 120
}


struct NewRateComparisonEquationView_Previews: PreviewProvider {

    static let width: CGFloat = EquationSizes.width
    static let height: CGFloat = EquationSizes.height

    static var previews: some View {
        VStack(spacing: 50) {
            UnscaledZeroOrderEquation(
                rate: "0.02",
                k: "0.06",
                concentration: "0.87",
                time: "1.2",
                a0: "1.0"
            )
            .frame(width: width, height: height)
            .border(Color.red)

            UnscaledFirstOrderEquation(
                rate: "0.02",
                k: "0.06",
                concentration: "0.87",
                time: "1.2",
                a0: "1.0"
            )
            .frame(width: width, height: height)
            .border(Color.red)

            UnscaledSecondOrderEquation(
                rate: "0.02",
                k: "0.06",
                concentration: "0.87",
                time: "1.2",
                a0: "1.0"
            )
            .frame(width: width, height: height)
            .border(Color.red)

        }.previewLayout(.fixed(width: width, height: (3 * height) + 100))
    }
}
