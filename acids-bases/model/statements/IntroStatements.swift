//
// Reactions App
//

import ReactionsCore

struct IntroStatements {
    static let intro: [TextLine] = [
        """
        *Acids and bases* are extremely common, as are the reactions \
        between acids and bases. The driving force is often the \
        hydronium ion reacting with the hydroxide to form water.
        """
    ]

    static let explainTexture: [TextLine] = [
        """
        At the macroscopic level, *acids* taste sour, may be damaging to \
        the skin, and react with bases to yield salts. *Bases* tase bitter,
        feel slippery, and react with acids to form salts. But on a microscopic \
        level there are various definitions by authors.
        """
    ]

    static let explainArrhenius: [TextLine] = [
        """
        An *Arrhenius acid* is a substance that dissociates in water into \
        hydrogen ions *(H^+^)* increasing the concentration of H^+^ ions in \
        the solution. An *Arrhenius base* is a substance that dissociates in \
        water into hydroxide *(OH^-^)* ions; increasing the concentration of \
        OH^-^ ions in an aqueous solution (aq).
        """
    ]

    static let explainBronstedLowry: [TextLine] = [
        """
        *The Bronsted-Lowry* definition states that acids are those with the \
        ability to "donate" hydrogen ions *(H^+^)*, otherwise known as *protons*,
        and bases are those that "accept" them.
        """
    ]

    static let explainLewis: [TextLine] = [
        """
        *The Lewis* definition defines a base (referred to as a Lewis base) to be \
        a compound that can donate an *electron pair*, and an acid (a Lewis acid) to \
        be a compound that can receive this electron pair.
        """
    ]

    static let explainSimpleDefinition: [TextLine] = [
        """
        To put it simply, the presence of *H^+^* ions in a solution makes it acidic, \
        while the presence of *OH^-^* makes it basic. Acids and bases are classified \
        in strong and weak. This will depend on how much they can *dissociate* into \
        H^+^ or OH^-^.
        """
    ]

    static let chooseStrongAcid: [TextLine] = [
        """
        Strong acids are those that dissociate entirely into H^+^ ions. The reaction \
        of these acids with water goes to completion.
        """,
        "*Choose a strong acid.*"
    ]
}
