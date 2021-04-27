//
// Reactions App
//


import SwiftUI

struct GaseousReactionScreen: View {

    @ObservedObject var model: GaseousReactionViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlightedElements.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geometry in
                GaseousReactionScreenWithSettings(
                    model: model,
                    settings: GaseousReactionScreenSettings(geometry: geometry)
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
            Spacer()
            PressureBeaker(
                model: model,
                settings: settings.pressureBeakerSettings
            )
        }
    }

    private var reactionDefinition: some View {
        HStack(spacing: 3) {
            Spacer()
                .frame(width: settings.common.menuSize)

            if model.selectedReaction.energyTransfer == .endothermic {
                heatPlus
            }

            AnimatingReactionDefinition(
                coefficients: model.selectedReaction.coefficients,
                direction: model.reactionDefinitionDirection
            ).frame(
                width: settings.common.reactionDefinitionWidth,
                height: settings.common.reactionDefinitionHeight
            )

            if model.selectedReaction.energyTransfer == .exothermic {
                plusHeat
            }

        }
        .font(.system(size: AnimatingReactionDefinition.fontSizeToHeight * settings.common.reactionDefinitionHeight))
        .background(background)
    }

    private var background: some View {
        Group {
            if model.highlightedElements.highlight(.reactionDefinition) {
                Rectangle()
                    .foregroundColor(.white)
                    .padding(-0.1 * settings.common.reactionDefinitionHeight)
            } else {
                EmptyView()
            }
        }
    }

    private var heatPlus: some View {
        HStack(spacing: 2) {
            Text("Heat")
            Text("+")
        }
        .foregroundColor(.orangeAccent)
    }

    private var plusHeat: some View {
        HStack(spacing: 2) {
            Text("+")
            Text("Heat")
        }
        .foregroundColor(.orangeAccent)
    }
}

struct GaseousReactionScreenSettings {
    let geometry: GeometryProxy
    var width: CGFloat {
        geometry.size.width
    }

    var pressureBeakerSettings: PressureBeakerSettings {
        PressureBeakerSettings(width: 0.3 * width)
    }

    var common: AqueousScreenLayoutSettings {
        AqueousScreenLayoutSettings(geometry: geometry)
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
