//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderEquationView: View {

    let emphasiseFilledTerms: Bool
    let reactionHasStarted: Bool
    let initialConcentration: CGFloat
    let initialTime: CGFloat
    let deltaC: CGFloat?
    let deltaT: CGFloat?
    let c2: CGFloat?
    let t2: CGFloat?
    let rateColorMultipy: Color
    let halfLifeColorMultiply: Color

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    @Binding var isShowingTooltip: Bool

    let currentTime: CGFloat?
    let concentration: ConcentrationEquation?

    private let naturalWidth: CGFloat = EquationSizes.width
    private let naturalHeight: CGFloat = EquationSizes.height

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledZeroOrderEquationView(
                emphasise: emphasiseFilledTerms,
                reactionHasStarted: reactionHasStarted,
                initialConcentration: initialConcentration,
                initialTime: initialTime,
                deltaC: deltaC,
                deltaT: deltaT,
                c2: c2,
                t2: t2,
                isShowingTooltip: $isShowingTooltip,
                rateColorMultipy: rateColorMultipy,
                halfLifeColorMultiply: halfLifeColorMultiply,
                currentTime: currentTime,
                concentration: concentration
            )
            .frame(width: maxWidth, height: maxHeight)
        }
    }
}

fileprivate struct UnscaledZeroOrderEquationView: View {

    let emphasise: Bool
    let reactionHasStarted: Bool
    let initialConcentration: CGFloat
    let initialTime: CGFloat
    let deltaC: CGFloat?
    let deltaT: CGFloat?
    let c2: CGFloat?
    let t2: CGFloat?
    @Binding var isShowingTooltip: Bool
    let rateColorMultipy: Color
    let halfLifeColorMultiply: Color

    let currentTime: CGFloat?
    let concentration: ConcentrationEquation?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                FilledRateConstant()
                EmptyRateConstant(
                    deltaC: deltaC?.str(decimals: 2),
                    deltaT: deltaT?.str(decimals: 2),
                    c1: initialConcentration.str(decimals: 2),
                    c2: c2?.str(decimals: 2),
                    t1: initialTime.str(decimals: 2),
                    t2: t2?.str(decimals: 2),
                    rate: concentration?.rateConstant.str(decimals: 2),
                    emphasise: emphasise
                )
            }
            .background(Color.white)
            .colorMultiply(rateColorMultipy)

            HStack(spacing: 22) {
                FilledHalfLife(
                    isShowingToolip: $isShowingTooltip
                )
                BlankHalfLife(
                    a0: concentration?.a0.str(decimals: 2),
                    halfLife: concentration?.halfLife.str(decimals: 2),
                    rate: concentration?.rateConstant.str(decimals: 2),
                    emphasise: emphasise
                )
            }
            .background(Color.white)
            .colorMultiply(halfLifeColorMultiply)

            HStack(spacing: 52) {
                BlankRate(order: 0)
                FilledRate(
                    reactionHasStarted: reactionHasStarted,
                    currentTime: currentTime,
                    concentration: concentration,
                    rateConstant: concentration?.rateConstant.str(decimals: 2),
                    rate: concentration?.rateConstant.str(decimals: 2),
                    emphasise: emphasise
                )
            }
        }
        .padding(.horizontal, 5)
        .font(.system(size: EquationSettings.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(1)
    }
}

fileprivate struct FilledRateConstant: View {
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

fileprivate struct EmptyRateConstant: View {

    let deltaC: String?
    let deltaT: String?
    let c1: String?
    let c2: String?
    let t1: String?
    let t2: String?
    let rate: String?
    let emphasise: Bool

    var body: some View {
        HStack(spacing: EquationSettings.hSpacing) {
            Rate()
            Placeholder(
                value: rate,
                emphasise: emphasise
            )
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
                Placeholder(value: deltaC, emphasise: emphasise)

                Rectangle()
                    .frame(width: 60, height: 2)
                Placeholder(value: deltaT, emphasise: emphasise)
            }
        }
    }

    private var fraction2: some View {
        HStack(spacing: 0) {
            FixedText("-")
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    Placeholder(value: c2, emphasise: emphasise)
                    FixedText("-")
                    Placeholder(value: c1, emphasise: c2 == nil)
                }
                Rectangle()
                    .frame(width: 140, height: 2)
                HStack(spacing: 1) {
                    Placeholder(value: t2, emphasise: emphasise)
                    FixedText("-")
                    Placeholder(value: t1, emphasise: t2 == nil)
                }
            }
        }
    }
}

fileprivate struct FilledHalfLife: View {

    @Binding var isShowingToolip: Bool

    var body: some View {
        HStack(spacing: 4) {
            HalfLife()
            FixedText("=")
            A0WithTooltip(
                isShowingTooltip: $isShowingToolip,
                offset: -60
            )
            FixedText("/")
            FixedText("(2 k)")

        }.font(.system(size: EquationSettings.fontSize))
    }
}

fileprivate struct A0WithTooltip: View {

    @Binding var isShowingTooltip: Bool
    let offset: CGFloat

    var body: some View {
            A_0()
                .onTapGesture {
                    isShowingTooltip.toggle()
                }
                .overlay(overlay.offset(y: offset).fixedSize())
    }

    private var overlay: some View {
        if (isShowingTooltip) {
            return AnyView(
                Tooltip(text: "Concentration of A at t=0")
                    .font(.system(size: EquationSettings.fontSize * 0.73))
                    .frame(width: 170)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(1)
            )
        }
        return AnyView(EmptyView())
    }
}

fileprivate struct BlankHalfLife: View {

    let a0: String?
    let halfLife: String?
    let rate: String?
    let emphasise: Bool

    var body: some View {
        HStack(spacing: 4) {
            Placeholder(value: halfLife, emphasise: emphasise)
            FixedText("=")
            Placeholder(value: a0, emphasise: emphasise)
            FixedText("/")
            FixedText("(2")
            FixedText("x")
            Placeholder(value: rate, emphasise: emphasise)
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


fileprivate struct EquationSizes {
    static let width: CGFloat = 550
    static let height: CGFloat = 335
}

struct ZeroOrderEquationView2_Previews: PreviewProvider {
    static var previews: some View {
        UnscaledZeroOrderEquationView(
            emphasise: false,
            reactionHasStarted: false,
            initialConcentration: 0.1,
            initialTime: 1,
            deltaC: nil,
            deltaT: nil,
            c2: nil,
            t2: nil,
            isShowingTooltip: .constant(true),
            rateColorMultipy: .white,
            halfLifeColorMultiply: .white,
            currentTime: nil,
            concentration: ZeroOrderReaction(a0: 1, rateConstant: 0.1)
        )
        .border(Color.red)
        .previewLayout(.fixed(width: EquationSizes.width, height: EquationSizes.height))
    }
}

