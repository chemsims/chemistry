//
// Reactions App
//

import ReactionsCore
import SwiftUI

struct TipSlider: View {

    let formatPrice: (UnlockBadgeTipLevel) -> String?
    @Binding var selectedTipLevel: UnlockBadgeTipLevel
    let settings: SupportStudentsModalSettings

    var body: some View {
        VStack {
            slider
                .frame(size: settings.tipSliderSize)
                .accessibilityElement(children: .ignore)
                .accessibility(label: Text(sliderLabel))
                .accessibility(value: Text(sliderValue))
                .accessibilityAdjustableAction(accessibilityAction)

            amount
                .frame(height: settings.tipAmountLabelHeight)
                .accessibility(label: Text("Tip amount"))
                .accessibility(value: Text(priceAccessibilityValue))
        }
    }

    private func accessibilityAction(direction: AccessibilityAdjustmentDirection) {
        if let next = direction == .increment ? selectedTipLevel.next : selectedTipLevel.previous {
            selectedTipLevel = next
        }
    }


    private let sliderLabel: String = "Slider to set optional tip level with hearts above the slider"

    private var sliderValue: String {
        let count = "\(selectedTipLevel.userFacingIndex) hearts out of \(UnlockBadgeTipLevel.max.userFacingIndex)"
        let price = priceAccessibilityValue
        return "\(count), \(price)"
    }

    private var priceAccessibilityValue: String {
        formatPrice(selectedTipLevel) ?? "loading price"
    }

    private var slider: some View {
        GeometryReader { geo in
            TipSliderWithGeometry(
                formatPrice: formatPrice,
                selectedTipLevel: $selectedTipLevel,
                geometry: TipSliderGeometry(
                    steps: UnlockBadgeTipLevel.allCases.count,
                    width: geo.size.width,
                    height: geo.size.height
                )
            )
        }
    }

    @ViewBuilder
    private var amount: some View {
        if let price = formatPrice(selectedTipLevel) {
            Text(price)
                .font(.system(.headline))
                .animation(nil)

        } else {
            ActivityIndicator()
        }
    }
}

private struct TipSliderWithGeometry: View {

    let formatPrice: (UnlockBadgeTipLevel) -> String?
    @Binding var selectedTipLevel: UnlockBadgeTipLevel
    let geometry: TipSliderGeometry

    private let haptics = UISelectionFeedbackGenerator()

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let animationDuration: TimeInterval = 0.2

    var body: some View {
        ZStack {
            slider
            labels
        }
        .gesture(dragGesture)
    }

    private var labels: some View {
        ForEach(UnlockBadgeTipLevel.allCases) { tipLevel in
            heart(forLevel: tipLevel)
        }
    }

    private var slider: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.gray)
                .frame(size: geometry.barSize)
                .position(geometry.barPosition)

            Rectangle()
                .foregroundColor(fill)
                .frame(size: geometry.barFillSize(atIndex: selectedIndex))
                .position(geometry.barFillPosition(atIndex: selectedIndex))

            RoundedRectangle(cornerRadius: geometry.handleCornerRadius)
                .foregroundColor(fill)
                .frame(size: geometry.handleSize)
                .position(geometry.handlePosition(atIndex: selectedIndex))
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                let newIndex = geometry.index(forPosition: drag.location)
                let newTipLevel = UnlockBadgeTipLevel.allCases[newIndex]
                if newTipLevel != selectedTipLevel {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: animationDuration)) {
                        selectedTipLevel = newTipLevel
                    }
                    haptics.selectionChanged()
                }
            }
    }

    private var selectedIndex: Int {
        index(of: selectedTipLevel)
    }

    private func index(of level: UnlockBadgeTipLevel) -> Int {
        UnlockBadgeTipLevel.allCases.firstIndex(of: level) ?? 0
    }

    private let fill: Color = RGB.primaryDarkBlue.color
}

extension TipSliderWithGeometry {

    func heart(forLevel level: UnlockBadgeTipLevel) -> some View {
        let selected = selectedTipLevel == level

        var singleHeart: some View {
            Image(systemName: selected ? "heart.fill" : "heart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.labelSize.width / 6)
        }

        return HStack(spacing: 0.01 * geometry.labelSize.width) {
            singleHeart
            if level > .level1 {
                singleHeart
            }
            if level > .level2 {
                singleHeart
            }
            if level > .level3 {
                singleHeart
            }
        }
        .frame(size: geometry.labelSize)
        .font(.body.weight(selected ? .bold : .regular))
        .scaleEffect(selected ? 1.3 : 1, anchor: .bottom)
        .position(geometry.labelPosition(atIndex: index(of: level)))
        .foregroundColor(selected ? fill : .black)
    }
}

private struct TipSliderGeometry {
    let steps: Int
    let width: CGFloat
    let height: CGFloat

    func labelPosition(atIndex index: Int) -> CGPoint {
        CGPoint(x: handleX(atIndex: index), y: labelHeight / 2)
    }

    func indicatorPosition(atIndex index: Int) -> CGPoint {
        CGPoint(x: handleX(atIndex: index), y: indicatorSize / 2)
    }

    func handlePosition(atIndex index: Int) -> CGPoint {
        CGPoint(x: handleX(atIndex: index), y: barY)
    }

    func index(forPosition position: CGPoint) -> Int {
        let indexAsFloat = handleX.getX(at: position.x)
        return indexAsFloat.roundedInt().within(min: 0, max: steps - 1)
    }

    func barFillSize(atIndex index: Int) -> CGSize {
        let width = handlePosition(atIndex: index).x - barLeadingSpacing
        return CGSize(
            width: width,
            height: barHeight
        )
    }

    func barFillPosition(atIndex index: Int) -> CGPoint {
        CGPoint(
            x: barLeadingSpacing + (barFillSize(atIndex: index).width / 2),
            y: barY
        )
    }

    var barPosition: CGPoint {
        CGPoint(x: width / 2, y: barY)
    }

    var labelSize: CGSize {
        CGSize(width: labelWidth, height: labelHeight)
    }

    var barSize: CGSize {
        CGSize(width: barWidth, height: barHeight)
    }

    var handleSize: CGSize {
        CGSize(width: handleWidth, height: handleHeight)
    }

    var handleCornerRadius: CGFloat {
        handleWidth * 0.25
    }

    var indicatorSize: CGFloat {
        barSize.height
    }

    private var barLeadingSpacing: CGFloat {
        labelWidth / 2
    }

    private var labelWidth: CGFloat {
        width / CGFloat(steps + 1)
    }

    private var labelHeight: CGFloat {
        height * 0.5
    }

    private var handleHeight: CGFloat {
        height - labelHeight
    }

    private var handleWidth: CGFloat {
        0.4 * handleHeight
    }

    private var barHeight: CGFloat {
        handleHeight * 0.3
    }

    private var barWidth: CGFloat {
        width - labelWidth
    }

    private var barY: CGFloat {
        height - handleHeight / 2
    }

    private func handleX(atIndex index: Int) -> CGFloat {
        handleX.getY(at: CGFloat(index))
    }

    private var handleX: LinearEquation {
        LinearEquation(
            x1: 0,
            y1: labelWidth + barLeadingSpacing,
            x2: CGFloat(steps - 1),
            y2: width - (labelWidth / 2)
        )
    }
}

struct TipSlider_Previews: PreviewProvider {
    static var previews: some View {
        TipSlider(
            formatPrice: { "$\($0.rawValue)" },
            selectedTipLevel: .constant(.level1),
            settings: .init(width: 200, height: 50)
        )
        .frame(width: 300, height: 100)
    }
}
