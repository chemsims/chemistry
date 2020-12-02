//
// Reactions App
//


import SwiftUI

struct EnergyProfileRateEquation: View {

    let k1: CGFloat?
    let k2: CGFloat?
    let ea: CGFloat?
    let t1: CGFloat?
    let t2: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    private let naturalWidth: CGFloat = 400
    private let naturalHeight: CGFloat = 355

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledEnergyProfileRateEquation(
                k1: k1,
                k2: k2,
                ea: ea,
                t1: t1,
                t2: t2
            )
            .frame(width: maxWidth, height: maxHeight)
        }
    }
}

fileprivate struct UnscaledEnergyProfileRateEquation: View {

    let k1: CGFloat?
    let k2: CGFloat?
    let ea: CGFloat?
    let t1: CGFloat?
    let t2: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            EnergyProfileRateK1()
            EnergyProfileRateLn()
            RateK1K2()
            BlankRates(
                k1: k1?.str(decimals: 1),
                k2: k2?.str(decimals: 1),
                ea: eaString,
                t1: t1?.str(decimals: 0),
                t2: t2?.str(decimals: 0)
            )
        }
    }

    private var eaString: String? {
        if let ea = ea {
            let mag = ea / 1000
            return "\(mag.str(decimals: 0))e3"
        }
        return nil
    }
}

fileprivate struct EnergyProfileRateK1: View {
    var body: some View {
        HStack(spacing: 5) {
            FixedText("k")
            FixedText("=")
            FixedText("A")
            HStack(spacing: 1) {
                FixedText("e")
                Group {
                    Text("-E") +
                        Text("a").baselineOffset(-3) + Text("/RT")
                }
                .font(.system(size: EquationSettings.subscriptFontSize))
                .offset(x: -3, y: -12)
                .frame(width: 70, height: 40)
            }
        }
        .font(.system(size: EquationSettings.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(1)
    }
}

fileprivate struct EnergyProfileRateLn: View {
    var body: some View {
        HStack(spacing: 5) {
            ln {
                FixedText("k")
            }
            FixedText("=")
            ln {
                FixedText("A")
            }
            FixedText("+")
            VStack(spacing: 0) {
                FixedText("Ea")
                Rectangle()
                    .frame(width: 40, height: 2)
                FixedText("RT")
            }
        }
        .font(.system(size: EquationSettings.fontSize))
        .minimumScaleFactor(1)
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

fileprivate struct RateK1K2: View {
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
                Rectangle()
                    .frame(width: 35, height: 2)
                FixedText("R")
            }
            HStack(spacing: 0) {
                LargeOpenParen()
                VStack(spacing: 1) {
                    FixedText("T1 - T2")
                    Rectangle()
                        .frame(width: 80, height: 2)
                    FixedText("T1T2")
                }
                LargeCloseParen()
            }
        }
        .font(.system(size: EquationSettings.fontSize))
        .minimumScaleFactor(1)
    }
}

fileprivate struct BlankRates: View {

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
                LargeOpenParen()
                VStack(spacing: 1) {
                    Placeholder(value: k1)
                        .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                        .minimumScaleFactor(0.5)
                    Rectangle()
                        .frame(width: 55, height: 2)
                    Placeholder(value: k2)
                        .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                        .minimumScaleFactor(0.5)
                }
                LargeCloseParen()
            }
            FixedText("=")
            VStack(spacing: 1) {
                Placeholder(value: ea)
                    .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                    .minimumScaleFactor(0.5)
                Rectangle()
                    .frame(width: 55, height: 2)
                FixedText("8.31")
                    .frame(height: EquationSettings.boxHeight)
            }
            HStack(spacing: 0) {
                LargeOpenParen()
                VStack(spacing: 1) {
                    HStack(spacing: 2) {
                        Placeholder(value: t1)
                            .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                            .minimumScaleFactor(0.5)
                        FixedText("-")
                        Placeholder(value: t2)
                            .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                            .minimumScaleFactor(0.5)
                    }
                    Rectangle()
                        .frame(width: 140, height: 2)
                    HStack(spacing: 2) {
                        Placeholder(value: t1)
                            .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                            .minimumScaleFactor(0.5)
                        FixedText("x")
                        Placeholder(value: t2)
                            .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                            .minimumScaleFactor(0.5)
                    }
                }
                LargeCloseParen()
            }
        }.font(.system(size: EquationSettings.fontSize))
    }
}

fileprivate struct EqSettings {
    static let largeBoxWidth: CGFloat = 100
}

fileprivate struct LargeOpenParen: View {
    var body: some View {
        FixedText("(")
            .scaleEffect(y: 2.5)
            .minimumScaleFactor(1)
    }
}

fileprivate struct LargeCloseParen: View {
    var body: some View {
        FixedText(")")
            .scaleEffect(y: 2.5)
            .minimumScaleFactor(1)
    }
}

struct EnergyProfileRate_Previews: PreviewProvider {
    static var previews: some View {
        UnscaledEnergyProfileRateEquation(
            k1: 10.2,
            k2: 11.5,
            ea: 17000,
            t1: 400,
            t2: 600
        )
        .border(Color.red)
        .previewLayout(.fixed(width: 400, height: 355))
    }
}
