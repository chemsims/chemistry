//
// Reactions App
//
  

import SwiftUI

struct ReactionComparisonZeroOrderEquation: View {

    let time: CGFloat?
    let concentration: Equation
    let rate: Equation
    let k: String

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
                time: time,
                concentration: concentration,
                rate: rate,
                k: k,
                a0: a0
            ).frame(width: maxWidth, height: maxHeight)
        }
    }
}

struct ReactionComparisonFirstOrderEquation: View {
    let time: CGFloat?
    let concentration: Equation
    let rate: Equation
    let k: String
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
                time: time,
                concentration: concentration,
                rate: rate,
                k: k,
                a0: a0
            ).frame(width: maxWidth, height: maxHeight)
        }
    }
}
struct ReactionComparisonSecondOrderEquation: View {

    let time: CGFloat?
    let concentration: Equation
    let rate: Equation
    let k: String
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
                time: time,
                concentration: concentration,
                rate: rate,
                k: k,
                a0: a0
            ).frame(width: maxWidth, height: maxHeight)
        }
    }
}


fileprivate struct UnscaledZeroOrderEquation: View {

    let time: CGFloat?
    let concentration: Equation
    let rate: Equation
    let k: String
    let a0: String

    var body: some View {
        GeneralEquation(
            order: 0,
            time: time,
            concentration: concentration,
            rate: rate,
            k: k,
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
            VaryingText(time: time, equation: concentration)
            FixedText("=")
            FixedText(a0)
            FixedText("-")
            FixedText(k)
            VaryingText(
                time: time,
                equation: IdentityEquation(),
                withParens: true,
                widthFactor: 0.8,
                decimals: 1
            )
        }
    }
}

fileprivate struct UnscaledFirstOrderEquation: View {

    let time: CGFloat?
    let concentration: Equation
    let rate: Equation
    let k: String
    let a0: String

    var body: some View {
        GeneralEquation(
            order: 1,
            time: time,
            concentration: concentration,
            rate: rate,
            k: k,
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
            FixedText("/")
            FixedText("e")
            FixedText("kt")
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(y: -12)
        }
    }

    private var aFilled: some View {
        HStack(spacing: 4) {
            VaryingText(time: time, equation: concentration)
            FixedText("=")
            FixedText(a0)
            FixedText("/")
            FixedText("e")
            HStack(spacing: 0) {
                FixedText(k)
                VaryingText(
                    time: time,
                    equation: IdentityEquation(),
                    withParens: true,
                    widthFactor: 0.55,
                    decimals: 1
                )
            }
            .font(.system(size: EquationSettings.subscriptFontSize))
            .offset(y: -10)
        }
    }
}

fileprivate struct UnscaledSecondOrderEquation: View {

    let time: CGFloat?
    let concentration: Equation
    let rate: Equation
    let k: String
    let a0: String

    var body: some View {
        GeneralEquation(
            order: 2,
            time: time,
            concentration: concentration,
            rate: rate,
            k: k,
            spacerWidth: 20
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
                    FixedText("(")
                    A_0()
                    FixedText("kt")
                    FixedText("+")
                    FixedText("1")
                    FixedText(")")
                }
            }
        }
    }

    private var aFilled: some View {
        HStack(spacing: 10) {
            HStack(spacing: 2) {
                VaryingText(time: time, equation: concentration)
                FixedText("=")
                FixedText(a0)
                FixedText("/")
                HStack(spacing: 1) {
                    FixedText("(")
                    FixedText(a0)
                    FixedText("(\(k))")
                    VaryingText(
                        time: time,
                        equation: IdentityEquation(),
                        withParens: true,
                        widthFactor: 0.65,
                        decimals: 1
                    )
                    FixedText("+")
                    FixedText("1")
                    FixedText(")")
                }
            }

        }
    }
}

fileprivate struct GeneralEquation<Content: View>: View {

    let order: Int
    let time: CGFloat?
    let concentration: Equation
    let rate: Equation
    let k: String
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
            VaryingText(time: time, equation: rate, widthFactor: 1.2)
            FixedText("=")
            FixedText(k)
            VaryingText(time: time, equation: concentration, withParens: true)
            FixedText("\(order)")
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(y: -10)
        }
    }
}

fileprivate struct VaryingText: View {

    let time: CGFloat?
    let equation: Equation
    let alignment: Alignment
    let withParens: Bool
    let widthFactor: CGFloat
    let decimals: Int

    init(
        time: CGFloat?,
        equation: Equation,
        alignment: Alignment = .center,
        withParens: Bool = false,
        widthFactor: CGFloat = 1,
        decimals: Int = 2
    ) {
        self.time = time
        self.equation = equation
        self.alignment = alignment
        self.withParens = withParens
        self.widthFactor = widthFactor
        self.decimals = decimals
    }

    var body: some View {
        HStack(spacing: 0) {
            if (withParens) {
                FixedText("(")
            }
            Group {
                if (time == nil) {
                    FixedText(equation.getY(at: 0).str(decimals: decimals))
                }
                if (time != nil) {
                    AnimatingNumber(
                        x: time!,
                        equation: equation,
                        formatter: { d in d.str(decimals: decimals) }
                    )
                }

            }
            .frame(width: EquationSettings.boxWidth * widthFactor, alignment: alignment)
            .foregroundColor(.orangeAccent)
            .minimumScaleFactor(0.5)
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
                time: 1.2,
                concentration: ConstantEquation(value: 0.87),
                rate: ConstantEquation(value: 0.02),
                k: "0.06",
                a0: "1.0"
            )
            .frame(width: width, height: height)
            .border(Color.red)

            UnscaledFirstOrderEquation(
                time: 1.2,
                concentration: ConstantEquation(value: 0.87),
                rate: ConstantEquation(value: 0.02),
                k: "0.06",
                a0: "1.0"
            )
            .frame(width: width, height: height)
            .border(Color.red)

            UnscaledSecondOrderEquation(
                time: 1.2,
                concentration: ConstantEquation(value: 0.87),
                rate: ConstantEquation(value: 0.02),
                k: "0.06",
                a0: "1.0"
            )
            .frame(width: width, height: height)
            .border(Color.red)

        }.previewLayout(.fixed(width: width, height: (3 * height) + 100))
    }
}
