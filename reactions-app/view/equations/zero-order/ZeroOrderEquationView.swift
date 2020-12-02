//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderEquationView: View {

    let emphasiseFilledTerms: Bool
    let initialConcentration: CGFloat
    let initialTime: CGFloat
    let rate: CGFloat?
    let deltaC: CGFloat?
    let deltaT: CGFloat?
    let c2: CGFloat?
    let t2: CGFloat?
    let halfTime: CGFloat?

    let maxWidth: CGFloat
    let maxHeight: CGFloat
    
    private let naturalWidth: CGFloat = 540
    private let naturalHeight: CGFloat = 265

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledZeroOrderEquationView(
                emphasiseFilledTerms: emphasiseFilledTerms,
                initialConcentration: initialConcentration,
                initialTime: initialTime,
                rate: rate,
                deltaC: deltaC,
                deltaT: deltaT,
                c2: c2,
                t2: t2,
                halfTime: halfTime
            )
            .frame(width: maxWidth, height: maxHeight)
        }
    }
}

fileprivate struct UnscaledZeroOrderEquationView: View {

    let emphasiseFilledTerms: Bool
    let initialConcentration: CGFloat
    let initialTime: CGFloat
    let rate: CGFloat?
    let deltaC: CGFloat?
    let deltaT: CGFloat?
    let c2: CGFloat?
    let t2: CGFloat?
    let halfTime: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                FilledRateView()
                EmptyRateView(
                    deltaC: deltaC?.str(decimals: 2),
                    deltaT: deltaT?.str(decimals: 2),
                    c1: initialConcentration.str(decimals: 2),
                    c2: c2?.str(decimals: 2),
                    t1: initialTime.str(decimals: 2),
                    t2: t2?.str(decimals: 2),
                    rate: rate?.str(decimals: 2)
                )
            }

            HStack(spacing: 22) {
                FilledHalftime()
                BlankHalftime(
                    c1: initialConcentration.str(decimals: 2),
                    halftime: halfTime?.str(decimals: 2),
                    rate: rate?.str(decimals: 2)
                )
            }
        }
        .font(.system(size: EquationSettings.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
}

fileprivate struct FilledRateView: View {
    var body: some View {
        HStack(spacing: EquationSettings.hSpacing) {
            Rate()
            Text("k")
                .frame(width: EquationSettings.boxWidth)
            Text("=")
                .fixedSize()
            fraction1
            FixedText("=")
            fraction2
        }
    }

    private var fraction1: some View {
        HStack(spacing: 0) {
            FixedText("-")
            VStack(spacing: 1) {
                HStack(spacing: 0) {
                    Text("Δc")
                        .frame(width: EquationSettings.boxWidth)
                }
                Rectangle()
                    .frame(width: 50, height: 2)
                Text("Δt")
                    .frame(width: EquationSettings.boxWidth)
            }
        }
    }

    private var fraction2: some View {
        HStack(spacing: 0) {
            FixedText("-")
            VStack(spacing: 5) {
                HStack(spacing: 1) {
                    C_2()
                        .frame(width: EquationSettings.boxWidth)
                    FixedText("-")
                    C_1()
                        .frame(width:  EquationSettings.boxWidth)
                }
                Rectangle()
                    .frame(width: 155, height: 2)
                HStack(spacing: 1) {
                    T_2()
                        .frame(width:  EquationSettings.boxWidth)
                    FixedText("-")
                    T_1()
                        .frame(width:  EquationSettings.boxWidth)
                }
            }
        }
    }
}

fileprivate struct EmptyRateView: View {

    let deltaC: String?
    let deltaT: String?
    let c1: String?
    let c2: String?
    let t1: String?
    let t2: String?
    let rate: String?

    var body: some View {
        HStack(spacing: EquationSettings.hSpacing) {
            Rate()
            Placeholder(value: rate)
                .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                .minimumScaleFactor(0.5)
            Text("=")
                .fixedSize()
            fraction1
            FixedText("=")
            fraction2
        }
        .font(.system(size: EquationSettings.fontSize))
        .lineLimit(1)
    }

    private var fraction1: some View {
        HStack(spacing: 0) {
            FixedText("-")
            VStack(spacing: 1) {
                Placeholder(value: deltaC)
                    .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                    .minimumScaleFactor(0.5)
                Rectangle()
                    .frame(width: 60, height: 2)
                Placeholder(value: deltaT)
                    .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                    .minimumScaleFactor(0.5)
            }
        }
    }

    private var fraction2: some View {
        HStack(spacing: 0) {
            FixedText("-")
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    Placeholder(value: c2)
                        .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                        .minimumScaleFactor(0.5)
                    FixedText("-")
                    Placeholder(value: c1)
                        .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                        .minimumScaleFactor(0.5)
                }
                Rectangle()
                    .frame(width: 140, height: 2)
                HStack(spacing: 1) {
                    Placeholder(value: t2)
                        .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                        .minimumScaleFactor(0.5)
                    FixedText("-")
                    Placeholder(value: t1)
                        .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                        .minimumScaleFactor(0.5)
                }
            }
        }
    }
}

fileprivate struct FilledHalftime: View {
    var body: some View {
        HStack(spacing: 4) {
            HalfTime()
            FixedText("=")
            A_0()
            FixedText("/")
            FixedText("(2 k)")

        }.font(.system(size: EquationSettings.fontSize))
    }
}

fileprivate struct BlankHalftime: View {

    let c1: String
    let halftime: String?
    let rate: String?

    var body: some View {
        HStack(spacing: 4) {
            Placeholder(value: halftime)
                .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                .minimumScaleFactor(0.5)
            FixedText("=")
            Text(c1)
                .frame(width: EquationSettings.boxWidth)
                .minimumScaleFactor(0.5)
            FixedText("/")
            FixedText("(2")
            FixedText("x")
            Placeholder(value: rate)
                .frame(width: EquationSettings.boxWidth, height: EquationSettings.boxHeight)
                .minimumScaleFactor(0.5)
            FixedText(")")
        }
        .font(.system(size: EquationSettings.fontSize))

    }
}


fileprivate struct Rate: View {
    var body: some View {
        HStack(spacing: 3) {
            Text("Rate")
                .fixedSize()
            FixedText("=")
        }
    }
}


struct ZeroOrderEquationView2_Previews: PreviewProvider {
    static var previews: some View {
        UnscaledZeroOrderEquationView(
            emphasiseFilledTerms: false,
            initialConcentration: 0.1,
            initialTime: 1,
            rate: 1.2,
            deltaC: nil,
            deltaT: nil,
            c2: nil,
            t2: nil,
            halfTime: nil
        )
        .border(Color.red)
        .previewLayout(.fixed(width: 540, height: 265))
    }
}

