//
// Reactions App
//


import SwiftUI
import ReactionsCore

struct PrecipitationScreen: View {

    @ObservedObject var model: PrecipitationScreenViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { geo in
            PrecipitationScreenWithLayout(
                model: model,
                layout: .init(
                    common: .init(
                        geometry: geo,
                        verticalSizeClass: verticalSizeClass,
                        horizontalSizeClass: horizontalSizeClass
                    )
                )
            )
        }
        .padding(ChemicalReactionsScreenLayout.topLevelScreenPadding)
    }
}

private struct PrecipitationScreenWithLayout: View {

    @ObservedObject var model: PrecipitationScreenViewModel
    let layout: PrecipitationScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            PrecipitationTopStack(layout: layout)

            Spacer(minLength: 0)

            HStack(spacing: 0) {
                PrecipitationBeaker(
                    model: model,
                    layout: layout
                )
                Spacer(minLength: 0)
                Text("chart + table")
                Spacer(minLength: 0)
                PrecipitationRightStack(model: model, layout: layout)
            }
        }
    }
}

private struct PrecipitationTopStack: View {

    let layout: PrecipitationScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            Text("reaction definition")
            Spacer(minLength: 0)
            Text("selection toggle")
        }
        .padding(.leading, layout.common.menuSize + layout.common.menuHPadding)
        .font(.system(size: layout.common.reactionDefinitionFontSize))
        .frame(height: layout.common.reactionDefinitionHeight)
    }
}

private struct PrecipitationRightStack: View {

    @ObservedObject var model: PrecipitationScreenViewModel
    let layout: PrecipitationScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            Text("equation")
            Spacer(minLength: 0)
            BeakyBox(
                statement: model.statement,
                next: model.next,
                back: model.back,
                nextIsDisabled: model.nextIsDisabled,
                settings: layout.common.beakySettings
            )
        }
    }
}

struct PrecipitationScreenLayout {
    let common: ChemicalReactionsScreenLayout

    var beakerToggleTextHeight: CGFloat {
        0.1 * common.beakerSettings.beakerHeight
    }

    var beakerToggleFontSize: CGFloat {
        0.5 * beakerToggleTextHeight
    }

    func containerAreaMask(rows: CGFloat) -> CGSize {
        CGSize(
            width: common.containerMaskWidth,
            height: topOfWaterPosition(rows: rows)
        )
    }

    func topOfWaterPosition(rows: CGFloat) -> CGFloat {
        let commonTop = common.topOfWaterPosition(rows: rows)
        return commonTop - beakerToggleTextHeight
    }
}


struct PrecipitationScreen_Previews: PreviewProvider {
    static var previews: some View {
        PrecipitationScreen(model: .init())
    }
}
