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
    let rateColorMultiply: Color
    let halfLifeColorMultiply: Color

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    @Binding var isShowingTooltip: Bool

    let currentTime: CGFloat?
    let concentration: ConcentrationEquation?

    let reactant: String

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
                rateColorMultipy: rateColorMultiply,
                halfLifeColorMultiply: halfLifeColorMultiply,
                currentTime: currentTime,
                concentration: concentration,
                reactant: reactant
            )
            .frame(width: maxWidth, height: maxHeight)
        }
        .accessibilityElement(children: .contain)
        .accessibility(sortPriority: 0)
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
    let reactant: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                FilledRateConstant()
                    .accessibility(sortPriority: 4)
                    .accessibility(addTraits: .isHeader)
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
                .accessibilityElement(children: .contain)
                .accessibility(sortPriority: 3)
            }
            .background(Color.white.padding(-EquationSizes.padding))
            .colorMultiply(rateColorMultipy)

            HStack(spacing: 22) {
                FilledHalfLife(
                    reactant: reactant,
                    isShowingToolip: $isShowingTooltip
                )
                BlankHalfLife(
                    a0: concentration?.a0.str(decimals: 2),
                    halfLife: concentration?.halfLife.str(decimals: 2),
                    rate: concentration?.rateConstant.str(decimals: 2),
                    emphasise: emphasise
                )
            }
            .background(Color.white.padding(-EquationSizes.padding))
            .colorMultiply(halfLifeColorMultiply)

            HStack(spacing: 52) {
                BlankRate(order: 0, reactant: reactant)
                FilledRate(
                    order: 0,
                    reactionHasStarted: reactionHasStarted,
                    currentTime: currentTime,
                    concentration: concentration,
                    emphasise: emphasise,
                    reactant: reactant
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
        .accessibilityElement()
        .accessibility(
            label: Text(
                "Rate equals k equals negative delta c divided by delta t. Equals negative, c2 minus c1, divided by t2 minus t1"
            )
        )
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
    let c1: String
    let c2: String?
    let t1: String
    let t2: String?
    let rate: String?
    let emphasise: Bool

    var body: some View {
        HStack(spacing: EquationSettings.hSpacing) {
            Rate()
                .accessibility(sortPriority: 5)
            Placeholder(
                value: rate,
                emphasise: emphasise
            )
            .accessibility(label: Text("k"))
            .accessibility(sortPriority: 4)
            Text("=")
                .fixedSize()
                .accessibility(sortPriority: 3)
            fraction1
            FixedText("=")
                .accessibility(sortPriority: 1)
            fraction2
        }
        .font(.system(size: EquationSettings.fontSize))
        .lineLimit(1)
    }

    private var fraction1: some View {
        HStack(spacing: 0) {
            FixedText("-")
                .accessibility(label: Text("negative"))
                .accessibility(sortPriority: 2.9)
            VStack(spacing: 1) {
                Placeholder(value: deltaC, emphasise: emphasise)
                    .accessibility(label: Text("delta c"))
                    .accessibility(sortPriority: 2.8)
                Rectangle()
                    .frame(width: 60, height: 2)
                    .accessibility(label: Text("Divide by"))
                    .accessibility(sortPriority: 2.7)
                Placeholder(value: deltaT, emphasise: emphasise)
                    .accessibility(label: Text("delta t"))
                    .accessibility(sortPriority: 2.6)
            }
        }
    }

    private var fraction2: some View {
        HStack(spacing: 0) {
            FixedText("-")
                .accessibility(label: Text("negative"))
                .accessibility(sortPriority: 0.9)
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    Placeholder(value: c2, emphasise: emphasise)
                        .accessibility(label: Text("c2"))
                        .accessibility(sortPriority: 0.8)
                    FixedText("-")
                        .accessibility(label: Text("minus"))
                        .accessibility(sortPriority: 0.7)
                    Placeholder(value: c1, emphasise: c2 == nil)
                        .accessibility(label: Text("c1"))
                        .accessibility(sortPriority: 0.6)
                }
                Rectangle()
                    .frame(width: 140, height: 2)
                    .accessibility(label: Text("Divide by"))
                    .accessibility(sortPriority: 0.5)
                HStack(spacing: 1) {
                    Placeholder(value: t2, emphasise: emphasise)
                        .accessibility(label: Text("t2"))
                        .accessibility(sortPriority: 0.4)
                    FixedText("-")
                        .accessibility(label: Text("minus"))
                        .accessibility(sortPriority: 0.3)
                    Placeholder(value: t1, emphasise: t2 == nil)
                        .accessibility(label: Text("t1"))
                        .accessibility(sortPriority: 0.2)
                }
            }
        }
    }
}

fileprivate struct FilledHalfLife: View {

    let reactant: String
    @Binding var isShowingToolip: Bool

    var body: some View {
        HStack(spacing: 4) {
            HalfLife()
            FixedText("=")
            A0WithTooltip(
                reactant: reactant,
                isShowingTooltip: $isShowingToolip,
                offset: -60
            )
            FixedText("/")
            FixedText("(2 k)")

        }
        .font(.system(size: EquationSettings.fontSize))
        .accessibilityElement()
        .accessibility(label:
            Text(
                "'T' 1/2 equals A0, divided by 2 times k"
            )
        )
    }
}

fileprivate struct A0WithTooltip: View {

    let reactant: String
    @Binding var isShowingTooltip: Bool
    let offset: CGFloat

    var body: some View {
            BracketSubscript(mainValue: reactant, subscriptValue: "0")
                .onTapGesture {
                    isShowingTooltip.toggle()
                }
                .overlay(overlay.offset(y: offset).fixedSize())
    }

    private var overlay: some View {
        if (isShowingTooltip) {
            return AnyView(
                Tooltip(text: "Concentration of \(reactant) at t=0")
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
                .accessibility(label: Text("'T' 1/2"))
            FixedText("=")
            Placeholder(value: a0, emphasise: emphasise)
                .accessibility(label: Text("A0"))

            FixedText("/")
                .accessibility(label: Text("Divide by"))

            HStack(spacing: 0) {
                FixedText("(")
                    .accessibility(label: Text(Labels.openParen))
                FixedText("2")
            }
            FixedText("x")
            .accessibility(label: Text("times"))

            Placeholder(value: rate, emphasise: emphasise)
                .accessibility(label: Text("k"))

            FixedText(")")
                .accessibility(label: Text(Labels.closedParen))
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
    static let width: CGFloat = 580
    static let height: CGFloat = 365

    static let padding: CGFloat = 15
}

struct ZeroOrderEquationView_Previews: PreviewProvider {
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
            isShowingTooltip: .constant(false),
            rateColorMultipy: .white,
            halfLifeColorMultiply: .white,
            currentTime: nil,
            concentration: ZeroOrderConcentration(a0: 1, rateConstant: 0.1),
            reactant: "A"
        )
        .border(Color.red)
        .previewLayout(.fixed(width: EquationSizes.width, height: EquationSizes.height))
    }
}

