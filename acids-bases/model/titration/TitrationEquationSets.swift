//
// Reactions App
//

import Foundation

/// Represents a set of titration equations, split into left and right columns
struct TitrationEquationSet {
    let left: [TitrationEquation]
    let right: [TitrationEquation]

    private init(left: [TitrationEquation], right: [TitrationEquation]) {
        self.left = left
        self.right = right
    }

    /// Returns an equation set where the filled variant is appending immediately after each equation.
    private static func setWithFilled(
        left: [TitrationEquation],
        right: [TitrationEquation]
    ) -> TitrationEquationSet {
        TitrationEquationSet(left: appendingFilled(to: left), right: appendingFilled(to: right))
    }

    /// Returns an array where each equation has its filled variant appended immediately after it.
    private static func appendingFilled(to equations: [TitrationEquation]) -> [TitrationEquation] {
        equations.flatMap { equation in
            [equation, .filled(equation)]
        }
    }
}

// MARK: Strong acid equations
extension TitrationEquationSet {
    static func strongAcidPreEP(
        fillSubstanceAndHydrogen: Bool,
        fillTitrantMolarity: Bool,
        fillAll: Bool
    ) -> TitrationEquationSet {
        Self.setWithFilled(
            left: [
                substanceMoles(fillAll: fillSubstanceAndHydrogen),
                concentrationToSubstanceMolesOverVolume(
                    .hydrogen,
                    fillSubstanceAndConcentration: fillSubstanceAndHydrogen,
                    fillTitrant: fillAll
                )
            ],
            right: [
                titrantMoles(fillMolarity: fillTitrantMolarity, fillAll: fillAll),
                pHLogH(fillAll: fillSubstanceAndHydrogen)
            ]
        )
    }

    static let strongAcidPostEP = Self.setWithFilled(
        left: [
            substanceMoles(fillAll: true),
            concentrationToTitrantMolesOverVolume(.hydrogen, fillAll: true)
        ],
        right: [
            titrantMoles(fillMolarity: true, fillAll: true),
            pHToHydroxide(fillAll: true)
        ]
    )
}

// MARK: Strong buffer equations
extension TitrationEquationSet {
    static func strongBufferPreEp(
        fillSubstanceAndHydroxide: Bool,
        fillTitrantMolarity: Bool,
        fillAll: Bool
    ) -> TitrationEquationSet {
        Self.setWithFilled(
            left: [
                substanceMoles(fillAll: fillSubstanceAndHydroxide),
                concentrationToSubstanceMolesOverVolume(
                    .hydroxide,
                    fillSubstanceAndConcentration: fillSubstanceAndHydroxide,
                    fillTitrant: fillAll
                )
            ],
            right: [
                titrantMoles(fillMolarity: fillTitrantMolarity, fillAll: fillAll),
                pHToHydroxide(fillAll: fillAll)
            ]
        )
    }

    static let strongBufferPostEp = Self.setWithFilled(
        left: [
            substanceMoles(fillAll: true),
            concentrationToTitrantMolesOverVolume(.hydroxide, fillAll: true)
        ],
        right: [
            titrantMoles(fillMolarity: true, fillAll: true),
            pHLogH(fillAll: true)
        ]
    )
}

// MARK: Weak acid equations
extension TitrationEquationSet {
    static func weakAcidInitialReaction(
        fillSubstance: Bool,
        fillAll: Bool
    ) -> TitrationEquationSet {
        Self.setWithFilled(
            left: [
                kAToConcentration(fillSubstance: fillSubstance, fillAll: fillAll),
                pHToPKa(fillSubstance: fillSubstance, fillAll: fillAll)
            ],
            right: [
                pKa(fillAll: fillAll),
                initialSubstanceMoles(fillAll: fillAll)
            ]
        )
    }

    static func weakAcidPreEp(
        fillTitrantMolarity: Bool,
        fillAll: Bool
    ) -> TitrationEquationSet {
        Self.setWithFilled(
            left: [
                substanceMolesDifference(fillTitrant: fillAll),
                pHToPKa(fillSubstance: fillAll, fillAll: fillAll)
            ],
            right: [
                titrantMoles(fillMolarity: fillTitrantMolarity, fillAll: fillAll),
                substanceConcentrationToMolesOverVolume(fillVolume: fillAll),
                secondaryConcentrationToMolesOverVolume(fillVolume: fillAll)
            ]
        )
    }

    static let weakAcidAtEp = Self.setWithFilled(
        left: [
            kBToConcentrationForAcid(),
            pOHLogOH(fillAll: true)
        ],
        right: [
            titrantMoles(fillMolarity: true, fillAll: true),
            kWToKaAndKb,
            secondaryConcentrationToMolesOverVolume(fillVolume: true)
        ]
    )


    static func weakAcidPostEp() -> TitrationEquationSet {
        Self.setWithFilled(
            left: [
                titrantMoles(fillMolarity: true, fillAll: true),
                .concentrationToMolesOverVolume(
                    concentration: .init(.hydroxide, isFilled: true),
                    moles: .init(.titrant, isFilled: true),
                    firstVolume: .init(.equivalencePoint, isFilled: true),
                    secondVolume: .init(.titrant, isFilled: true)
                ),
                pOHLogOH(fillAll: true)
            ],
            right: [
                pHpOHSum(fillAll: true)
            ]
        )
    }
}

// MARK: Weak buffer equations
extension TitrationEquationSet {
    static func weakBufferInitialReaction(
        fillSubstance: Bool,
        fillAll: Bool
    ) -> TitrationEquationSet {
        Self.setWithFilled(
            left: [
                kBToConcentrationForBase(fillSubstance: fillSubstance, fillAll: fillAll),
                pOHToPKb(fillSubstance: fillSubstance, fillAll: fillAll)
            ],
            right: [
                pKb(fillAll: fillAll),
                initialSubstanceMoles(fillAll: fillAll)
            ]
        )
    }

    static func weakBufferPreEp(
        fillTitrantMolarity: Bool,
        fillAll: Bool
    ) -> TitrationEquationSet {
        Self.setWithFilled(
            left: [
                substanceMolesDifference(fillTitrant: fillAll),
                pOHToPKb(fillSubstance: true, fillAll: true)
            ],
            right: [
                titrantMoles(fillMolarity: fillTitrantMolarity, fillAll: fillAll),
                substanceConcentrationToMolesOverVolume(fillVolume: fillAll),
                secondaryConcentrationToMolesOverVolume(fillVolume: fillAll)
            ]
        )
    }

    static let weakBufferAtEp = Self.setWithFilled(
        left: [
            kAToConcentration(fillSubstance: true, fillAll: true),
            pHLogH(fillAll: true)
        ],
        right: [
            titrantMoles(fillMolarity: true, fillAll: true),
            kWToKaAndKb,
            secondaryConcentrationToMolesOverVolume(fillVolume: true)
        ]
    )

    static let weakBufferPostEp = Self.setWithFilled(
        left: [
            titrantMoles(fillMolarity: true, fillAll: true),
            concentrationToMolesOverVolume(.hydrogen),
            pHLogH(fillAll: true)
        ],
        right: [
            pHpOHSum(fillAll: true)
        ]
    )
}

// MARK: Common equations
extension TitrationEquationSet {
    private static func substanceMoles(fillAll: Bool) -> TitrationEquation {
        .molesToMolarity(
            moles: .init(.substance, isFilled: fillAll),
            volume: .init(.substance, isFilled: true),
            molarity: .init(.substance, isFilled: fillAll)
        )
    }

    private static func titrantMoles(fillMolarity: Bool, fillAll: Bool) -> TitrationEquation {
        .molesToMolarity(
            moles: .init(.titrant, isFilled: fillAll),
            volume: .init(.titrant, isFilled: fillMolarity || fillAll),
            molarity: .init(.titrant, isFilled: fillAll)
        )
    }

    private static func concentrationToSubstanceMolesOverVolume(
        _ concentration: TitrationEquationTerm.Concentration,
        fillSubstanceAndConcentration: Bool,
        fillTitrant: Bool
    ) -> TitrationEquation {
        .concentrationToMolesDifferenceOverVolume(
            concentration: .init(concentration, isFilled: fillSubstanceAndConcentration),
            subtractingMoles: .init(.titrant, isFilled: fillTitrant),
            fromMoles: .init(.substance, isFilled: fillSubstanceAndConcentration),
            firstVolume: .init(.substance, isFilled: fillSubstanceAndConcentration),
            secondVolume: .init(.titrant, isFilled: fillTitrant)
        )
    }

    private static func concentrationToTitrantMolesOverVolume(
        _ concentration: TitrationEquationTerm.Concentration,
        fillAll: Bool
    ) -> TitrationEquation {
        .concentrationToMolesDifferenceOverVolume(
            concentration: .init(.secondary, isFilled: fillAll),
            subtractingMoles: .init(.substance, isFilled: fillAll),
            fromMoles: .init(.titrant, isFilled: fillAll),
            firstVolume: .init(.substance, isFilled: fillAll),
            secondVolume: .init(.titrant, isFilled: fillAll)
        )
    }

    private static func pHLogH(fillAll: Bool) -> TitrationEquation {
        .pConcentration(
            pValue: .init(.hydrogen, isFilled: fillAll),
            concentration: .init(.hydrogen, isFilled: fillAll)
        )
    }

    private static func pOHLogOH(fillAll: Bool) -> TitrationEquation {
        .pConcentration(
            pValue: .init(.hydroxide, isFilled: fillAll),
            concentration: .init(.hydroxide, isFilled: fillAll)
        )
    }

    private static func pHToHydroxide(fillAll: Bool) -> TitrationEquation {
        .pLogComplementConcentration(
            pValue: .init(.hydrogen, isFilled: fillAll),
            concentration: .init(.hydroxide, isFilled: fillAll)
        )
    }

    private static func kAToConcentration(
        fillSubstance: Bool,
        fillAll: Bool
    ) -> TitrationEquation {
        .kToConcentration(
            kValue: .init(.kA, isFilled: fillAll),
            firstNumeratorConcentration: .init(.hydrogen, isFilled: fillAll),
            secondNumeratorConcentration: .init(.secondary, isFilled: fillAll),
            denominatorConcentration: .init(.substance, isFilled: fillSubstance || fillAll)
        )
    }

    private static func kBToConcentrationForAcid() -> TitrationEquation {
        .kToConcentration(
            kValue: .init(.kB, isFilled: true),
            firstNumeratorConcentration: .init(.hydroxide, isFilled: true),
            secondNumeratorConcentration: .init(.substance, isFilled: true),
            denominatorConcentration: .init(.secondary, isFilled: true)
        )
    }

    private static func kBToConcentrationForBase(
        fillSubstance: Bool,
        fillAll: Bool
    ) -> TitrationEquation {
        .kToConcentration(
            kValue: .init(.kB, isFilled: fillAll),
            firstNumeratorConcentration: .init(.hydroxide, isFilled: fillAll),
            secondNumeratorConcentration: .init(.secondary, isFilled: fillAll),
            denominatorConcentration: .init(.substance, isFilled: fillSubstance || fillAll)
        )
    }

    private static func pHToPKa(
        fillSubstance: Bool,
        fillAll: Bool
    ) -> TitrationEquation {
        .pKLog(
            pConcentration: .init(.hydrogen, isFilled: fillAll),
            pK: .init(.kA, isFilled: fillAll),
            numeratorConcentration: .init(.secondary, isFilled: fillAll),
            denominatorConcentration: .init(.substance, isFilled: fillSubstance || fillAll)
        )
    }

    private static func pOHToPKb(
        fillSubstance: Bool,
        fillAll: Bool
    ) -> TitrationEquation {
        .pKLog(
            pConcentration: .init(.hydroxide, isFilled: fillAll),
            pK: .init(.kB, isFilled: fillAll),
            numeratorConcentration: .init(.secondary, isFilled: fillAll),
            denominatorConcentration: .init(.substance, isFilled: fillSubstance)
        )
    }

    private static func pKa(fillAll: Bool) -> TitrationEquation {
        .pToLogK(
            pValue: .init(.kA, isFilled: fillAll),
            kValue: .init(.kA, isFilled: fillAll)
        )
    }

    private static func pKb(fillAll: Bool) -> TitrationEquation {
        .pToLogK(
            pValue: .init(.kB, isFilled: fillAll),
            kValue: .init(.kB, isFilled: fillAll)
        )
    }

    private static func initialSubstanceMoles(fillAll: Bool) -> TitrationEquation {
        .molesToConcentration(
            moles: .init(.initialSubstance, isFilled: fillAll),
            concentration: .init(.initialSubstance, isFilled: fillAll),
            volume: .init(.initialSubstance, isFilled: true)
        )
    }

    private static func substanceMolesDifference(fillTitrant: Bool) -> TitrationEquation {
        .molesDifference(
            difference: .init(.substance, isFilled: true),
            subtracting: .init(.initialSubstance, isFilled: true),
            from: .init(.titrant, isFilled: fillTitrant)
        )
    }

    private static func substanceConcentrationToMolesOverVolume(
        fillVolume: Bool
    ) -> TitrationEquation {
        .concentrationToMolesOverVolume(
            concentration: .init(.substance, isFilled: true),
            moles: .init(.substance, isFilled: true),
            firstVolume: .init(.initialSubstance, isFilled: true),
            secondVolume: .init(.titrant, isFilled: fillVolume)
        )
    }

    private static func secondaryConcentrationToMolesOverVolume(
        fillVolume: Bool
    ) -> TitrationEquation {
        .concentrationToMolesOverVolume(
            concentration: .init(.secondary, isFilled: true),
            moles: .init(.initialSecondary, isFilled: true),
            firstVolume: .init(.initialSubstance, isFilled: true),
            secondVolume: .init(.titrant, isFilled: fillVolume)
        )
    }

    private static func concentrationToMolesOverVolume(
        _ concentration: TitrationEquationTerm.Concentration
    ) -> TitrationEquation {
        .concentrationToMolesOverVolume(
            concentration: .init(concentration, isFilled: true),
            moles: .init(.titrant, isFilled: true),
            firstVolume: .init(.equivalencePoint, isFilled: true),
            secondVolume: .init(.titrant, isFilled: true)
        )
    }

    private static let kWToKaAndKb = TitrationEquation.kW(
            kA: .init(.kA, isFilled: true),
            kB: .init(.kB, isFilled: true)
        )

    private static func pHpOHSum(fillAll: Bool) -> TitrationEquation {
        .pSum(
            firstPValue: .init(.hydrogen, isFilled: fillAll),
            secondPValue: .init(.hydroxide, isFilled: fillAll)
        )
    }
}

struct Foo {

    // weak substance equation set
    static func getSet(
        fillSubstanceAndHydrogen: Bool,
        fillTitrantMolarity: Bool,
        fillAll: Bool
    ) -> EquationSet {
        EquationSet.appendingFilledEquations(
            left: [
                substanceMoles(fillAll: fillSubstanceAndHydrogen),
                hydrogenToMolesOverVolume(fillSubstanceAndHydrogen: fillSubstanceAndHydrogen, fillTitrant: fillAll)
            ],
            right: [
                titrantMoles(fillMolarity: fillTitrantMolarity, fillAll: fillAll),
                pHLogH(fillAll: fillSubstanceAndHydrogen)
            ]
        )
    }

    static let substanceMolesNotFilled = substanceMoles(fillAll: false)
    static let substanceMolesFilled = substanceMoles(fillAll: true)

    static let titrantMolesNotFilled = titrantMoles(fillMolarity: false, fillAll: false)
    static let titrantMolesMolarityFilled = titrantMoles(fillMolarity: true, fillAll: false)
    static let titrantMolesMolarityAllFilled = titrantMoles(fillMolarity: true, fillAll: true)

    private static func substanceMoles(fillAll: Bool) -> TitrationEquation {
        .molesToMolarity(
            moles: .init(.substance, isFilled: fillAll),
            volume: .init(.substance, isFilled: true),
            molarity: .init(.substance, isFilled: fillAll)
        )
    }

    private static func titrantMoles(fillMolarity: Bool, fillAll: Bool) -> TitrationEquation {
        .molesToMolarity(
            moles: .init(.titrant, isFilled: fillAll),
            volume: .init(.titrant, isFilled: fillMolarity || fillAll),
            molarity: .init(.titrant, isFilled: fillAll)
        )
    }

    private static func hydrogenToMolesOverVolume(
        fillSubstanceAndHydrogen: Bool,
        fillTitrant: Bool
    ) -> TitrationEquation {
        .concentrationToMolesDifferenceOverVolume(
            concentration: .init(.hydrogen, isFilled: fillSubstanceAndHydrogen),
            subtractingMoles: .init(.titrant, isFilled: fillTitrant),
            fromMoles: .init(.substance, isFilled: fillSubstanceAndHydrogen),
            firstVolume: .init(.substance, isFilled: fillSubstanceAndHydrogen),
            secondVolume: .init(.titrant, isFilled: fillTitrant)
        )
    }

    private static func pHLogH(fillAll: Bool) -> TitrationEquation {
        .pConcentration(
            pValue: .init(.hydrogen, isFilled: fillAll),
            concentration: .init(.hydrogen, isFilled: fillAll)
        )
    }

    struct EquationSet {
        let left: [TitrationEquation]
        let right: [TitrationEquation]

        /// Returns an equation set where each equation has it's filled variant appended immediately after it.
        static func appendingFilledEquations(
            left: [TitrationEquation],
            right: [TitrationEquation]
        ) -> EquationSet {
            EquationSet(
                left: appendingFilled(to: left),
                right: appendingFilled(to: right)
            )
        }

        private static func appendingFilled(to equations: [TitrationEquation]) -> [TitrationEquation] {
            equations.flatMap { equation in
                [equation, .filled(equation)]
            }
        }
    }
}

