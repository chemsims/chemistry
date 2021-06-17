//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationBeaker: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel

    var body: some View {
        VStack {
            TitrationBeakerTools(layout: layout, components: model.components)
            Spacer()
            TitrationBeakerMolecules(
                layout: layout,
                model: model,
                components: model.components
            )
        }
    }
}

private struct TitrationBeakerTools: View {
    let layout: TitrationScreenLayout
    @ObservedObject var components: TitrationComponents

    var body: some View {
        HStack {
            Button(action: {
                components.incrementStrongAcid(count: 1)
            }) {
                Text("Add acid")
            }
        }
    }
}

private struct TitrationBeakerMolecules: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel
    @ObservedObject var components: TitrationComponents

    var body: some View {
        AdjustableFluidBeaker(
            rows: $model.rows,
            molecules: [components.substanceCoords],
            animatingMolecules: components.ionCoords,
            currentTime: 0,
            settings: layout.common.adjustableBeakerSettings,
            canSetLevel: true,
            beakerColorMultiply: .white,
            sliderColorMultiply: .white,
            beakerModifier: BeakerAccessibilityModifier()
        )
    }
}

// TODO
private struct BeakerAccessibilityModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

struct TitrationBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            TitrationBeaker(
                layout: TitrationScreenLayout(
                    common: AcidBasesScreenLayout(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                ),
                model: TitrationViewModel()
            )
        }
        .padding()
        .previewLayout(.iPhone8Landscape)
    }
}
