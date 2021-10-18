//
// Reactions App
//

import Foundation

public struct Countries {

    /// Checks whether analytics should be enabled for the users locale setting.
    ///
    /// Note, the analytics we use has no tracking at all, so is likely totally compliant with GDPR. However,
    /// in the interest of caution we don't enable it in countries covered by GDPR, until we have more confidence
    /// that the app & privacy policy are totally compliant.
    ///
    /// Also, this function simply checks the users region setting, which of course they can change. As of writing, the
    /// app is not available in EU markets at all, and it may remain that way even with this check, but it is worth including for
    /// now anyway.
    public static func shouldEnableAnalytics() -> Bool {
        guard let currentRegion = NSLocale.current.regionCode else {
            // Err on the cautious side and don't enable if we can't read the region code
            // (likely to be the simulator anyway)
            return false
        }
        return !noAnalyticsCodes.contains(currentRegion)
    }

    /// Checks whether the feedback button should be included.
    ///
    /// Note, we are fairly confident that there is no GDPR concern from a user sending an email using
    /// the feedback button. However, we will err on the very cautious side and wait until we have more
    /// confidence before enabling the feedback button for all users.
    public static func shouldEnableFeedbackButton() -> Bool {
        shouldEnableAnalytics()
    }

    // Sources:
    // Countries: https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Glossary:Country_codes
    // Codes: https://en.wikipedia.org/wiki/ISO_3166-2
    // Note that the first link also lists country codes, but these are not the ISO-3166 codes.
    // The only country which differs is Greece, which is GR in the ISO-3166 standard, but
    // EL in the other link. It was verified that 'GR' is a valid region code in `NSLocale`, while
    // 'EL' is not.
    static let euRegionCodes = Set([
        "BE", "BG", "CY", "CZ", "DK", "DE", "EE", "IE", "GR", "ES", "FR", "HR", "IT",
        "LV", "LT", "LU", "HU", "MT", "NL", "AT", "PL", "PT", "RO", "SI", "SK", "FI", "SE"
    ])

    // Note that while the UK is not in the EU, it is still covered by GDPR.
    static let noAnalyticsCodes = euRegionCodes + ["GB"]
}
