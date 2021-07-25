//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct EnergyProfileRateEquation: View {

    let k1: CGFloat?
    let k2: CGFloat?
    let ea: CGFloat?
    let t1: CGFloat?
    let t2: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let highlights: [EnergyProfileScreenElement]

    var body: some View {
        ScaledView(
            naturalWidth: EquationSize.width,
            naturalHeight: EquationSize.height,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledEnergyProfileRateEquation(
                k1: k1,
                k2: k2,
                ea: ea,
                t1: t1,
                t2: t2,
                highlights: highlights
            )
            .frame(width: maxWidth, height: maxHeight)
        }
    }
}

private struct UnscaledEnergyProfileRateEquation: View {

    let k1: CGFloat?
    let k2: CGFloat?
    let ea: CGFloat?
    let t1: CGFloat?
    let t2: CGFloat?
    let highlights: [EnergyProfileScreenElement]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    TermBG(highlight: highlightRateAndLinearAndRatio)
                        .padding(-padding)
                        .frame(width: 251, height: 248, alignment: .topLeading)
                    Spacer()
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: spacing) {
                VStack(alignment: .leading, spacing: spacing) {
                    rateEquation
                    linearRateEquation
                }
                .background(
                    TermBG(highlight: highlightRateAndLinear).padding(-padding)
                )
                VStack(alignment: .leading, spacing: spacing) {
                    rateRatio
                    blankRates
                }
                .background(
                    TermBG(highlight: highlightRatio).padding(-padding)
                )
            }
        }
    }

    private let spacing: CGFloat = 20
    private let padding: CGFloat = 10

    private var rateEquation: some View {
        EnergyProfileRateK1(
            highlightEa: highlightEa
        )
        .background(TermBG(highlight: highlightRate).padding(-padding))
    }

    private var linearRateEquation: some View {
        EnergyProfileRateLn(highlightEa: highlightEa)
    }

    private var rateRatio: some View {
        RateK1K2(highlightEa: highlightEa)
    }

    private var blankRates: some View {
        BlankRates(
            k1: k1?.str(decimals: 1),
            k2: k2?.str(decimals: 1),
            ea: eaString,
            t1: t1?.str(decimals: 0),
            t2: t2?.str(decimals: 0)
        )
    }

    private var eaString: String? {
        if let ea = ea {
            let mag = ea / 1000
            return "\(mag.str(decimals: 0))e3"
        }
        return nil
    }

    private var highlightRate: Bool {
        highlights.isEmpty || highlights.contains(.rateEquation)
    }

    private var highlightRateAndLinear: Bool {
        highlights.isEmpty || highlights.contains(.rateAndLinearRateEquation)
    }

    private var highlightRateAndLinearAndRatio: Bool {
        highlights.isEmpty || highlights.contains(.rateAndLinearAndRatioEquation)
    }

    private var highlightRatio: Bool {
        highlights.isEmpty || highlights.contains(.rateRatioEquation)
    }

    private var highlightEa: Bool {
        highlights.isEmpty || highlights.contains(.eaTerms)
    }

}

private struct EnergyProfileRateK1: View {

    let highlightEa: Bool

    var body: some View {
        HStack(spacing: 5) {
            FixedText("k")
            FixedText("=")
            FixedText("A")
            HStack(spacing: 1) {
                FixedText("e")
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("-E")
                        Text("a").baselineOffset(-3)
                    }
                    .background(TermBG(highlight: highlightEa))

                    Text("/RT")
                }
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(x: -3, y: -12)
                .frame(width: 70, height: 40)
            }
        }
        .font(.system(size: EquationSettings.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(1)
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Arrhenius equation. K = A, times E to the power of minus EA divide by RT"))
    }
}

private struct EnergyProfileRateLn: View {

    let highlightEa: Bool

    var body: some View {
        HStack(spacing: 5) {
            ln {
                FixedText("k")
            }
            FixedText("=")
            ln {
                FixedText("A")
            }
            FixedText("-")
            VStack(spacing: 0) {
                FixedText("Ea")
                    .background(TermBG(highlight: highlightEa))
                Rectangle()
                    .frame(width: 40, height: 2)
                FixedText("RT")
            }
        }
        .font(.system(size: EquationSettings.fontSize))
        .minimumScaleFactor(1)
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("ln k, equals ln a, minus EA divide by RT"))
    }

    private func ln<Content: View>(_ value: () -> Content) -> some View {
        HStack(spacing: 0) {
            FixedText("ln")
            FixedText("(")
            value()
            FixedText(")")
        }
    }
}

private struct RateK1K2: View {

    let highlightEa: Bool

    var body: some View {
        HStack(spacing: 5) {
            HStack(spacing: 0) {
                FixedText("ln")
                LargeOpenParen()
                VStack(spacing: 0) {
                    FixedText("k1")
                    Rectangle()
                        .frame(width: 30, height: 2)
                    FixedText("k2")
                }
                LargeCloseParen()
            }
            FixedText("=")
            VStack(spacing: 1) {
                FixedText("Ea")
                    .background(TermBG(highlight: highlightEa))
                Rectangle()
                    .frame(width: 35, height: 2)
                FixedText("R")
            }
            HStack(spacing: 2) {
                LargeOpenParen()
                VStack(spacing: 5) {
                    HStack(spacing: 5) {
                        T_1(uppercase: true)
                        FixedText("-")
                        T_2(uppercase: true)
                    }
                    Rectangle()
                        .frame(width: 80, height: 2)
                    HStack(spacing: 5) {
                        T_1(uppercase: true)
                        T_2(uppercase: true)
                    }
                }
                LargeCloseParen()
            }
        }
        .font(.system(size: EquationSettings.fontSize))
        .minimumScaleFactor(1)
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("ln(k1 divide by k2), equals EA divide by R, times T1 minus T2, divide by T1 times T2"))
    }
}

private struct BlankRates: View {

    let k1: String?
    let k2: String?
    let ea: String?
    let t1: String?
    let t2: String?

    var body: some View {
        HStack(spacing: 5) {
            HStack(spacing: 0) {
                FixedText("ln")
                    .minimumScaleFactor(1)
                    .accessibility(sortPriority: 5)

                LargeOpenParen()
                    .accessibility(sortPriority: 4.9)

                VStack(spacing: 1) {
                    Placeholder(value: k1)
                        .accessibility(label: Text("k1"))
                        .accessibility(sortPriority: 4.8)

                    Rectangle()
                        .frame(width: 55, height: 2)
                        .accessibility(label: Text("divide by"))
                        .accessibility(sortPriority: 4.7)

                    Placeholder(value: k2)
                        .accessibility(label: Text("k2"))
                        .accessibility(sortPriority: 4.6)
                }
                LargeCloseParen()
                    .accessibility(sortPriority: 4.5)
            }
            FixedText("=")
                .accessibility(sortPriority: 4.4)

            VStack(spacing: 1) {
                Placeholder(value: ea)
                    .accessibility(label: Text("EA"))
                    .accessibility(sortPriority: 4.3)

                Rectangle()
                    .frame(width: 55, height: 2)
                    .accessibility(label: Text("divide by"))
                    .accessibility(sortPriority: 4.3)

                FixedText("8.31")
                    .frame(height: EquationSettings.boxHeight)
                    .accessibility(label: Text("R"))
                    .accessibility(value: Text("8.31"))
                    .accessibility(sortPriority: 4.2)
            }
            HStack(spacing: 0) {
                LargeOpenParen()
                    .accessibility(sortPriority: 4.1)
                VStack(spacing: 1) {
                    HStack(spacing: 2) {
                        Placeholder(value: t1)
                            .accessibility(label: Text("T1"))
                            .accessibility(sortPriority: 4)

                        FixedText("-")
                            .accessibility(label: Text("minus"))
                            .accessibility(sortPriority: 3.9)

                        Placeholder(value: t2)
                            .accessibility(label: Text("T2"))
                            .accessibility(sortPriority: 3.8)
                    }
                    Rectangle()
                        .frame(width: 140, height: 2)
                        .accessibility(label: Text("divide by"))
                        .accessibility(sortPriority: 3.7)

                    HStack(spacing: 2) {
                        Placeholder(value: t1)
                            .accessibility(label: Text("t1"))
                            .accessibility(sortPriority: 3.6)
                        FixedText("x")
                            .accessibility(label: Text("multiplied by"))
                            .accessibility(sortPriority: 3.5)
                        Placeholder(value: t2)
                            .accessibility(label: Text("t2"))
                            .accessibility(sortPriority: 3.4)
                    }
                }
                LargeCloseParen()
            }
        }
        .font(.system(size: EquationSettings.fontSize))
        .accessibilityElement(children: .contain)
    }
}

private struct LargeOpenParen: View {
    var body: some View {
        FixedText("(")
            .scaleEffect(y: 2.5)
            .minimumScaleFactor(1)
    }
}

private struct LargeCloseParen: View {
    var body: some View {
        FixedText(")")
            .scaleEffect(y: 2.5)
            .minimumScaleFactor(1)
    }
}

private struct EquationSize {
    static let width: CGFloat = 425
    static let height: CGFloat = 388
}

private struct TermBG: View {

    let highlight: Bool

    var body: some View {
        Color.white
            .opacity(highlight ? 1 : 0)
    }
}

struct EnergyProfileRate_Previews: PreviewProvider {
    static var previews: some View {
        UnscaledEnergyProfileRateEquation(
            k1: 10.2,
            k2: 11.5,
            ea: 17000,
            t1: 400,
            t2: 600,
            highlights: [.rateRatioEquation]
        )
        .border(Color.red)
        .background(Color.white.colorMultiply(Styling.inactiveScreenElement))
        .previewLayout(
            .fixed(
                width: EquationSize.width,
                height: EquationSize.height
            )
        )
    }
}
