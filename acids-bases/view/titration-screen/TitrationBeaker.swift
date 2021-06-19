//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationBeaker: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            TitrationBeakerMolecules(
                layout: layout,
                model: model,
                components: model.components
            )

            TitrationBeakerTools(
                layout: layout,
                model: model,
                components: model.components
            )
        }
    }
}

private struct TitrationBeakerTools: View {
    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel
    @ObservedObject var components: TitrationComponents

    var body: some View {
        ZStack {
            phMeter

            Dropper(
                showIndicator: true,
                tubeFill: nil
            )
            .frame(size: layout.dropperSize)
            .position(layout.dropperPosition)

            Burette(
                fill: nil,
                indicatorIsActive: true
            )
            .frame(size: layout.buretteSize)
            .position(layout.burettePosition)

            ParticleContainer(settings: .init(labelColor: .red, label: "", labelFontColor: .blue))
                .frame(size: layout.common.containerSize)
                .position(layout.containerPosition)

        }
        .frame(width: layout.toolStackWidth)
    }

    private var phMeter: some View {
        DraggablePhMeter(
            labelWhenIntersectingWater: "pH: 7",
            layout: layout.common,
            initialPosition: layout.phMeterPosition,
            rows: model.rows
        )
        .zIndex(1)
    }
}

private extension TitrationScreenLayout {
    var dropperSize: CGSize {
        let width = 0.35 * availableWidthForDropperAndBurette
        let height = width / Dropper.aspectRatio
        return CGSize(width: width, height: height)
    }

    var buretteSize: CGSize {
        let width = availableWidthForDropperAndBurette - dropperSize.width
        let height = 1.7 * width
        return CGSize(width: width, height: height)
    }

    var beakerToolsY: CGFloat {
        50
    }

    var phMeterPosition: CGPoint {
        CGPoint(
            x: common.phMeterSize.width / 2,
            y: toolsBottomY - (common.phMeterSize.height / 2)
        )
    }

    // TODO - enforce dropper is above water
    var dropperPosition: CGPoint {
        position(
            elementSize: dropperSize,
            previousElementSize: common.phMeterSize,
            previousElementPosition: phMeterPosition
        )
    }

    var burettePosition: CGPoint {
        position(
            elementSize: buretteSize,
            previousElementSize: dropperSize,
            previousElementPosition: dropperPosition
        )
    }

    var containerPosition: CGPoint {
        position(
            elementSize: common.containerSize,
            previousElementSize: buretteSize,
            previousElementPosition: burettePosition
        )
    }

    var toolStackWidth: CGFloat {
        common.beakerWidth + common.sliderSettings.handleWidth
    }

    private func position(
        elementSize: CGSize,
        previousElementSize: CGSize,
        previousElementPosition: CGPoint
    ) -> CGPoint {
        let previousTrailing = previousElementPosition.x + (previousElementSize.width / 2)
        return CGPoint(
            x: previousTrailing + common.beakerToolsSpacing + (elementSize.width / 2),
            y: toolsBottomY - (elementSize.height / 2)
        )
    }

    private var toolsBottomY: CGFloat {
        common.height - common.beakerHeight - 50
    }

    private var availableWidthForDropperAndBurette: CGFloat {
        toolStackWidth - (3 * common.beakerToolsSpacing) - common.containerSize.width - common.phMeterSize.width
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
