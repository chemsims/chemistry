//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderEquationView2: View {

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
    

    private let naturalWidth: CGFloat = 373
    private let naturalHeight: CGFloat = 277

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            VStack(alignment: .leading, spacing: 4) {
                FilledRateView()
                EmptyRateView(
                    deltaC: deltaC?.str(decimals: 2),
                    deltaT: deltaT?.str(decimals: 2),
                    c1: initialConcentration.str(decimals: 2),
                    c2: c2?.str(decimals: 2),
                    t1: initialTime.str(decimals: 2),
                    t2: t2?.str(decimals: 2)
                )
                FilledHalftime()
                BlankHalftime(
                    c1: initialConcentration.str(decimals: 2),
                    halftime: halfTime?.str(decimals: 2),
                    rate: rate?.str(decimals: 2)
                )
            }
            .font(.system(size: RateEquationSizes.fontSize))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }.frame(width: maxWidth, height: maxHeight)
    }
}

fileprivate struct FilledRateView: View {
    var body: some View {
        HStack(spacing: Settings.hSpacing) {
            Rate()
            fraction1
            Equals()
            fraction2
        }
    }

    private var fraction1: some View {
        HStack(spacing: 0) {
            Minus()
            VStack(spacing: 1) {
                HStack(spacing: 0) {
                    Text("Δc")
                        .frame(width: Settings.boxWidth)
                }
                Rectangle()
                    .frame(width: 50, height: 2)
                Text("Δt")
                    .frame(width: Settings.boxWidth)
            }
        }
    }

    private var fraction2: some View {
        HStack(spacing: 0) {
            Minus()
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    Text("c2")
                        .frame(width: Settings.boxWidth)
                    Minus()
                    Text("c1")
                        .frame(width:  Settings.boxWidth)
                }
                Rectangle()
                    .frame(width: 155, height: 2)
                HStack(spacing: 1) {
                    Text("t2")
                        .frame(width:  Settings.boxWidth)
                    Minus()
                    Text("t1")
                        .frame(width:  Settings.boxWidth)
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

    var body: some View {
        HStack(spacing: Settings.hSpacing) {
            Rate()
            fraction1
            Equals()
            fraction2
        }
        .font(.system(size: RateEquationSizes.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }

    private var fraction1: some View {
        HStack(spacing: 0) {
            Minus()
            VStack(spacing: 1) {
                Placeholder(value: deltaC)
                    .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                Rectangle()
                    .frame(width: 60, height: 2)
                Placeholder(value: deltaT)
                    .frame(width: Settings.boxWidth, height: Settings.boxHeight)
            }
        }
    }

    private var fraction2: some View {
        HStack(spacing: 0) {
            Minus()
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    Placeholder(value: c2)
                        .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                    Minus()
                    Placeholder(value: c1)
                        .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                }
                Rectangle()
                    .frame(width: 140, height: 2)
                HStack(spacing: 1) {
                    Placeholder(value: t2)
                        .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                    Minus()
                    Placeholder(value: t1)
                        .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                }
            }
        }
    }
}

fileprivate struct FilledHalftime: View {
    var body: some View {
        HStack(spacing: 4) {
            HalfTime()
                .frame(width: Settings.boxWidth)
            Equals()
            A_0()
                .frame(width: Settings.boxWidth)
            Text("/")
                .frame(width: 12)
            Text("(2 k)")
                .frame(width: 60)

        }.font(.system(size: RateEquationSizes.fontSize))
    }
}

fileprivate struct BlankHalftime: View {

    let c1: String
    let halftime: String?
    let rate: String?

    var body: some View {
        HStack(spacing: 4) {
            Placeholder(value: halftime)
                .frame(width: Settings.boxWidth, height: Settings.boxHeight)
            Equals()
            Text(c1)
                .frame(width: Settings.boxWidth)
            Divide()
            Text("(2")
                .frame(width: 30)
            Text("x")
                .frame(width: 18)
            Placeholder(value: rate)
                .frame(width: Settings.boxWidth, height: Settings.boxHeight)
            Text(")")
                .frame(width: 8)
        }
        .font(.system(size: RateEquationSizes.fontSize))

    }
}

fileprivate struct Divide: View {
    var body: some View {
        Text("/")
            .frame(width: 12)
    }
}

fileprivate struct Rate: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("Rate")
                .frame(width:65)
            Equals()
        }
    }
}

fileprivate struct HalfTime: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("t")
                .font(.system(size: RateEquationSizes.fontSize))
                .frame(width: 20, alignment: .trailing)
            Text("1/2")
                .font(.system(size: RateEquationSizes.subscriptFontSize))
                .offset(y: 10)
                .frame(width: 30)
        }
    }
}

fileprivate struct Minus: View {
    var body: some View {
        Text("-")
            .frame(width: 17)
    }
}

fileprivate struct Equals: View {
    var body: some View {
        Text("=")
            .frame(width: 20)
    }
}

fileprivate struct Placeholder: View {
    let value: String?

    var body: some View {
        if (value != nil) {
            Text(value!)
        } else {
            Box()
        }
    }

}

fileprivate struct Box: View {
    let size: CGFloat = 35

    var body: some View {
        EquationPlaceholderView()
            .padding(10)
    }
}

fileprivate struct Settings {
    static let hSpacing: CGFloat = 2
    static let boxHeight: CGFloat = 50
    static let boxWidth: CGFloat = 70
}
