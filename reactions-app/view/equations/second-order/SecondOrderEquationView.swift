//
// Reactions App
//


import SwiftUI

struct SecondOrderEquationView: View {

    let emphasiseFilledTerms: Bool
    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let currentTime: CGFloat?
    let concentration: ConcentrationEquation?
    let reactionHasStarted: Bool
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let rateConstantColor: Color
    let halfLifeColor: Color
    let rateColor: Color
    let reactant: String

    var body: some View {
        ScaledView(
            naturalWidth: EquationSize.width,
            naturalHeight: EquationSize.height,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledSecondOrderEquationView(
                emphasise: emphasiseFilledTerms,
                c1: c1,
                c2: c2,
                t: t,
                currentTime: currentTime,
                concentration: concentration,
                reactionHasStarted: reactionHasStarted,
                rateConstantColor: rateConstantColor,
                halfLifeColor: halfLifeColor,
                rateColor: rateColor,
                reactant: reactant
            )
        }
        .frame(width: maxWidth, height: maxHeight)
        .accessibilityElement(children: .contain)
    }
}

fileprivate struct UnscaledSecondOrderEquationView: View {

    let emphasise: Bool
    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let currentTime: CGFloat?
    let concentration: ConcentrationEquation?
    let reactionHasStarted: Bool
    let rateConstantColor: Color
    let halfLifeColor: Color
    let rateColor: Color
    let reactant: String

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(spacing: 0) {
                SecondOrderRateFilled(reactant: reactant)
                SecondOrderRateBlank(
                    emphasise: emphasise,
                    rateConstant: concentration?.rateConstant.str(decimals: 2),
                    invA0: invStr(c1),
                    invAt: c2.map(invStr),
                    time: t?.str(decimals: 2)
                )
            }
            .background(Color.white.padding(-EquationSize.padding))
            .colorMultiply(rateConstantColor)

            VStack(alignment: .leading, spacing: 0) {
                SecondOrderHalfLifeFilled(reactant: reactant)
                SecondOrderHalfLifeBlank(
                    emphasise: emphasise,
                    halfLife: concentration?.halfLife.str(decimals: 2),
                    rateConstant: concentration?.rateConstant.str(decimals: 2),
                    a0: c1.str(decimals: 2)
                )
            }
            .background(Color.white.padding(-EquationSize.padding))
            .colorMultiply(halfLifeColor)

            VStack(alignment: .leading, spacing: 0) {
                BlankRate(order: 2, reactant: reactant)
                FilledRate(
                    order: 2,
                    reactionHasStarted: reactionHasStarted,
                    currentTime: currentTime,
                    concentration: concentration,
                    emphasise: emphasise,
                    reactant: reactant
                )
            }
            .background(Color.white.padding(-EquationSize.padding))
            .colorMultiply(rateColor)
        }
        .font(.system(size: EquationSettings.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(1)
    }

    private func invStr(_ c: CGFloat) -> String {
        (1 / c.rounded(decimals: 2)).str(decimals: 2)
    }
}

fileprivate struct SecondOrderRateFilled: View {

    let reactant: String

    var body: some View {
        HStack(spacing: 5) {
            Text("k")
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")

            VStack(spacing: 1) {
                HStack(spacing: 5) {
                    inverse {
                        BracketSubscript(mainValue: reactant, subscriptValue: "t")
                    }.frame(width: 100)
                    FixedText("-")
                    inverse {
                        BracketSubscript(mainValue: reactant, subscriptValue: "0")
                    }.frame(width: 100)
                }
                Rectangle()
                    .frame(width: 225, height: 2)
                Text("t")
                    .fixedSize()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibility(
            label: Text(
                "k equals, inverse A T minus inverse A0, divide by T"
            )
        )
    }

    private func inverse<Content: View>(aTerm: () -> Content) -> some View {
        HStack(spacing: 0) {
            Text("(1/")
                .fixedSize()
            aTerm()
            Text(")")
                .fixedSize()
        }
    }
}

fileprivate struct SecondOrderRateBlank: View {

    let emphasise: Bool
    let rateConstant: String?
    let invA0: String?
    let invAt: String?
    let time: String?

    var body: some View {
        HStack(spacing: 5) {
            Placeholder(value: rateConstant, emphasise: emphasise)
                .accessibility(sortPriority: 10)
                .accessibility(label: Text("k"))

            FixedText("=")
                .accessibility(sortPriority: 9)

            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    Placeholder(value: invAt, emphasise: emphasise)
                        .frame(width: 100)
                        .accessibility(sortPriority: 8)
                        .accessibility(label: Text("inverse A T"))

                    FixedText("-")
                        .accessibility(sortPriority: 7)
                        .accessibility(label: Text("minus"))

                    Placeholder(value: invA0, emphasise: invAt == nil)
                        .frame(width: 100)
                        .accessibility(sortPriority: 6)
                        .accessibility(label: Text("inverse A0"))
                }

                Rectangle()
                    .frame(width: 225, height: 2)
                    .accessibility(sortPriority: 5)
                    .accessibility(label: Text("divide by"))

                Placeholder(value: time, emphasise: emphasise)
                    .accessibility(sortPriority: 4)
                    .accessibility(label: Text("'T'"))
            }
        }
        .accessibilityElement(children: .contain)
    }
}

fileprivate struct SecondOrderHalfLifeFilled: View {

    let reactant: String

    var body: some View {
        HStack(spacing: 5) {
            HalfLife()
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")
            FixedText("1")
            FixedText("/")
            FixedText("(k")
            BracketSubscript(mainValue: reactant, subscriptValue: "0")
            FixedText(")")
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("'T' 1/2 equals 1, divide by k times A0"))
    }
}

fileprivate struct SecondOrderHalfLifeBlank: View {

    let emphasise: Bool
    let halfLife: String?
    let rateConstant: String?
    let a0: String

    var body: some View {
        HStack(spacing: 5) {
            Placeholder(value: halfLife, emphasise: emphasise)
                .accessibility(label: Text("'T' 1/2"))

            FixedText("=")

            FixedText("1")

            HStack(spacing: 1) {
                FixedText("/")
                    .accessibility(label: Text("divide by"))

                Placeholder(value: rateConstant, emphasise: emphasise)
                    .accessibility(label: Text("k"))
                FixedText("(")
                    .accessibility(label: Text(Labels.openParen))
                Text(a0)
                    .frame(width: EquationSettings.boxWidth * 0.8)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(rateConstant == nil ? .orangeAccent : .black)
                    .accessibility(label: Text("A0"))
                    .accessibility(value: Text(a0))
                FixedText(")")
                    .accessibility(label: Text(Labels.closedParen))
            }
        }
    }
}

fileprivate struct EquationSize {
    static let width: CGFloat = 360
    static let height: CGFloat = 446
    static let padding: CGFloat = 15
}

struct SecondOrderEquationView2_Previews: PreviewProvider {
    static var previews: some View {
        UnscaledSecondOrderEquationView(
            emphasise: true,
            c1: 1.23,
            c2: 0.34,
            t: 1.4,
            currentTime: nil,
            concentration: nil,
            reactionHasStarted: false,
            rateConstantColor: .white,
            halfLifeColor: .white,
            rateColor: .white,
            reactant: "A"
        )
        .border(Color.red)
        .previewLayout(.fixed(width: EquationSize.width, height: EquationSize.height))
    }
}
