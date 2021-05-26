//
// Reactions App
//

import ReactionsCore

struct AcidSubstanceBeakerCoords {

    let substance: AcidOrBase

    init(substance: AcidOrBase) {
        self.substance = substance
    }

    private var substanceCoords = [GridCoordinate]()
    private var primaryIonCoords = [GridCoordinate]()
    private var secondaryIonCoords = [GridCoordinate]()

    var coords: SubstanceValue<[GridCoordinate]> {
        SubstanceValue(
            substanceValue: substanceCoords,
            primaryIonValue: primaryIonCoords,
            secondaryIonValue: secondaryIonCoords
        )
    }

    /// Updates the coordinates using the new substance count
    mutating func update(
        substanceCount: Int,
        cols: Int,
        rows: Int
    ) {
        func updateCoords(
            _ coords: [GridCoordinate],
            _ desiredCount: Int,
            _ other: [[GridCoordinate]]
        ) -> [GridCoordinate] {
            let toAdd = desiredCount - coords.count
            if toAdd < 0 {
                return Array(coords.dropFirst(toAdd))
            }
            return GridCoordinateList.addingRandomElementsTo(
                grid: coords,
                count: toAdd,
                cols: cols,
                rows: rows,
                avoiding: other.flatten
            )
        }

        let perIon = substance.substanceAddedPerIon.value
        let desiredSubstance = perIon > 0 ? substanceCount : 0
        substanceCoords = updateCoords(
            substanceCoords,
            desiredSubstance,
            [primaryIonCoords, secondaryIonCoords]
        )


        let ionCount = perIon <= 0 ? substanceCount : substanceCount / perIon

        primaryIonCoords = updateCoords(
            primaryIonCoords,
            ionCount,
            [substanceCoords, secondaryIonCoords]
        )

        secondaryIonCoords = updateCoords(
            secondaryIonCoords,
            ionCount,
            [substanceCoords, primaryIonCoords]
        )
    }

}
