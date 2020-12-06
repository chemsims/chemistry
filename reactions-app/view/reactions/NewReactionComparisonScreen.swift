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

    @State private var dragLocation = CGPoint.zero
    @State private var draggingOrder: ReactionOrder?
    @State private var dragOverOrder: ReactionOrder?
    @State private var shakingOrder: ReactionOrder?

    @State private var handPosition: CGPoint = .zero
    @State private var handIsClosed: Bool = false

    let settings: ReactionComparisonLayoutSettings

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .colorMultiply(overlayFor(element: .background))
            beaky
                .colorMultiply(.white)
            beakers
                .colorMultiply(overlayFor(element: .beakers))
            charts
                .colorMultiply(overlayFor(element: .charts))
            equations
                .colorMultiply(overlayFor(element: .equations))

            if (reaction.showDragTutorial) {
                dragViewWithHand
            }

            if (draggingOrder != nil) {
                dragView(position: dragLocation)
            }
        }.onAppear {
            handPosition = settings.topEquationMidPoint
            let animation = Animation.easeInOut(duration: 1.5).delay(1)
            let animation2 = Animation.linear(duration: 0.1).delay(1)
            withAnimation(animation2) {
                handIsClosed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                withAnimation(animation) {
                    let x = settings.chartX(order: .Zero) + (settings.orderDragWidth / 2)
                    let y = settings.chartY(order: .Zero) + (settings.orderDragHeight / 2)
                    handPosition = CGPoint(x: x, y: y)
                }
            }
        }
    }

    private var beakers: some View {
        HStack {
            VStack {
                beaker(concentrationB: reaction.zeroOrderB, time: reaction.currentTime0 ?? 0)
                beaker(concentrationB: reaction.firstOrderB, time: reaction.currentTime1 ?? 0)
                beaker(concentrationB: reaction.secondOrderB, time: reaction.currentTime2 ?? 0)
            }.padding()
            Spacer()
        }
    }

    private var dragViewWithHand: some View {
        let x = settings.chartX(order: .Zero) + (settings.orderDragWidth / 2)
        let y = settings.chartY(order: .Zero) + (settings.orderDragHeight / 2)
        let finalPosition = CGPoint(x: x, y: y)

        let position = reaction.dragTutorialHandIsComplete ? finalPosition : settings.topEquationMidPoint
        return ZStack {
            if (reaction.dragTutorialHandIsMoving) {
                dragView(position: position)
            }
            handImage
                .position(position)
        }
    }

    private var handImage: some View {
        Image(reaction.dragTutorialHandIsMoving ? "closedhand" : "openhand")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: settings.orderDragWidth * 0.3)
    }

    private func dragView(position: CGPoint) ->  some View {
        ZStack {
            RoundedRectangle(cornerRadius: settings.dragCornerRadius)
                .fill(dragColor)

            RoundedRectangle(cornerRadius: settings.dragCornerRadius)
                .stroke()
                .fill(dragBorder)
        }
        .frame(width: settings.orderDragWidth, height: settings.orderDragHeight)
        .position(position)
        .offset(settings.dragOffset)
    }

    private var charts: some View {

        func chartSettings(
            time: CGFloat
        ) -> TimeChartGeometrySettings {
            TimeChartGeometrySettings(
                chartSize: settings.chartSize,
                minConcentration: 0,
                maxConcentration: 1,
                minTime: 0,
                maxTime: time,
                includeAxisPadding: false
            )
        }

        return ZStack {
            chart(
                chartSettings: chartSettings(time: reaction.finalTime0),
                concentrationA: reaction.zeroOrder,
                concentrationB: reaction.zeroOrderB,
                order: .Zero,
                finalTime: reaction.finalTime0,
                currentTime: currentTimeBinding0
            )
            .position(x: settings.chartX(order: .Zero), y: settings.chartY(order: .Zero))

            chart(
                chartSettings: chartSettings(time: reaction.finalTime1),
                concentrationA: reaction.firstOrder,
                concentrationB: reaction.firstOrderB,
                order: .First,
                finalTime: reaction.finalTime1,
                currentTime: currentTimeBinding1
            )
            .position(x: settings.chartX(order: .First), y: settings.chartY(order: .First))

            chart(
                chartSettings: chartSettings(time: reaction.finalTime2),
                concentrationA: reaction.secondOrder,
                concentrationB: reaction.secondOrderB,
                order: .Second,
                finalTime: reaction.finalTime2,
                currentTime: currentTimeBinding2
            )
            .position(x: settings.chartX(order: .Second), y: settings.chartY(order: .Second))
        }
    }

    private var equations: some View {
        HStack {
            Spacer()
            VStack {
                equation(
                    order: .Zero
                ) { geometry in
                    ReactionComparisonZeroOrderEquation(
                        time: reaction.currentTime0,
                        concentration: reaction.zeroOrder,
                        rate: reaction.zeroOrderRate,
                        k: reaction.zeroOrder.rate.str(decimals: 2),
                        a0: a0,
                        maxWidth: geometry.size.width,
                        maxHeight: geometry.size.height
                    )
                }

                equation(
                    order: .First
                ) { geometry in
                    ReactionComparisonFirstOrderEquation(
                        time: reaction.currentTime1,
                        concentration: reaction.firstOrder,
                        rate: reaction.firstOrderRate,
                        k: reaction.firstOrder.rate.str(decimals: 2),
                        a0: a0,
                        maxWidth: geometry.size.width,
                        maxHeight: geometry.size.height
                    )
                }

                equation(
                    order: .Second
                ) { geometry in
                    ReactionComparisonSecondOrderEquation(
                        time: reaction.currentTime2,
                        concentration: reaction.secondOrder,
                        rate: reaction.secondOrderRate,
                        k: reaction.secondOrder.rate.str(decimals: 2),
                        a0: a0,
                        maxWidth: geometry.size.width,
                        maxHeight: geometry.size.height
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

    private func equation<Content: View>(
        order: ReactionOrder,
        content: @escaping (GeometryProxy) -> Content
    ) -> some View {
        GeometryReader { geometry in
            content(geometry)
                .gesture(dragEquationGesture(geometry: geometry, order: order))
        }
        .padding(.horizontal, settings.equationInnerPadding)
        .background(
            equationBackground(
                color: equationColor(order: order),
                border: equationBorderColor(order: order)
            )
        )
        .rotationEffect(shakingOrder == order ? .degrees(3) : .zero)
    }

    private func equationBorderColor(order: ReactionOrder) -> Color {
        if (reaction.correctOrderSelections.contains(order)) {
            return Styling.comparisonEquationDisabledBorder
        }
        return order.border
    }

    private func equationColor(order: ReactionOrder) -> Color {
        if (reaction.correctOrderSelections.contains(order)) {
            return Styling.comparisonEquationDisabled
        }
        return order.color
    }

    private func runShakeAnimation(order: ReactionOrder) {
        let animation = Animation.spring(
            response: 0.125,
            dampingFraction: 0.125
        )
        withAnimation(animation) {
            shakingOrder = order
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            withAnimation(animation) {
                shakingOrder = nil
            }
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
        concentrationB: ConcentrationEquation,
        time: CGFloat
    ) -> some View {
        FilledBeaker(
            moleculesA: reaction.moleculesA,
            concentrationB: concentrationB,
            currentTime: time
        )
        .frame(width: settings.beakerWidth)
    }

    private func chart(
        chartSettings: TimeChartGeometrySettings,
        concentrationA: ConcentrationEquation,
        concentrationB: ConcentrationEquation,
        order: ReactionOrder,
        finalTime: CGFloat,
        currentTime: Binding<CGFloat>
    ) -> some View {
        ZStack {
            if (reaction.currentTime0 == nil) {
                CircleIconButton(
                    action: navigation.next,
                    systemImage: Icons.rightArrow,
                    background: .clear,
                    border: .black,
                    foreground: reaction.canStartAnimation ? .orangeAccent : .gray
                )
                .disabled(!reaction.canStartAnimation)
                .frame(width: settings.chartSize * 0.5)
            }
            if (reaction.currentTime0 != nil) {
                ConcentrationPlotView(
                    settings: chartSettings,
                    concentrationA: concentrationA,
                    concentrationB: concentrationB,
                    initialConcentration: 1,
                    finalConcentration: 0,
                    initialTime: reaction.initialTime,
                    currentTime: currentTime,
                    finalTime: finalTime,
                    canSetCurrentTime: false,
                    includeAxis: false
                )
            }
        }
        .frame(
            width: chartSettings.chartSize,
            height: chartSettings.chartSize
        )
        .background(Color.white.border(Color.black, width: 0.5 * settings.chartBorderWidth))
        .padding(settings.chartBorderWidth)
        .border(
            chartBorderColor(order: order),
            width: chartBorderWidth(order: order)
        )
    }

    private func chartBorderColor(order: ReactionOrder) -> Color {
        if (reaction.correctOrderSelections.contains(order)) {
            return order.border
        } else if (dragOverOrder == order) {
            return dragBorder
        }
        return Color.black
    }

    private func chartBorderWidth(order: ReactionOrder) -> CGFloat{
        if (reaction.correctOrderSelections.contains(order) || dragOverOrder == order) {
            return settings.chartBorderWidth
        }
        return 0
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
                ).padding(.trailing, settings.ordered.beakyRightPadding)
            }
        }
    }

    private var currentTimeBinding0: Binding<CGFloat> {
        Binding(
            get: { reaction.currentTime0 ?? 0 },
            set: { reaction.currentTime0 = $0 }
        )
    }

    private var currentTimeBinding1: Binding<CGFloat> {
        Binding(
            get: { reaction.currentTime1 ?? 0 },
            set: { reaction.currentTime1 = $0 }
        )
    }

    private var currentTimeBinding2: Binding<CGFloat> {
        Binding(
            get: { reaction.currentTime2 ?? 0 },
            set: { reaction.currentTime2 = $0 }
        )
    }

    private func overlayFor(element: ReactionComparisonScreenElement) -> Color {
        let highlights = reaction.highlightedElements
        if (highlights.isEmpty || highlights.contains(element)) {
            return .white
        }

        let x: Double = 173
        return  RGB(r: x, g: x, b: x).color.opacity(0.5)
    }

    private var dragBorder: Color {
        (draggingOrder ?? .Zero).border
    }

    private var dragColor: Color {
        (draggingOrder ?? .Zero).color
    }

    private var a0: String {
        "1.0"
    }

    private func dragEquationGesture(
        geometry: GeometryProxy,
        order: ReactionOrder
    ) -> some Gesture {
        DragGesture().onChanged { gesture in
            guard reaction.canDragOrders else {
                return
            }
            self.draggingOrder = order
            let globalFrame = geometry.frame(in: .global)
            let localFrame = geometry.frame(in: .local)
            let updatedPosition = gesture.location.frame(current: localFrame, target: globalFrame)
            self.dragLocation = updatedPosition
            self.dragOverOrder = settings.overlappingOrder(point: updatedPosition)
        }.onEnded { gesture in
            guard reaction.canDragOrders else {
                // Always set these to nil in case canDragOrders changes
                // while drag is in progress
                self.draggingOrder = nil
                self.dragOverOrder = nil
                return
            }
            if let dragOverOrder = dragOverOrder {
                if (dragOverOrder == order) {
                    reaction.addToCorrectSelection(order: order)
                    if (reaction.correctOrderSelections.count == 3) {
                        navigation.next()
                    }
                } else if (!reaction.correctOrderSelections.contains(dragOverOrder)) {
                    runShakeAnimation(order: order)
                }
            }
            self.draggingOrder = nil
            self.dragOverOrder = nil
        }
    }

}

fileprivate extension ReactionOrder {
    var border: Color {
        switch (self) {
        case .Zero: return Styling.comparisonOrder0Border
        case .First: return Styling.comparisonOrder1Border
        case .Second: return Styling.comparisonOrder2Border
        }
    }

    var color: Color {
        switch (self) {
        case .Zero: return Styling.comparisonOrder0Background
        case .First: return Styling.comparisonOrder1Background
        case .Second: return Styling.comparisonOrder2Background
        }
    }
}

fileprivate extension CGPoint {

    func frame(current: CGRect, target: CGRect) -> CGPoint {
        let newX = (target.origin.x + current.origin.x) + self.x
        let newY = (target.origin.y + current.origin.y) + self.y
        return CGPoint(x: newX, y: newY)
    }

}

struct ReactionComparisonLayoutSettings {

    let geometry: GeometryProxy
    let horizontalSizeClass: UserInterfaceSizeClass?
    let verticalSizeClass: UserInterfaceSizeClass?

    var height: CGFloat {
        geometry.size.height
    }

    var width: CGFloat {
        geometry.size.width
    }

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

    var equationInnerPadding: CGFloat {
        0.02 * equationsWidth
    }

    var equationCornerRadius: CGFloat {
        equationsWidth * 0.05
    }

    var topEquationMidPoint: CGPoint {
        let x = width - equationTrailingPadding - (equationsWidth / 2)
        let equationHeight = (height - ordered.beakyBoxTotalHeight) / 3
        return CGPoint(x: x, y: equationHeight)
    }

    var equationBorderWidth: CGFloat {
        0.2 * equationCornerRadius
    }

    var chartVerticalSpacing: CGFloat {
        0.2 * chartSize
    }

    var chartVerticalSpacerHeight: CGFloat {
        0.5 * (height - (3 * chartSize) - (4 * chartVerticalSpacing))
    }

    var chartHorizontalSpacerWidth: CGFloat {
        0.5 * (width - chartSize)
    }

    var orderDragWidth: CGFloat {
        0.9 * chartSize
    }

    var orderDragHeight: CGFloat {
        0.4 * orderDragWidth
    }

    var dragCornerRadius: CGFloat {
        0.1 * orderDragWidth
    }

    var dragOffset: CGSize {
        CGSize(
            width: -orderDragWidth * 0.4,
            height: -orderDragHeight * 0.4
        )
    }

    var chartBorderWidth: CGFloat {
        1.25
    }

    func chartX(order: ReactionOrder) -> CGFloat {
        width / 2
    }

    func chartY(order: ReactionOrder) -> CGFloat {
        let topChartPosition = chartVerticalSpacing + chartVerticalSpacerHeight + (chartSize / 2)
        switch (order) {
        case .Zero: return topChartPosition
        case .First: return topChartPosition + chartVerticalSpacing + chartSize
        case .Second: return height - topChartPosition
        }
    }

    func overlapsTopChart(point: CGPoint) -> Bool {
        let chartMinX = (width / 2) - (chartSize / 2)
        let chartMinY = chartVerticalSpacerHeight + chartVerticalSpacing
        let rect = CGRect(x: chartMinX, y: chartMinY, width: chartSize, height: chartSize)

        let dragRect = CGRect(
            x: point.x - orderDragWidth / 2,
            y: point.y - orderDragHeight / 2,
            width: orderDragWidth,
            height: orderDragHeight
        )

        return rect.intersects(dragRect)
    }

    func overlappingOrder(point: CGPoint) -> ReactionOrder? {
        let dragRect = CGRect(
            x: point.x - (orderDragWidth / 2) + dragOffset.width,
            y: point.y - (orderDragHeight / 2) + dragOffset.height,
            width: orderDragWidth,
            height: orderDragHeight
        )
        let orders: [ReactionOrder] = [.Zero, .First, .Second]
        return orders.first { order in
            let rect = chartRect(order: order)
            return rect.intersects(dragRect)
        }
    }

    private func chartRect(order: ReactionOrder) -> CGRect {
        let midX = chartX(order: order)
        let midY = chartY(order: order)
        return CGRect(
            x: midX - (chartSize / 2),
            y: midY - (chartSize / 2),
            width: chartSize,
            height: chartSize
        )
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
                reaction: NewReactionComparisonViewModel(
                    persistence: InMemoryReactionInputPersistence()
                )
            )
        ).previewLayout(.fixed(width: 500, height: 300))
    }
}
