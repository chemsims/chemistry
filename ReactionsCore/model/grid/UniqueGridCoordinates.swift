//
// Reactions App
//


import Foundation

extension GridCoordinate {

    /// Returns an array of grid coordinates where all coordinates are unique
    ///
    /// In the case of a duplicate, the first occurring coordinate is kept, while any others are removed
    public static func uniqueGridCoordinates(
        coords: [[GridCoordinate]]
    ) -> [[GridCoordinate]] {
        var seenCoords = Set<GridCoordinate>()
        return coords.map { coordList in
            var returnList = [GridCoordinate]()
            coordList.forEach { coord in
                if !seenCoords.contains(coord) {
                    returnList.append(coord)
                    seenCoords.insert(coord)
                }
            }
            return returnList
        }
    }
}
