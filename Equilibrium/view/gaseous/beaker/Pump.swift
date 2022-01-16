//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct Pump: View {

    let pumpModel: PumpViewModel<CGFloat>

    var body: some View {
        GeometryReader { geo in
            PumpWithGeometry(
                pumpModel: pumpModel,
                width: geo.size.width,
                height: geo.size.height
            )
        }
    }
}

private struct PumpWithGeometry: View {

    let pumpModel: PumpViewModel<CGFloat>
    let width: CGFloat
    let height: CGFloat

    init(
        pumpModel: PumpViewModel<CGFloat>,
        width: CGFloat,
        height: CGFloat
    ) {
        self.width = width
        self.height = height
        self.pumpModel = pumpModel
        self._extensionFactor = State(initialValue: pumpModel.initialExtensionFactor)
    }

    @State private var extensionFactor: CGFloat

    private static let coordSpace = "PumpCoordinateSpace"
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            // Without the spacer, the view does not fill the entire height,
            // even when ZStack is given a frame of that height
            Spacer()
                .frame(height: height)

            handle

            Image("pump-base", bundle: .equilibrium)
                .resizable()
                .frame(height: baseImageHeight)
                .allowsHitTesting(false)

        }.coordinateSpace(name: Self.coordSpace)
    }

    private var handle: some View {
        Image("pump-handle", bundle: .equilibrium)
            .resizable()
            .offset(y: -baseShapeHeight)
            .frame(width: handleWidth, height: handleHeight)
            .offset(x: handleXOffset, y: handleYOffset)
            .gesture(dragGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .named(Self.coordSpace)).onChanged { drag in
            let factor = axis.getValue(at: drag.location.y)
            let constrainedFactor = within(min: 0, max: 1, value: factor)
            pumpModel.moved(to: constrainedFactor)
            hapticHandler.valueDidChange(
                newValue: constrainedFactor,
                oldValue: self.extensionFactor
            )
            self.extensionFactor = constrainedFactor
        }
    }

    private var handleYOffset: CGFloat {
        axis.getPosition(at: extensionFactor)
    }

    private var axis: LinearAxis<CGFloat> {
        LinearAxis(
            minValuePosition: pumpedHandleYCenter,
            maxValuePosition: 0,
            minValue: 0,
            maxValue: 1
        )
    }

    private var hapticHandler: SliderHapticsHandler<CGFloat> {
        SliderHapticsHandler(axis: axis, impactGenerator: impactGenerator)
    }
}

struct PumpSettings {
    static let heightToWidth: CGFloat = 1.3
    static let nozzleToHeight: CGFloat = 0.641
    static let midPumpToWidth: CGFloat = 0.316
}

extension PumpWithGeometry {
    // Height of the base image
    var baseImageHeight: CGFloat {
        0.69 * height
    }

    // Height of the base shape itself - i.e., the pumping distance
    var baseShapeHeight: CGFloat {
        0.45 * height
    }

    var handleHeight: CGFloat {
        0.549 * height
    }

    var handleWidth: CGFloat {
        0.588 * width
    }

    var handleXOffset: CGFloat {
        0.024 * width
    }

    var pumpedHandleYCenter: CGFloat {
        0.434 * height
    }
}

struct PumpView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            Pump(pumpModel: PumpViewModel(
                    initialExtensionFactor: 1,
                    divisions: 10,
                    onDownPump: {})
            )
                .frame(
                    width: (1 / PumpSettings.heightToWidth) * geo.size.height,
                    height: geo.size.height
                )
        }
        .frame(height: 500)

    }
}
