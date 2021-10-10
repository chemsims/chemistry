//
// Reactions App
//

import ReactionsCore
import SwiftUI

struct PrecipitateBeakerDeposit: View {

    @ObservedObject var model: PrecipitationScreenViewModel
    @ObservedObject var components: PrecipitationComponents
    let layout: PrecipitationScreenLayout
    @GestureState var precipitateOffset: CGSize = .zero

    var body: some View {
        Polygon(points: components.precipitate.points)
            .foregroundColor(PrecipitationComponents.Molecule.product.color(reaction: model.chosenReaction))
            .frame(
                width: layout.common.innerBeakerWidth,
                height: layout.common.waterHeight(rows: model.rows)
            )
            .position(model.precipitatePosition == .scales ? layout.scalesPosition : layout.precipitatePositionInBeaker(rows: model.rows))
            .offset(precipitateOffset)
            .gesture(dragGesture)
            .animation(.easeOut(duration: 0.25), value: precipitateOffset)
            .animation(.easeOut(duration: 0.25), value: model.precipitatePosition)
    }

    private var dragGesture: some Gesture {
        DragGesture().updating($precipitateOffset) { (gesture, offsetState, _) in
            guard model.input == .weighProduct else {
                return
            }
            offsetState = gesture.translation
        }.onEnded { gesture in
            guard model.input == .weighProduct else {
                return
            }
            let isOverlapping = geometry.isOverlappingScales(offset: gesture.translation)
            if isOverlapping {
                model.precipitatePosition = .scales
            } else {
                model.precipitatePosition = .beaker
            }
        }
    }

    private var geometry: PrecipitateGeometry {
        PrecipitateGeometry(
            model: model,
            components: components,
            layout: layout
        )
    }
}

struct PrecipitateGeometry {
    let model: PrecipitationScreenViewModel
    let components: PrecipitationComponents
    let layout: PrecipitationScreenLayout

    func isOverlappingScales(offset: CGSize) -> Bool {
        let offsetRect = precipitateRect.offsetBy(dx: offset.width, dy: offset.height)
        return offsetRect.intersects(layout.scalesRect)
    }

    var position: CGPoint {
        if model.precipitatePosition == .scales {
            return layout.scalesPosition
        }
        return layout.precipitatePositionInBeaker(rows: model.rows)
    }

    /// A rect surrounding the precipitate, without accounting for drag offset.
    /// we have the rect using relative points between 0 and 1, in the reference of the containing shape.
    /// i.e., when precipitate is in water, then 0,0 is the top left of the water, and 1,1 is the
    /// bottom right.
    /// We need to convert the relative points into absolute coordinates, and then change
    /// the frame of reference so we are measuring the origin from the parent view, rather than
    /// the containing shape.
    var precipitateRect: CGRect {
        let baseRect = components.precipitate.boundingRect

        let shapeWidth = layout.common.innerBeakerWidth
        let shapeHeight = layout.common.waterHeight(rows: model.rows)

        let scaledSize = CGSize(
            width: shapeWidth * baseRect.size.width,
            height: shapeHeight * baseRect.size.height
        )

        // Distance of precipitate rect origin from the shape origin (top left of the shape, not the center)
        let scaledOriginInShape = CGPoint(
            x: shapeWidth * baseRect.origin.x,
            y: shapeHeight * baseRect.origin.y
        )

        let shapeCenterFromParentView = position
        let shapeOriginFromCenter = CGPoint(x: -shapeWidth / 2, y: -shapeHeight / 2)

        // If you draw out these origins out as lines, it is clearer
        // that we need to sum each 3 components. Imagine we are at
        // the parent origin, we first move to the center. We then
        // move to the shape origin, and finally to the precipitate
        // rect origin.
        let newOrigin = CGPoint(
            x: shapeCenterFromParentView.x + shapeOriginFromCenter.x + scaledOriginInShape.x,
            y: shapeCenterFromParentView.y + shapeOriginFromCenter.y + scaledOriginInShape.y
        )

        return CGRect(origin: newOrigin, size: scaledSize)
    }
}
