//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationScreen: View {

    @ObservedObject var model: TitrationViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlights.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geo in
                TitrationScreenWithSettings(
                    model: model,
                    layout: TitrationScreenLayout(
                        common: AcidBasesScreenLayout(
                            geometry: geo,
                            verticalSizeClass: verticalSizeClass,
                            horizontalSizeClass: horizontalSizeClass
                        )
                    )
                )
            }
            .padding(AcidBasesScreenLayout.topLevelScreenPadding)
        }
    }
}

private struct TitrationScreenWithSettings: View {

    @ObservedObject var model: TitrationViewModel
    let layout: TitrationScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            TitrationBeaker(layout: layout, model: model)
                .accessibilityElement(children: .contain)
            Spacer(minLength: 0)
            TitrationChartStack(layout: layout, model: model)
                .colorMultiply(model.highlights.colorMultiply(for: nil))
                .accessibilityElement(children: .contain)

            Spacer(minLength: 0)
            TitrationRightStack(
                layout: layout,
                model: model
            )
        }
    }
}

struct TitrationScreenLayout {
    let common: AcidBasesScreenLayout

    var equationSize: CGSize {
        let availableHeight = common.height - common.beakyBoxHeight - reactionDefinitionSize.height
        return CGSize(
            width: 0.9 * availableRightStackWidth,
            height: 0.9 * availableHeight
        )
    }

    var reactionDefinitionSize: CGSize {
        let availableWidth = availableRightStackWidth - common.branchMenu.width - togglesTrailingPadding
        return CGSize(
            width: 0.9 * availableWidth,
            height: 2 * common.toggleHeight
        )
    }

    private var availableRightStackWidth: CGFloat {
        let beakerWidth = common.beakerWidth + common.sliderSettings.handleWidth
        let chartsWidth = common.chartSize

        return common.width - beakerWidth - chartsWidth
    }

    /// Height of the water from the bottom of the beaker
    func waterHeight(forRows rows: CGFloat) -> CGFloat {
        common.waterHeight(rows: rows)
    }

    /// Position of the top of the water from the top of the screen
    func topOfWaterPosition(forRows rows: CGFloat) -> CGFloat {
        common.topOfWaterPosition(rows: rows) - common.toggleHeight
    }
}

extension TitrationScreenLayout {
    var branchMenuVSpacing: CGFloat {
        1.2 * common.branchMenuHSpacing
    }

    var togglesTrailingPadding: CGFloat {
        0.1 * common.menuSize
    }
}

struct TitrationScreen_Previews: PreviewProvider {
    static var previews: some View {
        TitrationScreen(
            model: TitrationViewModel(
                titrationPersistence: InMemoryTitrationInputPersistence(),
                namePersistence: InMemoryNamePersistence.shared
            )
        )
        .padding()
        .previewLayout(.iPhone8Landscape)
    }
}
