//
// Reactions App
//

import SwiftUI

struct ReactionComparisonScreen: View {

    @ObservedObject var model: ReactionComparisonViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            ReactionComparisonViewWithSettings(
                reaction: model,
                settings: ReactionComparisonLayoutSettings(
                    geometry: geometry,
                    horizontalSizeClass: horizontalSizeClass,
                    verticalSizeClass: verticalSizeClass,
                    ordering: model.reactionOrdering
                )
            )
        }
        .onAppear {
            DeferScreenEdgesState.shared.deferEdges = .top
        }.onDisappear {
            DeferScreenEdgesState.shared.deferEdges = []
        }
    }
}

private struct ReactionComparisonViewWithSettings: View {

    @ObservedObject var reaction: ReactionComparisonViewModel

    @State private var dragLocation = CGPoint.zero
    @State private var draggingOrder: ReactionOrder?
    @State private var dragOverOrder: ReactionOrder?
    @State private var shakingOrder: ReactionOrder?

    @State private var handIsClosed: Bool = false

    let settings: ReactionComparisonLayoutSettings

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .colorMultiply(overlayFor(element: .background))
                .edgesIgnoringSafeArea(.all)

            beaky
                .colorMultiply(.white)
            beakers
                .colorMultiply(overlayFor(element: .beakers))
            charts
                .colorMultiply(overlayFor(element: .charts))
            equations
                .colorMultiply(overlayFor(element: .equations))

            if reaction.showDragTutorial {
                dragViewWithHand
            }

            if draggingOrder != nil {
                dragView(position: dragLocation)
            }
        }
    }

    private var beakers: some View {
        func orderMsg(_ order: ReactionOrder) -> String {
            let selected = reaction.correctOrderSelections.contains(order)
            return selected ? ". Correctly identified as \(order) order. " : ""
        }

        return HStack(spacing: 0) {
            Spacer()
                .frame(width: settings.ordered.menuTotalWidth)
            VStack {
                beaker(order: settings.ordering[0])
                    .accessibilityElement(children: .contain)
                    .accessibility(label: Text("Top beaker\(orderMsg(settings.ordering[0]))"))
                    .accessibility(sortPriority: 0.5)

                beaker(order: settings.ordering[1])
                    .accessibilityElement(children: .contain)
                    .accessibility(label: Text("Middle beaker\(orderMsg(settings.ordering[1]))"))
                    .accessibility(sortPriority: 0.4)

                beaker(order: settings.ordering[2])
                    .accessibilityElement(children: .contain)
                    .accessibility(label: Text("Bottom beaker\(orderMsg(settings.ordering[2]))"))
                    .accessibility(sortPriority: 0.3)
            }.padding(settings.beakerPadding)
            Spacer()
        }
    }

    private var dragViewWithHand: some View {
        let order = settings.ordering[0]
        let x = settings.chartX(order: order) + (settings.orderDragWidth / 2)
        let y = settings.chartY(order: order) + (settings.orderDragHeight / 2)
        let finalPosition = CGPoint(x: x, y: y)

        let position = reaction.dragTutorialHandIsComplete ? finalPosition : settings.topEquationMidPoint

        return ZStack {
            if reaction.dragTutorialHandIsMoving {
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

            Text(dragString)
                .minimumScaleFactor(0.6)
                .font(.system(size: settings.dragFontSize, weight: .bold))
        }
        .frame(width: settings.orderDragWidth, height: settings.orderDragHeight)
        .position(position)
        .offset(settings.dragOffset)
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.willResignActiveNotification
            )
        ) { _ in
            endDrag()
        }
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
            labelledChart(
                chartSettings: chartSettings(time: reaction.finalTime0),
                concentrationA: reaction.zeroOrder,
                concentrationB: reaction.zeroOrderB,
                order: .Zero,
                finalTime: reaction.finalTime0,
                currentTime: currentTimeBinding0
            )
            .position(x: settings.chartX(order: .Zero), y: settings.chartY(order: .Zero))

            labelledChart(
                chartSettings: chartSettings(time: reaction.finalTime1),
                concentrationA: reaction.firstOrder,
                concentrationB: reaction.firstOrderB,
                order: .First,
                finalTime: reaction.finalTime1,
                currentTime: currentTimeBinding1
            )
            .position(x: settings.chartX(order: .First), y: settings.chartY(order: .First))

            labelledChart(
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
            VStack(spacing: settings.ordered.beakyBottomPadding) {
                equation(
                    order: .Zero
                ) { geometry in
                    ReactionComparisonZeroOrderEquation(
                        time: reaction.currentTime0,
                        concentration: reaction.zeroOrder,
                        rate: reaction.zeroOrder.rateEquation,
                        k: reaction.zeroOrder.rateConstant.str(decimals: 2),
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
                        rate: reaction.firstOrder.rateEquation,
                        k: reaction.firstOrder.rateConstant.str(decimals: 2),
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
                        rate: reaction.secondOrder.rateEquation,
                        k: reaction.secondOrder.rateConstant.str(decimals: 2),
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

    @ViewBuilder
    private func equation<Content: View>(
        order: ReactionOrder,
        content: @escaping (GeometryProxy) -> Content
    ) -> some View {
        let view = GeometryReader { geometry in
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
        .accessibilityElement(children: .contain)
        .accessibility(label: Text("Equation box"))
        .disabled(!canDragOrder(order))

        if !canDragOrder(order) {
            view
        } else {
            view
                .accessibilityAction(named: Text("Drag over top chart")) {
                    accessibilityDrag(order: order, chartIndex: 0)
                }
                .accessibilityAction(named: Text("Drag over middle chart")) {
                    accessibilityDrag(order: order, chartIndex: 1)
                }
                .accessibilityAction(named: Text("Drag over bottom chart")) {
                    accessibilityDrag(order: order, chartIndex: 2)
                }
        }
    }

    private func accessibilityDrag(order: ReactionOrder, chartIndex: Int) {
        if settings.ordering[chartIndex] == order {
            UIAccessibility.post(notification: .announcement, argument: "Correct selection")
            handleCorrectSelection(order: order)
        } else {
            UIAccessibility.post(notification: .announcement, argument: "Incorrect selection")
        }
    }

    private func equationBorderColor(order: ReactionOrder) -> Color {
        if reaction.correctOrderSelections.contains(order) {
            return Styling.comparisonEquationDisabledBorder
        }
        return order.border
    }

    private func equationColor(order: ReactionOrder) -> Color {
        if reaction.correctOrderSelections.contains(order) {
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
        order: ReactionOrder
    ) -> some View {
        return BeakerOfReactantToProduct(
            moleculesA: reaction.moleculesA,
            concentrationB: concentration(order: order),
            currentTime: time(order: order) ?? 0,
            finalTime: finalTime(order: order),
            reactionPair: ReactionType.A.display,
            outlineColor: chartBorderColor(order: order)
        )
        .frame(width: settings.beakerWidth)
    }

    private func concentration(order: ReactionOrder) -> Equation {
        switch order {
        case .Zero: return reaction.zeroOrderB
        case .First: return reaction.firstOrderB
        case .Second: return reaction.secondOrderB
        }
    }

    private func time(order: ReactionOrder) -> CGFloat? {
        switch order {
        case .Zero: return reaction.currentTime0
        case .First: return reaction.currentTime1
        case .Second: return reaction.currentTime2
        }
    }

    private func finalTime(order: ReactionOrder) -> CGFloat? {
        switch order {
        case .Zero: return reaction.finalTime0
        case .First: return reaction.finalTime1
        case .Second: return reaction.finalTime2
        }
    }

    private func labelledChart(
        chartSettings: TimeChartGeometrySettings,
        concentrationA: Equation,
        concentrationB: Equation,
        order: ReactionOrder,
        finalTime: CGFloat,
        currentTime: Binding<CGFloat>
    ) -> some View {
        let hasSelected = reaction.correctOrderSelections.contains(order)
        let orderMsg = hasSelected ? " Correctly selected as \(order) order. " : ""
        let label = "Chart showing time vs concentration.\(orderMsg) \(shape(order))"
        return HStack(alignment: .top, spacing: settings.chartHorizontalLabelSpacing) {
            Text("[A]")
                .font(.system(size: settings.chartFontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: settings.chartYLabelWidth, height: settings.chartSize)
                .accessibility(hidden: true)

            VStack(spacing: settings.chartVerticalLabelSpacing) {
                chart(
                    chartSettings: chartSettings,
                    concentrationA: concentrationA,
                    concentrationB: concentrationB,
                    order: order,
                    finalTime: finalTime,
                    currentTime: currentTime
                )
                Text("Time")
                    .font(.system(size: settings.chartFontSize))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(width: settings.chartSize, height: settings.chartXLabelHeight)
                    .accessibility(hidden: true)
            }
        }
        .frame(width: settings.chartTotalWidth, height: settings.chartTotalHeight)
        .accessibilityElement(children: .contain)
        .accessibility(label: Text(label))
        .accessibility(sortPriority: settings.chartSortPriority(order: order))
    }

    private func shape(_ order: ReactionOrder) -> String {
        if reaction.currentTime0 == nil {
            return "Reaction has not started yet"
        }
        switch order {
        case .Zero: return "Concentration of A reduces in a straight line, while B increases in a straight line"
        case .First: return "Concentration of A reduces in a curved line which is steeper at the start, and B increases with the same curve, flipped horizontally"
        case .Second: return "Concentration of A reduces in a heavily curved line which is stepper at the start, and B increases with the same curve, flipped horizontally"
        }
    }

    private func chart(
        chartSettings: TimeChartGeometrySettings,
        concentrationA: Equation,
        concentrationB: Equation,
        order: ReactionOrder,
        finalTime: CGFloat,
        currentTime: Binding<CGFloat>
    ) -> some View {
        ZStack {
            if reaction.currentTime0 == nil {
                CircleIconButton(
                    action: reaction.next,
                    systemImage: Icons.rightArrow,
                    background: .clear,
                    border: .black,
                    foreground: reaction.canStartAnimation ? .orangeAccent : .gray
                )
                .accessibility(label: Text("Start reaction"))
                .disabled(!reaction.canStartAnimation)
                .frame(width: settings.chartSize * 0.5)
            }
            if reaction.currentTime0 != nil {
                ConcentrationPlotView(
                    settings: chartSettings,
                    concentrationA: concentrationA,
                    concentrationB: concentrationB,
                    initialConcentration: 1,
                    finalConcentration: 0,
                    initialTime: reaction.initialTime,
                    currentTime: currentTime,
                    finalTime: finalTime,
                    canSetCurrentTime: reaction.reactionHasEnded,
                    highlightChart: false,
                    highlightLhsCurve: false,
                    highlightRhsCurve: false,
                    display: ReactionType.A.display,
                    includeAxis: false
                )
                .disabled(!reaction.reactionHasEnded)
            }
        }
        .frame(
            width: chartSettings.chartSize,
            height: chartSettings.chartSize
        )
        .padding(settings.chartBorderWidth)
        .background(Color.white)
        .border(
            chartBorderColor(order: order),
            width: chartBorderWidth(order: order)
        )
    }

    private func chartBorderColor(order: ReactionOrder) -> Color {
        if reaction.correctOrderSelections.contains(order) {
            return order.border
        } else if dragOverOrder == order {
            return dragBorder
        }
        return Styling.beakerOutline
    }

    private func chartBorderWidth(order: ReactionOrder) -> CGFloat {
        if reaction.correctOrderSelections.contains(order) || dragOverOrder == order {
            return settings.chartBorderWidth
        }
        return settings.chartBorderWidth * 0.5
    }

    private var beaky: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                BeakyBox(
                    statement: reaction.statement,
                    next: reaction.next,
                    back: reaction.back,
                    nextIsDisabled: !reaction.canClickNext,
                    verticalSpacing: settings.ordered.beakyVSpacing,
                    bubbleWidth: settings.ordered.bubbleWidth,
                    bubbleHeight: settings.ordered.bubbleHeight,
                    beakyHeight: settings.ordered.beakyHeight,
                    fontSize: settings.ordered.bubbleFontSize,
                    navButtonSize: settings.ordered.navButtonSize,
                    bubbleStemWidth: settings.ordered.bubbleStemWidth
                )
                .padding(.trailing, settings.ordered.beakyRightPadding)
                .padding(.bottom, settings.ordered.beakyBottomPadding)
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
        if highlights.isEmpty || highlights.contains(element) {
            return .white
        }
        return Styling.inactiveScreenElement
    }

    private var dragBorder: Color {
        (draggingOrder ?? .Zero).border
    }

    private var dragColor: Color {
        (draggingOrder ?? .Zero).color
    }

    private var dragString: String {
        (draggingOrder ?? .Zero).string
    }

    private var a0: String {
        "1.0"
    }

    private func dragEquationGesture(
        geometry: GeometryProxy,
        order: ReactionOrder
    ) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global).onChanged { gesture in
            guard canDragOrder(order) else {
                return
            }
            self.draggingOrder = order
            self.dragLocation = gesture.location
            self.dragOverOrder = settings.overlappingOrder(point: gesture.location)
        }.onEnded { _ in
            guard reaction.canDragOrders else {
                // Always set these to nil in case canDragOrders changes
                // while drag is in progress
                self.draggingOrder = nil
                self.dragOverOrder = nil
                return
            }
            if let dragOverOrder = dragOverOrder {
                if dragOverOrder == order {
                    handleCorrectSelection(order: order)
                } else if !reaction.correctOrderSelections.contains(dragOverOrder) {
                    runShakeAnimation(order: order)
                }
            }
            endDrag()
        }
    }

    private func canDragOrder(_ order: ReactionOrder) -> Bool {
        reaction.canDragOrders && !reaction.correctOrderSelections.contains(order)
    }

    private func handleCorrectSelection(order: ReactionOrder) {
        reaction.addToCorrectSelection(order: order)
        if reaction.correctOrderSelections.count == 3 && !reaction.reactionHasEnded {
            reaction.next()
        }
    }

    private func endDrag() {
        self.draggingOrder = nil
        self.dragOverOrder = nil
    }
}

fileprivate extension ReactionOrder {
    var border: Color {
        switch self {
        case .Zero: return Styling.comparisonOrder0Border
        case .First: return Styling.comparisonOrder1Border
        case .Second: return Styling.comparisonOrder2Border
        }
    }

    var color: Color {
        switch self {
        case .Zero: return Styling.comparisonOrder0Background
        case .First: return Styling.comparisonOrder1Background
        case .Second: return Styling.comparisonOrder2Background
        }
    }

    var string: String {
        var num: String
        switch self {
        case .Zero: num = "0"
        case .First: num = "1"
        case .Second: num = "2"
        }
        return "Order: \(num)"
    }
}

struct ReactionComparisonLayoutSettings {

    let geometry: GeometryProxy
    let horizontalSizeClass: UserInterfaceSizeClass?
    let verticalSizeClass: UserInterfaceSizeClass?
    let ordering: [ReactionOrder]

    var height: CGFloat {
        geometry.size.height
    }

    var width: CGFloat {
        geometry.size.width
    }

    var beakerWidth: CGFloat {
        0.85 * ordered.beakerWidth
    }

    var beakerPadding: CGFloat {
        0.1 * beakerWidth
    }

    var beakerTotalWidth: CGFloat {
        beakerWidth + (2 * beakerPadding)
    }

    var chartSize: CGFloat {
        let maxW = (0.9 * availableChartWidth) / (1 + chartYLabelWidthFactor)
        let maxH = (0.9 * height) / (3 * (1 + chartXLabelHeightFactor))
        return min(maxW, maxH)
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

    var chartHorizontalSpacerWidth: CGFloat {
        0.5 * (width - chartSize)
    }

    var chartHorizontalLabelSpacing: CGFloat {
        0
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

    var dragFontSize: CGFloat {
        0.45 * orderDragHeight
    }

    var chartBorderWidth: CGFloat {
        max(0.02 * chartSize, 1.5)
    }

    var chartVerticalLabelSpacing: CGFloat {
        0
    }

    var chartFontSize: CGFloat {
        0.1 * chartSize
    }

    private var availableChartWidth: CGFloat {
        let beakyBoxWidth = ordered.beakyBoxTotalWidth
        let equationTotalWidth = equationTrailingPadding + equationsWidth
        let maxRhsWidth = max(beakyBoxWidth, equationTotalWidth)
        return width - beakerTotalWidth - maxRhsWidth
    }

    var chartTotalHeight: CGFloat {
        chartSize + chartVerticalLabelSpacing + chartXLabelHeight
    }

    var chartTotalWidth: CGFloat {
        chartSize + chartYLabelWidth + chartHorizontalLabelSpacing
    }

    var chartYLabelWidth: CGFloat {
        chartYLabelWidthFactor * chartSize
    }

    var chartXLabelHeight: CGFloat {
        chartXLabelHeightFactor * chartSize
    }

    private var chartYLabelWidthFactor: CGFloat {
        0.2
    }

    private var chartXLabelHeightFactor: CGFloat {
        0.15
    }

    func chartX(order: ReactionOrder) -> CGFloat {
        let minX = beakerTotalWidth
        let maxX = minX + availableChartWidth
        return (maxX + minX) / 2
    }

    func chartY(order: ReactionOrder) -> CGFloat {
        let heightForTop = (height - chartTotalHeight) / 2
        let topPosition = heightForTop / 2

        if ordering[0] == order {
            return topPosition
        } else if ordering[1] == order {
            return height / 2
        }
        return height - topPosition
    }

    func chartSortPriority(order: ReactionOrder) -> Double {
        if ordering[0] == order {
            return 0.49
        } else if ordering[1] == order {
            return 0.39
        }
        return 0.29
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
        let originX = midX - (chartTotalWidth / 2)
        let originY = midY - (chartTotalHeight / 2)
        return CGRect(
            x: originX + chartYLabelWidth,
            y: originY,
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

struct ReactionComparisonScreen_Previews: PreviewProvider {
    static var previews: some View {
        ReactionComparisonScreen(
            model: ReactionComparisonViewModel(
               persistence: InMemoryReactionInputPersistence()
           )
        ).previewLayout(.fixed(width: 500, height: 300))
    }
}
