//
// Reactions App
//
  

import SwiftUI

struct NewReactionComparisonScreen: View {

    @ObservedObject var navigation: ReactionNavigationViewModel<ReactionComparisonState>

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            NewReactionComparisonViewWithSettings(
                navigation: navigation,
                reaction: navigation.model,
                settings: ReactionComparisonLayoutSettings(
                    geometry: geometry,
                    horizontalSizeClass: horizontalSizeClass,
                    verticalSizeClass: verticalSizeClass
                )
            )
        }
    }
}

fileprivate struct NewReactionComparisonViewWithSettings: View {

    @ObservedObject var navigation: ReactionNavigationViewModel<ReactionComparisonState>
    @ObservedObject var reaction: NewReactionComparisonViewModel

    let settings: ReactionComparisonLayoutSettings

    var body: some View {
        beaky
        beakers
        charts
        equations
    }

    private var beakers: some View {
        HStack {
            VStack {
                beaker(concentrationB: reaction.zeroOrderB)
                beaker(concentrationB: reaction.firstOrderB)
                beaker(concentrationB: reaction.secondOrderB)
            }.padding()
            Spacer()
        }
    }

    private var charts: some View {
        let chartSettings = TimeChartGeometrySettings(chartSize: settings.chartSize)
        return HStack {
            Spacer()
            VStack {
                Spacer()
                chart(
                    chartSettings: chartSettings,
                    concentrationA: reaction.zeroOrder,
                    concentrationB: reaction.zeroOrderB
                )
                chart(
                    chartSettings: chartSettings,
                    concentrationA: reaction.firstOrder,
                    concentrationB: reaction.firstOrderB
                )
                chart(
                    chartSettings: chartSettings,
                    concentrationA: reaction.secondOrder,
                    concentrationB: reaction.secondOrderB
                )
                Spacer()
            }
            Spacer()
        }
    }

    private var equations: some View {
        HStack {
            Spacer()
            VStack {
                GeometryReader { geometry in
                    ReactionComparisonZeroOrderEquation(
                        rate: "1.0",
                        k: "0.2",
                        concentration: "1.0",
                        time: "1",
                        a0: "1.0",
                        maxWidth: geometry.size.width,
                        maxHeight: geometry.size.height
                    ).background(
                        equationBackground(
                            color: Styling.comparisonOrder0Background,
                            border: Styling.comparisonOrder0Border
                        )
                    )
                }

                GeometryReader { geometry in
                    ReactionComparisonFirstOrderEquation(
                        rate: "1.0",
                        k: "0.2",
                        concentration: "1.0",
                        time: "1",
                        a0: "1.0",
                        maxWidth: geometry.size.width,
                        maxHeight: geometry.size.height
                    ).background(
                        equationBackground(
                            color: Styling.comparisonOrder1Background,
                            border: Styling.comparisonOrder1Border
                        )
                    )
                }

                GeometryReader { geometry in
                    ReactionComparisonSecondOrderEquation(
                        rate: "1.0",
                        k: "0.2",
                        concentration: "1.0",
                        time: "1",
                        a0: "1.0",
                        maxWidth: geometry.size.width,
                        maxHeight: geometry.size.height
                    ).background(
                        equationBackground(
                            color: Styling.comparisonOrder2Background,
                            border: Styling.comparisonOrder2Border
                        )
                    )
                }
                Spacer()
                    .frame(height: settings.ordered.beakyBoxTotalHeight)
            }
            .frame(width: settings.equationsWidth)
            .padding(.top, settings.equationTopPadding)
            .padding(.trailing, settings.equationTrailingPadding)
        }
    }

    private func equationBackground(
        color: Color,
        border: Color
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: settings.equationCornerRadius)
                .fill(color)

            RoundedRectangle(cornerRadius: settings.equationCornerRadius)
                .stroke(border, lineWidth: settings.equationBorderWidth)
                .foregroundColor(color)
        }
    }
    

    private func beaker(
        concentrationB: ConcentrationEquation
    ) -> some View {
        FilledBeaker(
            moleculesA: reaction.moleculesA,
            concentrationB: concentrationB,
            currentTime: reaction.currentTime
        )
        .frame(width: settings.beakerWidth)
    }

    private func chart(
        chartSettings: TimeChartGeometrySettings,
        concentrationA: ConcentrationEquation,
        concentrationB: ConcentrationEquation
    ) -> some View {
        ConcentrationPlotView(
            settings: chartSettings,
            concentrationA: concentrationA,
            concentrationB: concentrationB,
            initialConcentration: 1,
            finalConcentration: 0,
            initialTime: reaction.initialTime,
            currentTime: currentTimeBinding,
            finalTime: reaction.finalTime,
            canSetCurrentTime: false,
            minTime: nil,
            maxTime: nil
        ).frame(
            width: chartSettings.chartSize,
            height: chartSettings.chartSize
        )
    }

    private var beaky: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                BeakyBox(
                    statement: navigation.statement,
                    next: navigation.next,
                    back: navigation.back,
                    verticalSpacing: settings.ordered.beakyVSpacing,
                    bubbleWidth: settings.ordered.bubbleWidth,
                    bubbleHeight: settings.ordered.bubbleHeight,
                    beakyHeight: settings.ordered.beakyHeight,
                    fontSize: settings.ordered.bubbleFontSize,
                    navButtonSize: settings.ordered.navButtonSize,
                    bubbleStemWidth: settings.ordered.bubbleStemWidth
                )
            }
        }
    }

    private var currentTimeBinding: Binding<CGFloat> {
        Binding(
            get: { reaction.currentTime ?? 0 },
            set: { reaction.currentTime = $0 }
        )
    }
}

struct ReactionComparisonLayoutSettings {

    let geometry: GeometryProxy
    let horizontalSizeClass: UserInterfaceSizeClass?
    let verticalSizeClass: UserInterfaceSizeClass?

    var beakerWidth: CGFloat {
        0.85 * ordered.beakerWidth
    }

    // TODO
    var chartSize: CGFloat {
        0.8 * ordered.chartSize
    }

    var equationsWidth: CGFloat {
        0.37 * geometry.size.width
    }

    var equationTrailingPadding: CGFloat {
        5
    }

    var equationTopPadding: CGFloat {
        5
    }

    var equationCornerRadius: CGFloat {
        equationsWidth * 0.05
    }

    var equationBorderWidth: CGFloat {
        0.2 * equationCornerRadius
    }


    var ordered: OrderedReactionLayoutSettings {
        OrderedReactionLayoutSettings(
            geometry: geometry,
            horizontalSize: horizontalSizeClass,
            verticalSize: verticalSizeClass
        )
    }

}

struct NewReactionComparisonScreen_Previews: PreviewProvider {
    static var previews: some View {
        NewReactionComparisonScreen(
            navigation: NewReactionComparisonNavigationViewModel.model(
                reaction: NewReactionComparisonViewModel()
            )
        ).previewLayout(.fixed(width: 500, height: 300))
    }
}
