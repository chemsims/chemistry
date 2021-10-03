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

                PrecipitationMiddleStack(
                    components: model.components,
                    layout: layout
                )

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

private struct PrecipitationMiddleStack: View {

    let components: PrecipitationComponents
    let layout: PrecipitationScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            table
            Spacer(minLength: 0)
            chart
        }
    }

    private var table: some View {
        Table(
            rows: [
                .init(cells: ["Compound", "Molar Mass (g/mol)"]),
                .init(cells: ["Na_2_CO_3_", "106"]),
                .init(cells: ["Li_2_CO_3_", "74"]),
                .init(cells: ["K_2_CO_3_", "138"])
            ]
        )
        .frame(size: layout.tableSize)
    }

    private var chart: some View {
        ReactionProgressChart(
            model: components.reactionProgressModel,
            geometry: layout.common.reactionProgressGeometry(
                PrecipitationComponents.Molecule.self
            )
        )
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

    var tableSize: CGSize {
        let availableWidth = common.width - common.totalBeakerAreaWidth - common.beakyBoxWidth

        return CGSize(
            width: 0.7 * availableWidth,
            height: 0.35 * common.height
        )
    }
}

struct PrecipitationScreen_Previews: PreviewProvider {
    static var previews: some View {
        PrecipitationScreen(model: .init())
    }
}
