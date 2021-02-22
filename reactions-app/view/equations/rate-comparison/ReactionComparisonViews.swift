//
// Reactions App
//

import SwiftUI
import ReactionsCore

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

private struct UnscaledZeroOrderEquation: View {

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
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Concentration of A at T, equals A0 minus K times T"))
    }

    private var aFilled: some View {
        HStack(spacing: 4) {
            VaryingText(time: time, equation: concentration, label: "concentration of A at T")
            FixedText("=")
            FixedText(a0)
                .accessibility(label: Text("A0"))
                .accessibility(value: Text(a0))
            FixedText("-")
                .accessibility(label: Text("minus"))
            FixedText(k)
                .accessibility(label: Text("k"))
                .accessibility(value: Text(k))

            VaryingText(
                time: time,
                equation: IdentityEquation(),
                withParens: true,
                widthFactor: 0.8,
                decimals: 1,
                label: "time"
            )
        }
    }
}

private struct UnscaledFirstOrderEquation: View {

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
            spacerWidth: 144
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
            FixedText("-kt")
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(y: -12)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Concentration of A at T, equals A0, times E to the power of minus KT"))
    }

    private var aFilled: some View {
        HStack(spacing: 4) {
            VaryingText(time: time, equation: concentration, label: "Concentration of A at T")
            FixedText("=")
            FixedText(a0)
                .accessibility(label: Text("A0"))
                .accessibility(value: Text(a0))

            FixedText("e")

            HStack(spacing: 0) {
                FixedText("-")
                    .accessibility(label: Text("minus"))

                FixedText(k)
                    .accessibility(label: Text("k"))
                    .accessibility(value: Text(k))

                VaryingText(
                    time: time,
                    equation: IdentityEquation(),
                    withParens: true,
                    widthFactor: 0.55,
                    decimals: 1,
                    label: "time"
                )
            }
            .font(.system(size: EquationSettings.subscriptFontSize))
            .offset(y: -10)
        }
    }
}

private struct UnscaledSecondOrderEquation: View {

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
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Concentration of A at T, equals A0 divide by, A0 times KT, plus 1"))
    }

    private var aFilled: some View {
        HStack(spacing: 10) {
            HStack(spacing: 2) {
                VaryingText(time: time, equation: concentration, label: "Concentration of A at T")
                FixedText("=")
                FixedText(a0)
                    .accessibility(label: Text("A0"))
                    .accessibility(value: Text(a0))

                FixedText("/")
                    .accessibility(label: Text("divide by"))

                HStack(spacing: 1) {
                    FixedText("(")
                    FixedText(a0)
                        .accessibility(label: Text("A0"))
                        .accessibility(value: Text(a0))

                    HStack(spacing: 0) {
                        FixedText("(")
                        FixedText(k)
                            .accessibility(label: Text("k"))
                            .accessibility(value: Text(k))
                        FixedText(")")
                    }

                    VaryingText(
                        time: time,
                        equation: IdentityEquation(),
                        withParens: true,
                        widthFactor: 0.65,
                        decimals: 1,
                        label: "time"
                    )
                    FixedText("+")
                    FixedText("1")
                    FixedText(")")
                }
            }

        }
    }
}

private struct GeneralEquation<Content: View>: View {

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
                .accessibility(sortPriority: 1)

            HStack {
                lhs()
                    .accessibility(sortPriority: 0.5)

                Spacer()
                    .frame(width: spacerWidth)
                VStack(alignment: .leading, spacing: 5) {
                    filledRate
                    blankRate
                }
            }
        }
        .font(.system(size: EquationSettings.fontSize))
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
        .accessibilityElement(children: .ignore)
        .accessibility(
            label: Text(
                "Rate equals k, times concentration of A to the power of \(order)"
            )
        )

    }

    private var blankRate: some View {
        HStack(spacing: 4) {
            VaryingText(
                time: time,
                equation: rate,
                widthFactor: 1.2,
                decimals: 3,
                label: "rate"
            )

            FixedText("=")
            FixedText(k)
                .accessibility(label: Text("k"))
                .accessibility(value: Text(k))

            VaryingText(
                time: time,
                equation: concentration,
                withParens: true,
                label: "concentration of A"
            )

            FixedText("\(order)")
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(y: -10)
                .accessibility(label: Text("to the power of \(order)"))
        }
    }
}

private struct VaryingText: View {

    let time: CGFloat?
    let equation: Equation
    let alignment: Alignment
    let withParens: Bool
    let widthFactor: CGFloat
    let decimals: Int
    let label: String

    init(
        time: CGFloat?,
        equation: Equation,
        alignment: Alignment = .center,
        withParens: Bool = false,
        widthFactor: CGFloat = 1,
        decimals: Int = 2,
        label: String
    ) {
        self.time = time
        self.equation = equation
        self.alignment = alignment
        self.withParens = withParens
        self.widthFactor = widthFactor
        self.decimals = decimals
        self.label = label
    }

    var body: some View {
        HStack(spacing: 0) {
            if withParens {
                FixedText("(")
            }
            Group {
                if time == nil {
                    FixedText(equation.getY(at: 0).str(decimals: decimals))
                        .accessibility(label: Text(label))
                        .accessibility(value: Text(equation.getY(at: 0).str(decimals: decimals)))
                }
                if time != nil {
                    AnimatingNumber(
                        x: time!,
                        equation: equation,
                        formatter: { d in d.str(decimals: decimals) },
                        alignment: .leading
                    )
                    .accessibility(label: Text(label))
                }

            }
            .frame(width: EquationSettings.boxWidth * widthFactor, alignment: alignment)
            .foregroundColor(.orangeAccent)
            .minimumScaleFactor(0.5)
            if withParens {
                FixedText(")")
            }

        }
    }
}

private struct EquationSizes {
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
