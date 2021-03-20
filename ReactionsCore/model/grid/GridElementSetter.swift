//
// Reactions App
//


import Foundation

public struct GridElementSetter {
    let elements: [GridElementToBalance]
    let shuffledCoords: [GridCoordinate]

    public init(elements: [GridElementToBalance], shuffledCoords: [GridCoordinate]) {
        self.elements = elements
        self.shuffledCoords = shuffledCoords
    }

    public var balancedElements: [BalancedGridElement] {
        var builder = [BalancedGridElement]()

        func getElement(for index: Int) -> BalancedGridElement {
            let currentElement = elements[index]
            if currentElement.delta < 0 {
                return currentElement.decreasingElement(
                    with: currentElement.initialCoords,
                    extraDrop: abs(currentElement.delta)
                )
            }

            let prevToAvoid = builder.flatMap(\.coords)
            let nextToAvoid = elements[(index+1)...].flatMap(\.initialCoords)
            let newCoords = GridCoordinateList.addingElementsTo(
                grid: currentElement.initialCoords,
                count: currentElement.delta,
                from: shuffledCoords,
                avoiding: prevToAvoid + nextToAvoid
            )
            return currentElement.increasingElement(with: newCoords)
        }

        for index in elements.indices {
            builder.append(getElement(for: index))
        }
        return builder
    }

}

private extension GridElementToBalance {

}
