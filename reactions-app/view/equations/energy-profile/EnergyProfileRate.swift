//
// Reactions App
//


import SwiftUI

struct EnergyProfileRate: View {

    let k1: CGFloat?
    let k2: CGFloat?
    let ea: CGFloat?
    let t1: CGFloat?
    let t2: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    private let naturalWidth: CGFloat = 413
    private let naturalHeight: CGFloat = 355

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
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
        .frame(width: maxWidth, height: maxHeight)
        .minimumScaleFactor(0.5)
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
            Text("k")
                .frame(width: 18)
            Equals()
            Text("A")
                .frame(width: 21)
            HStack(spacing: 1) {
                Text("e")
                    .frame(width: 18)
                Group {
                    Text("-E") +
                        Text("a").baselineOffset(-3) + Text("/RT")
                }
                .font(.system(size: RateEquationSizes.subscriptFontSize))
                .offset(x: -3, y: -12)
                .frame(width: 70, height: 40)
            }
        }
        .font(.system(size: RateEquationSizes.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(1)
    }
}

fileprivate struct EnergyProfileRateLn: View {
    var body: some View {
        HStack(spacing: 5) {
            ln {
                Text("k")
                    .frame(width: 18)
            }
            Equals()
            ln {
                Text("A")
                    .frame(width: 21)
            }
            Text("+")
                .frame(width: 20)
            VStack(spacing: 0) {
                Text("Ea")
                    .frame(width: 36)
                Rectangle()
                    .frame(width: 40, height: 2)
                Text("RT")
                    .frame(width: 40)
            }
        }
        .font(.system(size: RateEquationSizes.fontSize))
        .minimumScaleFactor(1)
    }

    private func ln<Content: View>(_ value: () -> Content) -> some View {
        HStack(spacing: 0) {
            Text("ln")
                .frame(width: 25)
            Text("(")
                .frame(width: 12)
            value()
            Text(")")
                .frame(width: 12)
        }
    }
}

fileprivate struct RateK1K2: View {
    var body: some View {
        HStack(spacing: 5) {
            HStack(spacing: 0) {
                Text("ln")
                    .frame(width: 25)
                Text("(")
                    .scaleEffect(y: 2.5)
                    .frame(width: 12)
                VStack(spacing: 0) {
                    Text("k1")
                        .frame(width: 30, height: 35)
                    Rectangle()
                        .frame(width: 30, height: 2)
                    Text("k2")
                        .frame(width: 34)
                }
                Text(")")
                    .scaleEffect(y: 2.5)
                    .frame(width: 12)
            }
            Equals()
            VStack(spacing: 1) {
                Text("Ea")
                    .frame(width: 36)
                Rectangle()
                    .frame(width: 35, height: 2)
                Text("R")
                    .frame(width: 23)
            }
            HStack(spacing: 0) {
                Text("(")
                    .scaleEffect(y: 2.5)
                    .frame(width: 12)
                VStack(spacing: 1) {
                    Text("T1 - T2")
                        .frame(width: 100)
                    Rectangle()
                        .frame(width: 80, height: 2)
                    Text("T1T2")
                        .frame(width: 75)
                }
                Text(")")
                    .scaleEffect(y: 2.5)
                    .frame(width: 12)
            }
        }
        .font(.system(size: RateEquationSizes.fontSize))
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
                Text("ln")
                    .frame(width: 27)
                LargeOpenParen()
                VStack(spacing: 1) {
                    Placeholder(value: k1)
                        .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                    Rectangle()
                        .frame(width: 55, height: 2)
                    Placeholder(value: k2)
                        .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                }
                LargeCloseParen()
            }
            Equals()
            VStack(spacing: 1) {
                Placeholder(value: ea)
                    .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                Rectangle()
                    .frame(width: 55, height: 2)
                Text("8.31")
                    .frame(width: 60, height: Settings.boxHeight)
            }
            HStack(spacing: 0) {
                LargeOpenParen()
                VStack(spacing: 1) {
                    HStack(spacing: 2) {
                        Placeholder(value: t1)
                            .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                        Minus()
                        Placeholder(value: t2)
                            .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                    }
                    Rectangle()
                        .frame(width: 140, height: 2)
                    HStack(spacing: 2) {
                        Placeholder(value: t1)
                            .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                        Text("x")
                            .frame(width: 20)
                        Placeholder(value: t2)
                            .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                    }
                }
                LargeCloseParen()
            }
        }.font(.system(size: RateEquationSizes.fontSize))
    }
}

fileprivate struct EqSettings {
    static let largeBoxWidth: CGFloat = 100
}

fileprivate struct LargeOpenParen: View {
    var body: some View {
        Text("(")
            .scaleEffect(y: 2.5)
            .frame(width: 12)
    }
}

fileprivate struct LargeCloseParen: View {
    var body: some View {
        Text(")")
            .scaleEffect(y: 2.5)
            .frame(width: 12)
    }
}

struct EnergyProfileRate_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileRate(
            k1: 10.2,
            k2: 11.5,
            ea: 17000,
            t1: 400,
            t2: 600,
            maxWidth: 400,
            maxHeight: 400

        )
            .previewLayout(.fixed(width: 600, height: 500))
    }
}
