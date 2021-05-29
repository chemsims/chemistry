//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntroBeaker: View {

    @ObservedObject var model: IntroScreenViewModel
    let layout: IntroScreenLayout

    var body: some View {
        ZStack(alignment: .bottom) {

            beaker

            Button(action: {
                model.increment()
            }) {
                Text("add acid")
            }

        }
        .frame(height: layout.common.height)
    }

    private var containers: some View {
        Text("foo")
    }

    private var beaker: some View {
        AdjustableFluidBeaker(
            rows: $model.rows,
            molecules: model.components.coords.all,
            animatingMolecules: [],
            currentTime: 0,
            settings: AdjustableFluidBeakerSettings(
                minRows: AcidAppSettings.minBeakerRows,
                maxRows: AcidAppSettings.maxBeakerRows,
                beakerWidth: layout.common.beakerWidth,
                beakerHeight: layout.common.beakerHeight,
                sliderSettings: layout.common.sliderSettings,
                sliderHeight: layout.common.sliderHeight
            ),
            canSetLevel: true,
            beakerColorMultiply: .white,
            sliderColorMultiply: .white,
            beakerModifier: AddMoleculesAccessibilityModifier()
        )
    }
}

struct AddMoleculesAccessibilityModifier: ViewModifier {
    // TODO
    func body(content: Content) -> some View {
        content
    }
}

struct IntroBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            IntroBeaker(
                model: IntroScreenViewModel(),
                layout: IntroScreenLayout(
                    common: AcidBasesGeneralScreenLayout(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                )
            )
        }
        .previewLayout(.iPhoneSELandscape)
    }
}
