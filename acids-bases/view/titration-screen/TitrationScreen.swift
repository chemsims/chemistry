//
// Reactions App
//


import SwiftUI

struct TitrationScreen: View {

    let model: TitrationViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
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
    }
}

private struct TitrationScreenWithSettings: View {

    @ObservedObject var model: TitrationViewModel
    let layout: TitrationScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            TitrationBeaker(layout: layout, model: model)
            Spacer(minLength: 0)
            TitrationChartStack(layout: layout)
            Spacer(minLength: 0)
            TitrationRightStack(layout: layout, model: model)
        }
    }
}

struct TitrationScreenLayout {
    let common: AcidBasesScreenLayout

    var buretteMoleculeSize: CGFloat {
        0.5 * common.moleculeSize
    }

    var dropperMoleculeSize: CGFloat {
        0.25 * common.moleculeSize
    }
}

struct TitrationScreen_Previews: PreviewProvider {
    static var previews: some View {
        TitrationScreen(model: TitrationViewModel())
            .padding()
            .previewLayout(.iPhone8Landscape)
    }
}
