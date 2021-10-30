//
// Reactions App
//


import SwiftUI

struct GaseousReactionScreen: View {

    @ObservedObject var model: GaseousReactionViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlightedElements.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geometry in
                GaseousReactionScreenWithSettings(
                    model: model,
                    settings: GaseousReactionScreenSettings(
                        geometry: geometry,
                        verticalSizeClass: verticalSizeClass,
                        horizontalSizeClass: horizontalSizeClass
                    )
                )
            }
            .padding(10)
        }
    }
}

private struct GaseousReactionScreenWithSettings: View {

    @ObservedObject var model: GaseousReactionViewModel
    let settings: GaseousReactionScreenSettings

    var body: some View {
        HStack(spacing: 0) {
            LeftStack(model: model, settings: settings)
                .zIndex(1) // Workaround for an issue where a white rectangle overlaps content when changing the chart offset sometimes

            Spacer()
            ChartStack(
                model: model,
                currentTime: $model.currentTime,
                settings: settings.common
            )
            Spacer()
            RightStackView(
                model: model,
                selectedReaction: $model.selectedReaction,
                reactions: GaseousReactionType.allCases,
                reactionSelectionIsToggled: $model.reactionSelectionIsToggled,
                settings: settings.common
            )
        }
    }
}

private struct LeftStack: View {

    @ObservedObject var model: GaseousReactionViewModel
    let settings: GaseousReactionScreenSettings

    var body: some View {
        VStack(spacing: 0) {
            reactionDefinition
                .id(model.selectedReaction.rawValue)
                .transition(.identity)
                .padding(.leading, settings.common.menuSize)
            Spacer()
            PressureBeaker(
                model: model,
                settings: settings.pressureBeakerSettings
            )
            .padding(.bottom, settings.common.beakerBottomPadding)
        }
        .accessibilityElement(children: .contain)
    }

    private var reactionDefinition: some View {
        HStack(spacing: 3) {
            if heatOnReactantSide {
                heatPlus
                    .accessibility(hidden: true)
            }

            AnimatingReactionDefinition(
                coefficients: model.selectedReaction.coefficients,
                direction: model.reactionDefinitionDirection,
                labelPrefix: heatOnReactantSide ? "heat + " : "",
                labelSuffix: heatOnProductsSide ? " + heat" : ""
            ).frame(
                width: settings.common.reactionDefinitionWidth,
                height: settings.common.reactionDefinitionHeight
            )

            if heatOnProductsSide {
                plusHeat
                    .accessibility(hidden: true)
            }
        }
        .font(.system(size: AnimatingReactionDefinition.fontSizeToHeight * settings.common.reactionDefinitionHeight))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .background(reactionDefinitionBackground)
        .padding(.leading, settings.common.menuSize)
        .colorMultiply(
            model.highlightedElements.colorMultiply(
                anyOf: .reactionDefinition, .reactionDefinitionWithAnimation
            )
        )
        .accessibilityElement(children: .combine)
    }

    private var heatOnReactantSide: Bool {
        model.selectedReaction.energyTransfer == .endothermic
    }

    private var heatOnProductsSide: Bool {
        model.selectedReaction.energyTransfer == .exothermic
    }

    @ViewBuilder
    private var reactionDefinitionBackground: some View {
        if model.highlightedElements.highlight(.reactionDefinitionWithAnimation) {
            Rectangle()
                .foregroundColor(.white)
                .padding(-0.1 * settings.common.reactionDefinitionHeight)
        } else if model.highlightedElements.highlight(.reactionDefinition) {
            Rectangle()
                .padding(
                    .vertical, settings.common.reactionDefinitionHeight * AnimatingReactionDefinition.moleculeFrameHeightToHeight
                )
                .foregroundColor(.white)
        }
    }

    private var heatPlus: some View {
        HStack(spacing: 2) {
            Text("Heat")
            Text("+")
        }
        .foregroundColor(.orangeAccent)
        .accessibilityElement(children: .ignore)
    }

    private var plusHeat: some View {
        HStack(spacing: 2) {
            Text("+")
            Text("Heat")
        }
        .foregroundColor(.orangeAccent)
        .accessibilityElement(children: .ignore)
    }
}

struct GaseousReactionScreenSettings {
    let geometry: GeometryProxy
    let verticalSizeClass: UserInterfaceSizeClass?
    let horizontalSizeClass: UserInterfaceSizeClass?
    var width: CGFloat {
        geometry.size.width
    }

    var pressureBeakerSettings: PressureBeakerSettings {
        PressureBeakerSettings(width: 0.3 * width)
    }

    var common: EquilibriumAppLayoutSettings {
        EquilibriumAppLayoutSettings(
            geometry: geometry,
            verticalSizeClass: verticalSizeClass,
            horizontalSizeClass: horizontalSizeClass
        )
    }
}

struct GaseousReactionScreen_Previews: PreviewProvider {
    static var previews: some View {
        GaseousReactionScreen(
            model: GaseousReactionViewModel()
        )
        .previewLayout(.iPhone8Landscape)
    }
}
